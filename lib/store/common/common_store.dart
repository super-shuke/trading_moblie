import 'package:flutter/material.dart';

class CommonStore extends ChangeNotifier {
  CommonStore({
    ThemeMode initialThemeMode = ThemeMode.dark,
    Locale? initialLocale = const Locale('zh'),
  }) : _themeMode = initialThemeMode,
       _locale = initialLocale;

  ThemeMode _themeMode;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void toggleLightDark() {
    setThemeMode(
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setLocale(Locale? locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    if (_locale == null) return;
    _locale = null;
    notifyListeners();
  }
}

class CommonStoreScope extends InheritedNotifier<CommonStore> {
  const CommonStoreScope({
    super.key,
    required CommonStore notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static CommonStore of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<CommonStoreScope>();
    if (scope?.notifier == null) {
      throw StateError('CommonStoreScope not found in widget tree.');
    }
    return scope!.notifier!;
  }
}
