

import 'dart:async';


import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:traveling_app/service/auth/auth_store.dart';
/// 续期失败时由 Api 触发的回调签名。
typedef UnauthorizedHandler = FutureOr<void> Function();

// ============================================================================
//                                  Api
// ============================================================================

class Api {
  // ─── 单例 ──────────────────────────────────────────────────────────────
  Api._();
  static final Api _instance = Api._();

  /// 全局单例。建议起一个短别名：`final api = Api.main;`
  static Api get main => _instance;

  // ─── 配置 ──────────────────────────────────────────────────────────────

  /// 续期失败 / refresh token 也过期时触发。
  /// 典型实现：跳登录页 + 弹 Toast。可以随时赋值。
  UnauthorizedHandler? onUnauthorized;

  // ─── 私有状态 ──────────────────────────────────────────────────────────

  late final Dio _dio;
  late final AuthStore _tokens;
  bool _initialized = false;

  // 并发 refresh 共享：第一个 401 触发 refresh，后续 401 等同一个 Future
  Completer<String?>? _refreshing;

  // ─── 初始化 ────────────────────────────────────────────────────────────

  /// App 启动时调用一次（必须）。
  ///
  /// - [baseUrl] 后端基地址，例如 'http://localhost:3000/api/v1'
  /// - [connectTimeout] / [receiveTimeout] / [sendTimeout] 可选超时
  /// - [enableLogging] 是否打印请求日志；默认仅 debug 模式开启
  Future<void> init({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
    Duration sendTimeout = const Duration(seconds: 15),
    bool? enableLogging,
  }) async {
    assert(!_initialized, 'Api.mainnit() 只能调用一次');
    assert(baseUrl.isNotEmpty, 'baseUrl 不能为空');

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));

    _tokens = AuthStore();
    await _tokens.loadFromDisk();

    _installInterceptors(enableLogging ?? kDebugMode);
    _initialized = true;
  }

  // ─── 认证 ──────────────────────────────────────────────────────────────

  /// 是否已登录（仅内存判断，不会去访问磁盘）
  bool get isAuthenticated => _tokens.accessToken != null;

  /// 当前 access token；如果未登录则为 null。
  String? get accessToken => _tokens.accessToken;

  /// 当前用户信息缓存（最近一次 loginWithGoogle / refreshMe 后存的）
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? _currentUser;

  /// 用 Google ID Token 登录。
  /// 成功后 token 自动持久化，后续请求自动带上。
  Future<void> loginWithGoogle(String idToken) async {
    _assertInit();
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/google',
      data: {'idToken': idToken},
      options: _skipAuthOptions(), // 登录请求不带旧 token
    );
    final data = _unwrap(res);
    await _tokens.save(
      access: data['accessToken'] as String,
      refresh: data['refreshToken'] as String,
    );
    _currentUser = (data['user'] as Map?)?.cast<String, dynamic>();
  }

  /// 登出：通知后端 → 清空本地 token。
  /// 即使后端调用失败也会清本地。
  Future<void> logout() async {
    _assertInit();
    try {
      if (_tokens.accessToken != null) {
        await _dio.post('/auth/logout');
      }
    } catch (_) {
      // 即使后端报错也要清本地
    } finally {
      await _tokens.clear();
      _currentUser = null;
    }
  }

  // ─── 业务请求 ──────────────────────────────────────────────────────────

  /// GET 请求；返回已解包的业务数据（即后端 `data` 字段）
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) {
    return _request('GET', path, query: query, skipAuth: skipAuth);
  }

  /// POST 请求
  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) {
    return _request('POST', path, body: body, query: query, skipAuth: skipAuth);
  }

  /// PATCH 请求
  Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) {
    return _request('PATCH', path, body: body, query: query, skipAuth: skipAuth);
  }

  /// PUT 请求
  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) {
    return _request('PUT', path, body: body, query: query, skipAuth: skipAuth);
  }

  /// DELETE 请求
  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) {
    return _request('DELETE', path, body: body, query: query, skipAuth: skipAuth);
  }

  // ─── 内部实现：请求 ────────────────────────────────────────────────────

  Future<dynamic> _request(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool skipAuth = false,
  }) async {
    _assertInit();
    try {
      final res = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          extra: skipAuth ? {_kSkipAuth: true} : null,
        ),
      );
      return _unwrap(res);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  // ─── 内部实现：拦截器装配 ──────────────────────────────────────────────

  void _installInterceptors(bool enableLogging) {
    _dio.interceptors.add(InterceptorsWrapper(
      // ── 请求：加 Authorization ────────────────────────────
      onRequest: (options, handler) async {
        // 显式跳过 / 登录刷新端点 → 不带 token
        if (options.extra[_kSkipAuth] == true ||
            _isAuthEndpoint(options.path)) {
          return handler.next(options);
        }
        final token = _tokens.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },

      // ── 错误：401 自动 refresh + 重试 ─────────────────────
      onError: (err, handler) async {
        // 非 401 直接透传
        if (err.response?.statusCode != 401) {
          return handler.next(err);
        }
        // 续期接口自己 401 → refresh token 也过期，直接清账号
        if (_isAuthEndpoint(err.requestOptions.path)) {
          await _handleUnauthorized();
          return handler.next(err);
        }
        // 已经重试过的请求 → 防止死循环
        if (err.requestOptions.extra[_kAlreadyRetried] == true) {
          await _handleUnauthorized();
          return handler.next(err);
        }

        try {
          final newToken = await _refreshAccessToken();
          if (newToken == null) {
            await _handleUnauthorized();
            return handler.next(err);
          }
          // 用新 token 重试
          final retried = await _retry(err.requestOptions, newToken);
          handler.resolve(retried);
        } catch (_) {
          await _handleUnauthorized();
          handler.next(err);
        }
      },
    ));

    // ── 日志（可选，含脱敏）────────────────────────────────
    if (enableLogging) {
      _dio.interceptors.add(_safeLogger());
    }
  }

  // ─── 内部实现：refresh 并发安全 ────────────────────────────────────────

  Future<String?> _refreshAccessToken() async {
    // 已有 refresh 在进行 → 复用它，避免重复调
    final ongoing = _refreshing;
    if (ongoing != null) return ongoing.future;

    final completer = Completer<String?>();
    _refreshing = completer;
    try {
      final refresh = _tokens.refreshToken;
      if (refresh == null) {
        completer.complete(null);
        return null;
      }

      final res = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refresh},
        options: _skipAuthOptions(),
      );
      final data = _unwrap(res) as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String;
      final newRefresh = data['refreshToken'] as String;

      await _tokens.save(access: newAccess, refresh: newRefresh);
      completer.complete(newAccess);
      return newAccess;
    } catch (_) {
      completer.complete(null);
      return null;
    } finally {
      _refreshing = null;
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions original,
    String newToken,
  ) {
    final headers = Map<String, dynamic>.from(original.headers)
      ..['Authorization'] = 'Bearer $newToken';
    final extra = Map<String, dynamic>.from(original.extra)
      ..[_kAlreadyRetried] = true;
    return _dio.fetch<dynamic>(
      original.copyWith(headers: headers, extra: extra),
    );
  }

  Future<void> _handleUnauthorized() async {
    await _tokens.clear();
    _currentUser = null;
    final cb = onUnauthorized;
    if (cb != null) {
      // 异步触发，不阻塞错误传递
      Future(() async => cb());
    }
  }

  // ─── 内部实现：响应解包 ────────────────────────────────────────────────

  /// 把后端 `{ success, data, timestamp }` 外壳剥掉。
  /// 如果不是这种格式（如某些第三方代理），原样返回 res.data。
  dynamic _unwrap(Response<dynamic> res) {
    final body = res.data;
    if (body is Map && body['success'] == true && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  // ─── 内部实现：错误转换 ────────────────────────────────────────────────

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode ?? -1;
    final body = e.response?.data;

    String message = e.message ?? 'Network error';
    String? error;
    String? path = e.requestOptions.path;

    if (body is Map) {
      final m = body['message'];
      if (m is String) {
        message = m;
      } else if (m is List && m.isNotEmpty) {
        // class-validator 校验错误是数组
        message = m.join(', ');
      }
      error = body['error'] as String?;
      path = body['path'] as String? ?? path;
    }

    return ApiException(
      statusCode: status,
      message: message,
      error: error,
      path: path,
      cause: e,
    );
  }

  // ─── 内部实现：日志（脱敏） ────────────────────────────────────────────

  Interceptor _safeLogger() {
    return InterceptorsWrapper(
      onRequest: (o, h) {
        debugPrint('→ ${o.method} ${o.baseUrl}${o.path}');
        final auth = o.headers['Authorization'];
        if (auth is String && auth.startsWith('Bearer ')) {
          final t = auth.substring(7);
          final mask = t.length <= 12
              ? '***'
              : '${t.substring(0, 6)}...${t.substring(t.length - 4)}';
          debugPrint('  Authorization: Bearer $mask');
        }
        if (o.queryParameters.isNotEmpty) {
          debugPrint('  Query: ${o.queryParameters}');
        }
        if (o.data != null) debugPrint('  Body: ${_maskBody(o.data)}');
        h.next(o);
      },
      onResponse: (r, h) {
        debugPrint('← ${r.statusCode} ${r.requestOptions.path}');
        if (r.data != null) debugPrint('  Body: ${_maskBody(r.data)}');
        h.next(r);
      },
      onError: (e, h) {
        debugPrint('✗ ${e.response?.statusCode ?? '-'} ${e.requestOptions.path}'
            '  ${e.message ?? ''}');
        h.next(e);
      },
    );
  }

  // ─── 工具 ──────────────────────────────────────────────────────────────

  void _assertInit() {
    assert(_initialized, 'Api 未初始化。请在 main() 中调用 Api.main.init(baseUrl: ...)');
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/google') || path.contains('/auth/refresh');
  }

  Options _skipAuthOptions() => Options(extra: {_kSkipAuth: true});

  String _maskBody(Object? body) {
    var s = body.toString();
    s = s.replaceAllMapped(
      RegExp(r'"(accessToken|refreshToken|idToken|password)"\s*:\s*"[^"]*"'),
      (m) => '"${m.group(1)}":"***"',
    );
    return s.length > 2000 ? '${s.substring(0, 2000)}...(truncated)' : s;
  }

  // ─── 私有常量 ──────────────────────────────────────────────────────────
  static const String _kSkipAuth = '__skipAuth__';
  static const String _kAlreadyRetried = '__authRetried__';
}

// API 错误封装，包含 HTTP 状态码、后端 message/error 字段、请求路径等信息。
class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.error,
    this.path,
    this.cause,
  });

  /// HTTP 状态码；网络错误时为 -1
  final int statusCode;

  /// 给用户/开发看的消息（优先取后端 message，其次 Dio 错误信息）
  final String message;

  /// 后端 error 字段（如 "NotFoundException"）；网络错误时为 null
  final String? error;

  /// 出错的 API 路径
  final String? path;

  /// 原始 DioException，便于深入排查
  final DioException? cause;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isNetworkError => statusCode == -1;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
