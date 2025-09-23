import 'package:flutter/material.dart';

class PageContent extends StatelessWidget {
  final PreferredSizeWidget? appBar; // 顶部区域，相当于 slot:header
  final Widget body; // 主体区域，相当于 slot:default
  final Widget? bottomNavigation; // 底部导航，相当于 slot:footer
  final Widget? floatingActionButton;
  final String? pageName;

  const PageContent({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigation,
    this.floatingActionButton,
    this.pageName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? AppBar(title: Text(pageName ?? 'Tittle')),
      body: body,
      bottomNavigationBar: bottomNavigation,
      floatingActionButton: floatingActionButton,
    );
  }
}
