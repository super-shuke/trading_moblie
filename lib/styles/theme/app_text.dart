import 'package:flutter/material.dart';
import 'package:tradingMt1/styles/theme/app_common.dart';

TextTheme buildAppTextTheme(AppCommon themes) {
  return TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: themes.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: themes.textSecondary,
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.15,
      color: themes.textPrimary,
    ),
    bodySmall: TextStyle(fontSize: 10, color: themes.textMuted),
    labelMedium: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: themes.textPrimary,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: themes.textSecondary,
    ),
  );
}
