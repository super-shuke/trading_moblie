import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/route/routers.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  // 底部导航使用的路由壳。
  final StatefulNavigationShell navigationShell;
  // 传入路由壳用于页面切换。
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  // 切换底部导航页签。
  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 当前主题色。
    final colorScheme = Theme.of(context).colorScheme;
    // 业务扩展主题 token。
    final themes = Theme.of(context).extension<AppCommon>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navSurface = (themes?.surface ?? colorScheme.surface).withValues(
      alpha: isDark ? 0.62 : 0.76,
    );
    final navBorder = (themes?.border ?? colorScheme.outlineVariant).withValues(
      alpha: isDark ? 0.35 : 0.55,
    );

    return Scaffold(
      extendBody: true,
      // 路由壳作为页面主体。
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: navSurface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: navBorder),
                ),
                child: BottomNavigationBar(
                  // 当前选中页签索引。
                  currentIndex: widget.navigationShell.currentIndex,
                  // 选中状态颜色。
                  selectedItemColor: colorScheme.primary,
                  // 未选中图标颜色。
                  unselectedIconTheme: IconThemeData(
                    color: themes?.textSecondary,
                  ),
                  // 选中图标颜色。
                  selectedIconTheme: IconThemeData(color: colorScheme.primary),
                  // 容器样式由外层毛玻璃容器控制。
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  // 点击切换页签。
                  onTap: _onTap,
                  items: tabRoutes.asMap().entries.map((entry) {
                    Map<String, dynamic> route = entry.value;

                    return BottomNavigationBarItem(
                      // 页签图标。
                      icon: Icon(route['icon']),
                      // 选中页签图标
                      activeIcon: route['activeIcon'] != null
                          ? Icon(route['activeIcon'] as IconData)
                          : Icon(route['icon'] as IconData),
                      // 页签名称。
                      label: route['name'],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
