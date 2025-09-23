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
