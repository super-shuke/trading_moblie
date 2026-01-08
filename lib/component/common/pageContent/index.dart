import 'package:flutter/material.dart';

/// 页面内容组件
///
/// 封装了 Scaffold，提供统一的页面布局结构
/// 支持安全距离处理，适配刘海屏、底部手势条等
class PageContent extends StatelessWidget {
  /// 顶部区域（AppBar）
  final PreferredSizeWidget? appBar;

  /// 主体区域
  final Widget body;

  /// 底部导航
  final Widget? bottomNavigation;

  /// 悬浮按钮
  final Widget? floatingActionButton;

  /// 页面名称（用于默认 AppBar 标题）
  final String? pageName;

  /// 是否启用安全距离（默认 true）
  final bool useSafeArea;

  /// 是否处理顶部安全距离（默认 true）
  final bool safeAreaTop;

  /// 是否处理底部安全距离（默认 true）
  final bool safeAreaBottom;

  /// 是否处理左侧安全距离（默认 true）
  final bool safeAreaLeft;

  /// 是否处理右侧安全距离（默认 true）
  final bool safeAreaRight;

  /// 背景色（默认使用主题背景色）
  final Color? backgroundColor;

  const PageContent({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigation,
    this.floatingActionButton,
    this.pageName,
    this.useSafeArea = true,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
    this.safeAreaLeft = true,
    this.safeAreaRight = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // 判断是否使用标准 AppBar
    final bool isStandardAppBar = appBar is AppBar;

    // 如果是标准 AppBar 或没有 appBar，使用 Scaffold 的 appBar 属性
    if (isStandardAppBar || appBar == null) {
      return _buildWithScaffoldAppBar(context, isStandardAppBar);
    }

    // 如果是自定义 appBar（如 PreferredSize），不使用 Scaffold 的 appBar
    // 而是把自定义头部和 body 放在一起处理
    return _buildWithCustomAppBar(context);
  }

  /// 使用 Scaffold 的 appBar 属性构建
  Widget _buildWithScaffoldAppBar(BuildContext context, bool isStandardAppBar) {
    Widget content = body;

    if (useSafeArea) {
      content = SafeArea(
        top: appBar == null && safeAreaTop,
        bottom: bottomNavigation == null && safeAreaBottom,
        left: safeAreaLeft,
        right: safeAreaRight,
        child: content,
      );
    }

    return Scaffold(
      appBar: appBar ?? AppBar(title: Text(pageName ?? 'Title')),
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: content,
      bottomNavigationBar: bottomNavigation,
      floatingActionButton: floatingActionButton,
    );
  }

  /// 使用自定义 appBar 构建（不使用 Scaffold 的 appBar 属性）
  Widget _buildWithCustomAppBar(BuildContext context) {
    // 获取 PreferredSize 的 child 和高度
    Widget headerWidget;
    double headerHeight;

    if (appBar is PreferredSize) {
      headerWidget = (appBar as PreferredSize).child;
      headerHeight = appBar!.preferredSize.height;
    } else {
      headerWidget = appBar!;
      headerHeight = appBar!.preferredSize.height;
    }

    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        top: useSafeArea && safeAreaTop,
        bottom: false, // 底部由 bottomNavigationBar 处理
        left: useSafeArea && safeAreaLeft,
        right: useSafeArea && safeAreaRight,
        child: Column(
          children: [
            // 自定义头部
            SizedBox(
              height: headerHeight,
              width: double.infinity,
              child: headerWidget,
            ),
            // 主体内容
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigation,
      floatingActionButton: floatingActionButton,
    );
  }
}
