// UnauthorizedInterceptor —— 401 兜底拦截器
//
// 职责：
//   当 AuthInterceptor 尝试 refresh token 也失败、错误最终透传到这里时，
//   触发"用户必须重新登录"的副作用（典型实现：清空本地 token + 跳登录页）。
//
// 位置：必须在拦截器链中位于 AuthInterceptor 之后添加，
//      这样 401 错误先经过 AuthInterceptor 尝试续期，
//      续期失败才会到达这里。
//
// 设计要点：
//   - 通过回调注入副作用，本拦截器不依赖具体的路由/状态管理库；
//   - 不吞掉错误，仍然透传给业务方，让 UI 也能做对应反应（如显示 Toast）；
//   - 用一个简单的"节流"避免短时间内多个并发 401 各自触发一次跳登录。

import 'dart:async';

import 'package:dio/dio.dart';

/// 当 refresh 也失败时触发的副作用回调。
/// 典型实现：清空本地 token + 跳登录页。
typedef UnauthorizedHandler = FutureOr<void> Function();

class UnauthorizedInterceptor extends Interceptor {
  UnauthorizedInterceptor({
    required this.onUnauthorized,
    this.cooldown = const Duration(seconds: 2),
  });

  final UnauthorizedHandler onUnauthorized;

  /// 节流窗口：在窗口内重复 401 只触发一次回调
  final Duration cooldown;

  DateTime? _lastFiredAt;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final now = DateTime.now();
      final last = _lastFiredAt;
      if (last == null || now.difference(last) > cooldown) {
        _lastFiredAt = now;
        // 异步触发，不阻塞错误传递
        Future(() => onUnauthorized());
      }
    }
    // 继续把错误传给业务方（UI 层可能想 Toast）
    handler.next(err);
  }
}
