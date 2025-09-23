import 'package:flutter/material.dart';
import 'package:flutter_application_1/route/routers.dart';
import 'package:go_router/go_router.dart';

enum AnimationDirection { left, right }

CustomTransitionPage<T> buildPageWithAnimation<T>({
  required LocalKey key,
  required Widget child,
  AnimationDirection direction = AnimationDirection.right,
  Duration duration = const Duration(milliseconds: 200),
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      late Tween<Offset> tween;
      switch (direction) {
        case AnimationDirection.right:
          tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
          break;
        case AnimationDirection.left:
          tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
          break;
      }
      final curveAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      return SlideTransition(
        position: tween.animate(curveAnimation),
        child: FadeTransition(opacity: curveAnimation, child: child),
      );
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
              final direction = state.extra as AnimationDirection?;
              return buildPageWithAnimation(
                key: state.pageKey,
                child: route['builder']!(context, state),
                direction: direction ?? AnimationDirection.right,
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
      ),
    ),
  ],
);

class ScaffoldWithNavBar extends StatefulWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _selectedIndex = 0;

  void _onTap(int index) {
    final direction = (index > _selectedIndex)
        ? AnimationDirection.right
        : AnimationDirection.left;
    context.go(routes[index]['path'], extra: direction);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: routes.map((route) {
          return BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: route['name'],
          );
        }).toList(),
      ),
    );
  }
}
