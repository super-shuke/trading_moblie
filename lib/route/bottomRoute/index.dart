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
    return Scaffold(
      // 路由壳作为页面主体。
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        // 当前选中页签索引。
        currentIndex: widget.navigationShell.currentIndex,
        // 选中状态颜色。
        selectedItemColor: colorScheme.primary,
        // 未选中图标颜色。
        unselectedIconTheme: IconThemeData(color: themes?.textSecondary),
        // 选中图标颜色。
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        // 底部栏背景色。
        backgroundColor: themes?.surface,
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
    );
  }
}
