import 'package:flutter/material.dart';
import 'package:tradingMt1/store/common/common_store.dart';
import 'package:tradingMt1/store/user/user_store.dart';

/// AppProviders
/// 这是一个类似 "中间件" 的聚合组件，用于统一管理和注入所有的 Store。
/// 它可以避免在 main.dart 中出现深层嵌套。
class AppProviders extends StatelessWidget {
  final Widget child;
  final CommonStore commonStore;
  final UserStore userStore;

  const AppProviders({
    super.key,
    required this.child,
    required this.commonStore,
    required this.userStore,
  });

  @override
  Widget build(BuildContext context) {
    // 每一个 Scope 负责注入一个 Store
    // 使用嵌套的方式将所有 Store 注入到 Widget 树中
    return CommonStoreScope(
      notifier: commonStore,
      child: UserStoreScope(notifier: userStore, child: child),
    );
  }
}
