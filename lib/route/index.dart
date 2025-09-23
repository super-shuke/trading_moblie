import 'package:flutter/material.dart';
import 'package:tradingMt1/route/bottomRoute/index.dart';
import 'package:tradingMt1/route/routers.dart';
import 'package:go_router/go_router.dart';

// height Router used fade, other router used slide
enum PageTransition { fade, slideLeft, slideRight }

Widget _buildFadeTransition(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
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
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
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
  required LocalKey key,
  required Widget child,
  PageTransition transition = PageTransition.slideRight,
  Duration duration = const Duration(milliseconds: 200),
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: duration,
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

final GoRouter mainRouter = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        ...routes.map((route) {
          return GoRoute(
            path: route['path'],
            name: route['name'],
            pageBuilder: (context, state) {
              return buildPageWithAnimation(
                key: state.pageKey,
                child: route['builder']!(context, state),
                transition: PageTransition.fade,
              );
            },
          );
        }).toList(),
      ],
    ),
    ...secondaryRoutes.map(
      (route) => GoRoute(
        path: route['path'],
        name: route['name'],
        builder: route['builder'],
        pageBuilder: (context, state) {
          final transition = state.extra as PageTransition?;
          return buildPageWithAnimation(
            key: state.pageKey,
            child: route['builder']!(context, state),
            transition: transition ?? PageTransition.slideRight,
          );
        },
      ),
    ),
  ],
);
