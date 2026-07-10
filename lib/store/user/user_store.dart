import 'package:flutter/material.dart';

class UserStore extends ChangeNotifier {
  String _username = 'Explorer';
  String _email = '';
  String _bio = '';
  bool _isLoggedIn = false;

  String get username => _username;
  String get email => _email;
  String get bio => _bio;
  bool get isLoggedIn => _isLoggedIn;

  void login(String name, {String email = ''}) {
    _username = name;
    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  void updateProfile({required String name, String? email, String? bio}) {
    _username = name;
    if (email != null) _email = email;
    if (bio != null) _bio = bio;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _username = 'Guest';
    _email = '';
    _bio = '';
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
