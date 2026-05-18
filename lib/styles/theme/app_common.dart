import 'dart:ui';

import 'package:flutter/material.dart';

class AppCommon extends ThemeExtension<AppCommon> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color btnBackgroundPrimary;
  final Color btnTextPrimary;
  final Color textPrimarySameBtn;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color brand;
  final Color borderDefault;
  final Color accentAlt;
  final Color amber;
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
    required this.surfaceElevated,
    required this.textPrimary,
    required this.btnBackgroundPrimary,
    required this.btnTextPrimary,
    required this.textPrimarySameBtn,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.brand,
    required this.borderDefault,
    required this.accentAlt,
    required this.amber,
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
      background: Color(0xFFF7F1E7),
      surface: Color(0xFFFFFCF7),
      surfaceElevated: Color(0xFFF0E8DB),
      textPrimary: Color(0xFF1F241E),
      btnBackgroundPrimary: Color(0xFF7dd87d),
      btnTextPrimary: Color(0xFFF7F1E7),
      textSecondary: Color(0xFF485344),
      textMuted: Color(0xFF7B8276),
      textPrimarySameBtn: Color(0xFF7dd87d),
      border: Color(0xFFD8D0C0),
      borderDefault: Color(0xFFE8EFE6),
      brand: Color(0xFFe8efe6),
      accentAlt: Color(0xFFD9784A),
      amber: Color(0xFFE0A93B),
      priceUp: Color(0xFF7dd87d),
      priceDown: Color(0xFFC35642),
      radiusSm: 6,
      radiusMd: 10,
      radiusLg: 16,
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
      background: Color(0xFF0D1410),
      surface: Color(0xFF152019),
      surfaceElevated: Color(0xFF1B2922),
      textPrimary: Color(0xFFFFFFFF),
      btnBackgroundPrimary: Color(0xFF7dd87d),
      btnTextPrimary: Color(0xFF0D1410),
      textPrimarySameBtn: Color(0xFF7dd87d),
      textSecondary: Color(0xFFB3BBAF),
      textMuted: Color(0xFF8A9485),
      border: Color(0xFF2A3A30),
      borderDefault: Color(0xFFE8EFE6),

      brand: Color(0xFFe8efe6),
      accentAlt: Color(0xFFD9784A),
      amber: Color(0xFFE9B84A),
      priceUp: Color(0xFF7dd87d),
      priceDown: Color(0xFFD9544A),
      radiusSm: 6,
      radiusMd: 10,
      radiusLg: 16,
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
    Color? surfaceElevated,
    Color? textPrimary,
    Color? btnBackgroundPrimary,
    Color? btnTextPrimary,
    Color? textPrimarySameBtn,
    Color? textSecondary,
    Color? textMuted,
    Color? border,
    Color? brand,
    Color? borderDefault,
    Color? accentAlt,
    Color? amber,
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
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      btnBackgroundPrimary: btnBackgroundPrimary ?? this.btnBackgroundPrimary,
      btnTextPrimary: btnTextPrimary ?? this.btnTextPrimary,
      textPrimarySameBtn: textPrimarySameBtn ?? this.textPrimarySameBtn,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      brand: brand ?? this.brand,
      borderDefault: borderDefault ?? this.borderDefault,
      accentAlt: accentAlt ?? this.accentAlt,
      amber: amber ?? this.amber,
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
      surfaceElevated:
          Color.lerp(surfaceElevated, other.surfaceElevated, t) ??
          surfaceElevated,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textPrimarySameBtn:
          Color.lerp(textPrimarySameBtn, other.textPrimarySameBtn, t) ??
          textPrimarySameBtn,
      btnBackgroundPrimary:
          Color.lerp(btnBackgroundPrimary, other.btnBackgroundPrimary, t) ??
          btnBackgroundPrimary,
      btnTextPrimary:
          Color.lerp(btnTextPrimary, other.btnTextPrimary, t) ?? btnTextPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      border: Color.lerp(border, other.border, t) ?? border,
      borderDefault:
          Color.lerp(borderDefault, other.borderDefault, t) ?? borderDefault,
      brand: Color.lerp(brand, other.brand, t) ?? brand,
      accentAlt: Color.lerp(accentAlt, other.accentAlt, t) ?? accentAlt,
      amber: Color.lerp(amber, other.amber, t) ?? amber,
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
