// SafeLogInterceptor —— 安全日志拦截器
//
// 在 LogInterceptor 基础上做了两件事：
//   1) Authorization 请求头打印时只显示前后几位（"Bearer eyJh...x9z2"）；
//   2) 响应/请求体里的 accessToken / refreshToken / idToken 字段值脱敏为 "***"。
//
// 这样即使在 release 包里有人手动打开日志（或者把 logcat 抓出来给同事），
// 也不会泄漏真实凭据。
//
// 注意：日志拦截器永远是开发辅助，生产环境默认应该关闭。
//      DioClient.initialize(enableLogging: kDebugMode) 已经做了默认保护。

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SafeLogInterceptor extends Interceptor {
  SafeLogInterceptor({this.maxBodyLength = 2000});

  /// 单条 body 日志的最大长度，超过截断（避免大 JSON 刷屏）
  final int maxBodyLength;

  // 匹配 JSON 里的敏感字段：
  //   "accessToken": "xxx"   →   "accessToken":"***"
  static final RegExp _tokenFieldPattern = RegExp(
    r'"(accessToken|refreshToken|idToken|password)"\s*:\s*"[^"]*"',
  );

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    debugPrint('┌─── HTTP →  ${options.method}  ${_fullPath(options)}');
    final auth = options.headers['Authorization'];
    if (auth is String && auth.startsWith('Bearer ')) {
      debugPrint('│  Authorization: ${_maskBearer(auth)}');
    }
    if (options.queryParameters.isNotEmpty) {
      debugPrint('│  Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      debugPrint('│  Body : ${_maskBody(options.data)}');
    }
    debugPrint('└──────');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final code = response.statusCode;
    debugPrint('┌─── HTTP ←  $code  ${_fullPath(response.requestOptions)}');
    if (response.data != null) {
      debugPrint('│  Body : ${_maskBody(response.data)}');
    }
    debugPrint('└──────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final code = err.response?.statusCode ?? '-';
    debugPrint('┌─── HTTP ✗  $code  ${_fullPath(err.requestOptions)}');
    debugPrint('│  Type   : ${err.type}');
    debugPrint('│  Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('│  Body   : ${_maskBody(err.response!.data)}');
    }
    debugPrint('└──────');
    handler.next(err);
  }

  // ─── helpers ──────────────────────────────────────────────

  String _fullPath(RequestOptions o) {
    final base = o.baseUrl.isNotEmpty ? o.baseUrl : '';
    return '$base${o.path}';
  }

  String _maskBearer(String header) {
    final token = header.substring('Bearer '.length);
    if (token.length <= 12) return 'Bearer ***';
    return 'Bearer ${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }

  String _maskBody(Object? body) {
    var s = body.toString();
    s = s.replaceAllMapped(
      _tokenFieldPattern,
      (m) => '"${m.group(1)}":"***"',
    );
    if (s.length > maxBodyLength) {
      s = '${s.substring(0, maxBodyLength)}... (truncated ${s.length - maxBodyLength} chars)';
    }
    return s;
  }
}
