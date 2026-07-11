import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/route/bottomRoute/index.dart';
import 'package:traveling_app/route/routers.dart';

// 根导航 key，用于需要覆盖底部栏的路由。
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

Widget _buildFadeTransition(
  // 进入页面动画。
  Animation<double> animation,
  // 退出页面动画。
  Animation<double> secondaryAnimation,
  // 页面内容。
  Widget child,
) {
  // 曲线动画
  final curve = CurvedAnimation(parent: animation, curve: Curves.easeIn);
  return FadeTransition(
    opacity: Tween(begin: 0.3, end: 1.0).animate(curve),
    child: FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.0).animate(secondaryAnimation),
      child: child,
    ),
  );
}

Widget _buildSlideTransition(
  // 进入页面动画。
  Animation<double> animation,
  // 退出页面动画。
  Animation<double> secondaryAnimation,
  // 页面内容。
  Widget child,
  // 滑动方向选择。
  PageTransition transition,
) {
  final inTween = Tween<Offset>(
    begin: transition == PageTransition.slideRight
        ? const Offset(1, 0)
        : const Offset(-1, 0),
    end: Offset.zero,
  ).animate(animation);

  final outTween = Tween<Offset>(
    begin: Offset.zero,
    end: transition == PageTransition.slideRight
        ? const Offset(-0.1, 0)
        : const Offset(1, 0),
  ).animate(secondaryAnimation);

  return SlideTransition(
    position: inTween,
    child: SlideTransition(position: outTween, child: child),
  );
}

CustomTransitionPage<T> buildPageWithAnimation<T>({
  // 页面 key，用于页面标识与转场作用域。
  required LocalKey key,
  // 页面内容。
  required Widget child,
  // 转场样式。
  PageTransition transition = PageTransition.slideRight,
  // 转场时长。
  Duration duration = const Duration(milliseconds: 200),
  // 是否由当前路由独立承载星空背景。
  bool includeBackground = true,
}) {
  return CustomTransitionPage(
    key: key,
    child: includeBackground ? GeoStarfieldBackground(child: child) : child,
    opaque: true,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (transition == PageTransition.fade) {
        return _buildFadeTransition(animation, secondaryAnimation, child);
      } else {
        return _buildSlideTransition(
          animation,
          secondaryAnimation,
          child,
          transition,
        );
      }
    },
  );
}

//-----------------------------------Router Config-----------------------------------//

final GoRouter mainRouter = GoRouter(
  // 应用初始路由。
  initialLocation: '/login',
  // 根导航 key，用于全屏路由跳转。
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    // 全部路由配置。
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return GeoStarfieldBackground(
          child: ScaffoldWithNavBar(navigationShell: navigationShell),
        );
      },
      branches: [
        ...tabRoutes.map(
          (route) => StatefulShellBranch(
            routes: [
              GoRoute(
                // Tab 路由路径。
                path: route['path'],
                // Tab 路由名称。
                name: route['name'],
                pageBuilder: (context, state) {
                  // Tab 页面构建器。
                  final builder = route['builder'];
                  return buildPageWithAnimation(
                    key: state.pageKey,
                    child: builder(context, state),
                    transition: PageTransition.fade,
                    includeBackground: false,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
    ...secondaryRoutes.map(
      (route) => GoRoute(
        // 次级路由路径。
        path: route['path'],
        // 次级路由名称。
        name: route['name'],
        // 覆盖底部栏时使用根导航。
        parentNavigatorKey: route['coverBottomBar'] == true
            ? _rootNavigatorKey
            : null,
        pageBuilder: (context, state) {
          // 允许通过 extra 覆盖转场方式。
          final transition = state.extra is PageTransition
              ? state.extra as PageTransition
              : null;
          // 次级页面构建器。
          final builder = route['builder'];
          return buildPageWithAnimation(
            key: state.pageKey,
            child: builder(context, state),
            transition: transition ?? PageTransition.slideRight,
          );
        },
      ),
    ),
  ],
);
