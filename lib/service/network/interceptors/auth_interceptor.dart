// AuthInterceptor —— 认证拦截器
//
// 职责：
//   1) 请求阶段：自动附加 "Authorization: Bearer <accessToken>" 请求头
//   2) 响应阶段：当后端返回 401 时，自动尝试用 refreshToken 续期一次，
//      然后用新 token 重放原请求；调用方完全无感知。
//
// 与后端的契约（参考 GeoTravel NestJS backend）：
//   - 公开接口：写了 @Public() 的路由，不带 token 也能访问
//   - 私有接口：JwtAuthGuard 验证失败 → 401
//   - 续期接口：POST /auth/refresh  { refreshToken } → { accessToken, refreshToken, ... }
//
// 跳过认证：在 RequestOptions.extra 里加 __skipAuth__ = true，
//          或使用 DioClient.skipAuth() 便利方法。
//          /auth/google 和 /auth/refresh 这两个端点会被自动识别并跳过。

import 'dart:async';
import 'package:dio/dio.dart';

import '../dio_client.dart';

/// 返回当前 access token；返回 null 表示用户未登录。
/// 支持同步或异步实现。
typedef AccessTokenProvider = FutureOr<String?> Function();

/// 返回当前 refresh token；返回 null 表示无法续期（用户需重新登录）。
typedef RefreshTokenProvider = FutureOr<String?> Function();

/// 续期成功后的回调，业务方负责把新 token 持久化（如写入 SecureStorage）。
typedef TokensRefreshedCallback = FutureOr<void> Function(
  String accessToken,
  String refreshToken,
);

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.accessTokenProvider,
    this.refreshTokenProvider,
    this.onTokensRefreshed,
    this.refreshEndpoint = '/auth/refresh',
  });

  /// 注入同一个 Dio 实例，用于"重试原请求"。
  /// 不能 new 一个新的 Dio，否则会失去 baseUrl / 其他拦截器。
  final Dio dio;

  final AccessTokenProvider accessTokenProvider;
  final RefreshTokenProvider? refreshTokenProvider;
  final TokensRefreshedCallback? onTokensRefreshed;

  /// 续期端点路径，与后端保持一致
  final String refreshEndpoint;

  // ─── 并发控制 ─────────────────────────────────────────────
  // 当 N 个请求同时拿到 401 时，只能发起 1 次 refresh，
  // 其他请求等待这次 refresh 的结果。否则会出现：
  //   - refresh 接口被打 N 次
  //   - 后发的请求拿到旧 refresh token → 又 401 → 死循环
  //
  // 用一个 Completer 当"广播信号"：
  //   - 第一个 401 触发 refresh，建立 _refreshing
  //   - 后续 401 进来发现 _refreshing 不为 null，就 await 它
  //   - refresh 完成后 _refreshing 置 null，下一次 401 再开新一轮
  // ────────────────────────────────────────────────────────
  Completer<String?>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 显式跳过：业务方主动声明不要附加 token
    if (options.extra[DioClient.skipAuthKey] == true) {
      return handler.next(options);
    }

    // 隐式跳过：登录 / 刷新这两个端点不能带旧 token，
    // 否则可能形成"401 → refresh → 又 401"循环。
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await accessTokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 非 401 直接透传
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    // 没配 refreshTokenProvider 或 onTokensRefreshed → 没法续期，直接透传给下游
    // （下游的 UnauthorizedInterceptor 会触发跳登录）
    if (refreshTokenProvider == null || onTokensRefreshed == null) {
      return handler.next(err);
    }
    // 续期端点自己 401 → 说明 refresh token 也过期了，不要再递归
    if (_isAuthEndpoint(err.requestOptions.path)) {
      return handler.next(err);
    }
    // 标记为"已经重试过的请求"，避免无限循环
    if (err.requestOptions.extra[_alreadyRetriedKey] == true) {
      return handler.next(err);
    }

    try {
      // 1) 拿到（或等待）新的 access token
      final newAccessToken = await _refreshAccessToken();
      if (newAccessToken == null) {
        // 续期失败 → 把原 401 错误透传出去
        return handler.next(err);
      }

      // 2) 用新 token 重试原请求
      final retried = await _retry(err.requestOptions, newAccessToken);
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    } catch (e, st) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: e,
          stackTrace: st,
          message: 'Token refresh failed',
        ),
      );
    }
  }

  // ─── helpers ──────────────────────────────────────────────

  /// 单次 refresh，并发请求会共享同一个 Future。
  Future<String?> _refreshAccessToken() async {
    // 已经有一个 refresh 在进行 → 复用它
    final ongoing = _refreshing;
    if (ongoing != null) {
      return ongoing.future;
    }

    final completer = Completer<String?>();
    _refreshing = completer;

    try {
      final refreshToken = await refreshTokenProvider!();
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(null);
        return null;
      }

      // 调用 /auth/refresh
      final res = await dio.post<Map<String, dynamic>>(
        refreshEndpoint,
        data: {'refreshToken': refreshToken},
        options: DioClient.skipAuth(), // 不带旧 token
      );

      // 拿响应数据 —— 注意此时 ResponseUnwrapInterceptor 已经解过包，
      // res.data 就是 { accessToken, refreshToken, expiresIn, user } 本身
      final data = res.data;
      if (data == null) {
        completer.complete(null);
        return null;
      }
      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newAccess == null || newRefresh == null) {
        completer.complete(null);
        return null;
      }

      // 通知业务方持久化
      await onTokensRefreshed!(newAccess, newRefresh);

      completer.complete(newAccess);
      return newAccess;
    } catch (e) {
      // refresh 本身失败（网络 / 401 / 服务端异常）
      completer.complete(null);
      return null;
    } finally {
      _refreshing = null;
    }
  }

  /// 用新 token 重试原请求
  Future<Response<dynamic>> _retry(
    RequestOptions original,
    String newAccessToken,
  ) {
    final newHeaders = Map<String, dynamic>.from(original.headers)
      ..['Authorization'] = 'Bearer $newAccessToken';

    final newExtra = Map<String, dynamic>.from(original.extra)
      ..[_alreadyRetriedKey] = true;

    return dio.fetch<dynamic>(
      original.copyWith(headers: newHeaders, extra: newExtra),
    );
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/google') || path.contains(refreshEndpoint);
  }

  static const String _alreadyRetriedKey = '__authRetried__';
}
