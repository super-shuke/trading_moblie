import 'dart:ui';

import 'package:flutter/material.dart';

class AppCommon extends ThemeExtension<AppCommon> {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color btnBackgroundPrimary;
  final Color btnTextPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color brand;
  final Color priceUp;
  final Color priceDown;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  final double space2;
  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space24;
  final double space32;

  const AppCommon({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.btnBackgroundPrimary,
    required this.btnTextPrimary,

    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.brand,
    required this.priceUp,
    required this.priceDown,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.space2,
    required this.space4,
    required this.space8,
    required this.space12,
    required this.space16,
    required this.space24,
    required this.space32,
  });

  factory AppCommon.light() {
    return const AppCommon(
      background: Color(0xFFF6F7F9),
      surface: Color(0xFFFFFFFF),
      textPrimary: Color(0xFF111111),
      btnBackgroundPrimary: Color(0xFF1976D2),
      btnTextPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFF616161),
      textMuted: Color(0xFF8A8A8A),
      border: Color(0xFFE0E0E0),
      brand: Color(0xFF1976D2),
      priceUp: Color(0xFF1E88E5),
      priceDown: Color(0xFFD32F2F),
      radiusSm: 4,
      radiusMd: 8,
      radiusLg: 12,
      space2: 2,
      space4: 4,
      space8: 8,
      space12: 12,
      space16: 16,
      space24: 24,
      space32: 32,
    );
  }

  factory AppCommon.dark() {
    return const AppCommon(
      background: Color(0xFF0F1115),
      surface: Color(0xFF161A22),
      textPrimary: Color(0xFFF5F5F5),
      textSecondary: Color(0xFFB0B0B0),
      btnBackgroundPrimary: Color(0xFF90CAF9),
      btnTextPrimary: Color(0xFF000000),
      textMuted: Color(0xFF8A8A8A),
      border: Color(0xFF2A2F3A),
      brand: Color(0xFF90CAF9),
      priceUp: Color(0xFF64B5F6),
      priceDown: Color(0xFFEF5350),
      radiusSm: 4,
      radiusMd: 8,
      radiusLg: 12,
      space2: 2,
      space4: 4,
      space8: 8,
      space12: 12,
      space16: 16,
      space24: 24,
      space32: 32,
    );
  }

  @override
  AppCommon copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? btnBackgroundPrimary,
    Color? btnTextPrimary,

    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? brand,
    Color? priceUp,
    Color? priceDown,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? space2,
    double? space4,
    double? space8,
    double? space12,
    double? space16,
    double? space24,
    double? space32,
  }) {
    return AppCommon(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      btnBackgroundPrimary: btnBackgroundPrimary ?? this.btnBackgroundPrimary,
      btnTextPrimary: btnTextPrimary ?? this.btnTextPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      brand: brand ?? this.brand,
      priceUp: priceUp ?? this.priceUp,
      priceDown: priceDown ?? this.priceDown,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      space2: space2 ?? this.space2,
      space4: space4 ?? this.space4,
      space8: space8 ?? this.space8,
      space12: space12 ?? this.space12,
      space16: space16 ?? this.space16,
      space24: space24 ?? this.space24,
      space32: space32 ?? this.space32,
    );
  }

  @override
  AppCommon lerp(ThemeExtension<AppCommon>? other, double t) {
    if (other is! AppCommon) {
      return this;
    }
    return AppCommon(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      btnBackgroundPrimary:
          Color.lerp(btnBackgroundPrimary, other.btnBackgroundPrimary, t) ??
          btnBackgroundPrimary,
      btnTextPrimary:
          Color.lerp(btnTextPrimary, other.btnTextPrimary, t) ?? btnTextPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      border: Color.lerp(border, other.border, t) ?? border,
      brand: Color.lerp(brand, other.brand, t) ?? brand,
      priceUp: Color.lerp(priceUp, other.priceUp, t) ?? priceUp,
      priceDown: Color.lerp(priceDown, other.priceDown, t) ?? priceDown,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t) ?? radiusSm,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t) ?? radiusMd,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t) ?? radiusLg,
      space2: lerpDouble(space2, other.space2, t) ?? space2,
      space4: lerpDouble(space4, other.space4, t) ?? space4,
      space8: lerpDouble(space8, other.space8, t) ?? space8,
      space12: lerpDouble(space12, other.space12, t) ?? space12,
      space16: lerpDouble(space16, other.space16, t) ?? space16,
      space24: lerpDouble(space24, other.space24, t) ?? space24,
      space32: lerpDouble(space32, other.space32, t) ?? space32,
    );
  }
}
