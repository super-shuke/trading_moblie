// 此文件定义了 DioClient —— 全局唯一的 Dio 实例提供者。
//
// 设计原则：
// 1. 单例：整个 App 共用一个 Dio，避免每个 Repository 自己 new 一个；
// 2. 懒初始化：在 main() 启动时调用一次 initialize() 注入回调即可；
// 3. 拦截器顺序由内部保证，调用方无需关心；
// 4. 与 NestJS 后端 (GeoTravel Backend) 完全配套：
//    - 自动附加 Authorization: Bearer <accessToken>
//    - 收到 401 时先尝试 refreshToken 续期再重试原请求
//    - 自动解包后端 { success, data, timestamp } 响应格式
//
// 用法：
//   void main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     final authStore = AuthStore(); // 你的 token 仓库（建议用 flutter_secure_storage）
//     DioClient.instance.initialize(
//       baseUrl: 'http://localhost:3000/api/v1',
//       accessTokenProvider: () => authStore.accessToken,
//       refreshTokenProvider: () => authStore.refreshToken,
//       onTokensRefreshed: (a, r) => authStore.save(access: a, refresh: r),
//       onUnauthorized: () => GoRouter.of(ctx).go('/login'),
//     );
//     runApp(const MyApp());
//   }
//
//   // 业务调用
//   final res = await DioClient.instance.dio.get('/cities');
//   print(res.data); // 已自动解包 → { items, page, pageSize, total, totalPages }

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/response_unwrap_interceptor.dart';
import 'interceptors/unauthorized_interceptor.dart';
import 'interceptors/safe_log_interceptor.dart';

class DioClient {
  // 私有构造 + 静态单例
  DioClient._()
      : dio = Dio(
          BaseOptions(
            baseUrl: _defaultBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
            // 让 4xx/5xx 也走 onResponse（不抛异常），由拦截器统一处理
            // 设为 null 表示交还给 Dio 默认行为；保持默认即可。
          ),
        );

  /// 通过 `--dart-define=API_BASE_URL=...` 编译注入；
  /// 不传时 initialize() 里手动设置。
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// 全局单例
  static final DioClient instance = DioClient._();

  /// 业务方拿到的 Dio 实例
  final Dio dio;

  /// 防止重复 initialize（热重载时也安全）
  bool _initialized = false;

  /// 初始化拦截器栈。
  ///
  /// 必须在 App 启动时调用一次。所有参数都通过回调注入，
  /// 这样 DioClient 完全不依赖具体的存储/路由实现，便于测试。
  ///
  /// - [baseUrl]               后端地址，覆盖编译时注入的 API_BASE_URL
  /// - [accessTokenProvider]   返回当前 access token（同步或异步均可）
  /// - [refreshTokenProvider]  返回当前 refresh token，用于 401 续期
  /// - [onTokensRefreshed]     续期成功后回调，调用方负责持久化新 token
  /// - [onUnauthorized]        续期失败 / refresh token 也过期时回调，
  ///                           典型动作是跳转登录页 + 清空本地 token
  /// - [enableLogging]         是否打印请求日志；默认仅在 debug 模式开
  void initialize({
    String? baseUrl,
    required AccessTokenProvider accessTokenProvider,
    RefreshTokenProvider? refreshTokenProvider,
    TokensRefreshedCallback? onTokensRefreshed,
    UnauthorizedHandler? onUnauthorized,
    bool enableLogging = kDebugMode,
  }) {
    if (_initialized) {
      // 热重载场景：先清掉旧拦截器再重新装
      dio.interceptors.clear();
    }

    if (baseUrl != null && baseUrl.isNotEmpty) {
      dio.options.baseUrl = baseUrl;
    }
    assert(
      dio.options.baseUrl.isNotEmpty,
      'DioClient.baseUrl 未设置。请在 initialize() 时传入 baseUrl，'
      '或编译时通过 --dart-define=API_BASE_URL=... 注入。',
    );

    // ─── 拦截器顺序（重要！） ──────────────────────────────────
    // Dio 拦截器在请求阶段按"添加顺序"执行，
    // 在响应/错误阶段按"反向顺序"执行。
    //
    // 添加顺序：[auth] → [unauthorized] → [unwrap] → [logger]
    //
    // 请求路径：
    //   业务发请求 → auth 加 token → unauthorized 透传 →
    //   unwrap 透传 → logger 打印 → 真正发送
    //
    // 响应路径（成功）：
    //   服务器返回 → logger 打印 → unwrap 解包 →
    //   unauthorized 透传 → auth 透传 → 交给业务
    //
    // 错误路径（401）：
    //   服务器返回 401 → logger 打印 → unwrap 透传 →
    //   unauthorized 触发登出 → auth 尝试 refresh + 重试 → ...
    //
    // 注意：auth 的 onError 必须在最内层（最后添加），
    // 因为 refresh 重试要在所有日志之前触发，避免重试请求被日志重复打印。
    // ────────────────────────────────────────────────────────

    // 1. Auth：请求时附加 token；收到 401 时尝试 refresh + 重试
    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        accessTokenProvider: accessTokenProvider,
        refreshTokenProvider: refreshTokenProvider,
        onTokensRefreshed: onTokensRefreshed,
      ),
    );

    // 2. Unauthorized：refresh 也失败时，触发跳登录
    if (onUnauthorized != null) {
      dio.interceptors.add(
        UnauthorizedInterceptor(onUnauthorized: onUnauthorized),
      );
    }

    // 3. Response Unwrap：把后端的 { success, data, timestamp } 拆掉，
    //    业务拿到的 response.data 直接是 data 字段的内容
    dio.interceptors.add(ResponseUnwrapInterceptor());

    // 4. Logger：最外层，看到最原始的请求和最终的响应；
    //    内部已脱敏 token，生产环境也安全（但默认不开）
    if (enableLogging) {
      dio.interceptors.add(SafeLogInterceptor());
    }

    _initialized = true;
  }

  /// 业务侧便利方法：构造一个"跳过认证"的 Options。
  ///
  /// 用法：
  ///   await dio.get('/some-public-endpoint', options: DioClient.skipAuth());
  ///
  /// 注意：你后端的 cities/pois 等公开接口本身就允许匿名访问，
  /// 但带上 token 也无妨；这个方法主要用于：
  ///   - 登录/刷新接口（不能带旧 token，否则可能被 401 拦截器循环）
  ///   - 调用第三方 API（不希望泄漏自家 token）
  static Options skipAuth([Options? base]) {
    return (base ?? Options()).copyWith(
      extra: {...?base?.extra, _skipAuthKey: true},
    );
  }

  /// 内部用的 extra key，AuthInterceptor 通过它识别"跳过"标记
  static const String _skipAuthKey = '__skipAuth__';
  static const String skipAuthKey = _skipAuthKey;
}
