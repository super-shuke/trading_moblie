import 'package:flutter/material.dart';

class UserStore extends ChangeNotifier {
  String _username = 'Guest';
  bool _isLoggedIn = false;

  String get username => _username;
  bool get isLoggedIn => _isLoggedIn;

  void login(String name) {
    _username = name;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _username = 'Guest';
    _isLoggedIn = false;
    notifyListeners();
  }
}

class UserStoreScope extends InheritedNotifier<UserStore> {
  const UserStoreScope({
    super.key,
    required UserStore notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static UserStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<UserStoreScope>();
    if (scope == null) {
      throw StateError('UserStoreScope not found in widget tree.');
    }
    return scope.notifier!;
  }
}
