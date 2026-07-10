import 'package:flutter/material.dart';
import 'package:traveling_app/styles/theme/app_text.dart';
import 'package:traveling_app/styles/theme/app_common.dart';
import 'package:traveling_app/styles/theme/app_button.dart';

class AppTheme {
  AppTheme._();

  static ThemeMode defaultThemeMode = ThemeMode.system;

  static ThemeData light() {
    return _buildTheme(AppCommon.light(), Brightness.light);
  }

  static ThemeData dark() {
    return _buildTheme(AppCommon.dark(), Brightness.dark);
  }

  static ThemeData fromThemes(AppCommon themes, Brightness brightness) {
    return _buildTheme(themes, brightness);
  }

  static ThemeData _buildTheme(AppCommon themes, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: themes.brand,
      brightness: brightness,
      primary: themes.brand,
      secondary: themes.accentAlt,
      error: themes.priceDown,
      surface: themes.surface,
    );

    final buttons = buildAppButtonTheme(themes);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: buildAppTextTheme(themes),
      extensions: <ThemeExtension<dynamic>>[
        themes,
        AppButtonStyles.fromThemes(themes),
      ],
      elevatedButtonTheme: buttons.elevated,
      textButtonTheme: buttons.text,
      outlinedButtonTheme: buttons.outlined,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: themes.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: buildAppTextTheme(themes).titleLarge,
        iconTheme: IconThemeData(color: themes.textSecondary),
      ),
      iconTheme: IconThemeData(color: themes.textSecondary),
      dividerTheme: DividerThemeData(color: themes.border),
      listTileTheme: ListTileThemeData(
        iconColor: themes.textSecondary,
        textColor: themes.textPrimary,
      ),
      splashColor: colorScheme.primary.withValues(alpha: 0.08),
      highlightColor: colorScheme.primary.withValues(alpha: 0.06),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: themes.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: themes.textSecondary,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: themes.textSecondary),
        showUnselectedLabels: true,
      ),
    );
  }
}
