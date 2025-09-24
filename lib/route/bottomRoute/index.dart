import 'package:flutter/material.dart';
import 'package:tradingMt1/route/routers.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  int _selectedIndex = 0;

  void _onTap(int index) {
    context.go(routes[index]['path']);
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
        selectedItemColor: const Color.fromRGBO(25, 118, 210, 1),
        unselectedIconTheme: const IconThemeData(
          color: Color.fromRGBO(97, 97, 97, 1),
        ),
        selectedIconTheme: const IconThemeData(
          color: Color.fromRGBO(25, 118, 210, 1),
        ),
        backgroundColor: Colors.white,
        onTap: _onTap,
        items: routes.map((route) {
          return BottomNavigationBarItem(
            icon: Icon(route['icon']),
            label: route['name'],
          );
        }).toList(),
      ),
    );
  }
}
