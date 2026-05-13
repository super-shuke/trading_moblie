import 'package:flutter/material.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class AppButtonTheme {
  final ElevatedButtonThemeData elevated;
  final TextButtonThemeData text;
  final OutlinedButtonThemeData outlined;

  const AppButtonTheme({
    required this.elevated,
    required this.text,
    required this.outlined,
  });
}

class AppButtonStyles extends ThemeExtension<AppButtonStyles> {
  final ButtonStyle elevated;
  final ButtonStyle text;
  final ButtonStyle outlined;

  const AppButtonStyles({
    required this.elevated,
    required this.text,
    required this.outlined,
  });

  factory AppButtonStyles.fromThemes(AppCommon themes) {
    return AppButtonStyles(
      elevated: buildAppElevatedButtonTheme(themes).style!,
      text: buildAppTextButtonTheme(themes).style!,
      outlined: buildAppOutlinedButtonTheme(themes).style!,
    );
  }

  @override
  AppButtonStyles copyWith({
    ButtonStyle? elevated,
    ButtonStyle? text,
    ButtonStyle? outlined,
  }) {
    return AppButtonStyles(
      elevated: elevated ?? this.elevated,
      text: text ?? this.text,
      outlined: outlined ?? this.outlined,
    );
  }

  @override
  AppButtonStyles lerp(ThemeExtension<AppButtonStyles>? other, double t) {
    if (other is! AppButtonStyles) {
      return this;
    }
    return AppButtonStyles(
      elevated: ButtonStyle.lerp(elevated, other.elevated, t) ?? elevated,
      text: ButtonStyle.lerp(text, other.text, t) ?? text,
      outlined: ButtonStyle.lerp(outlined, other.outlined, t) ?? outlined,
    );
  }
}

AppButtonTheme buildAppButtonTheme(AppCommon themes) {
  return AppButtonTheme(
    elevated: buildAppElevatedButtonTheme(themes),
    text: buildAppTextButtonTheme(themes),
    outlined: buildAppOutlinedButtonTheme(themes),
  );
}

ElevatedButtonThemeData buildAppElevatedButtonTheme(AppCommon themes) {
  return ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return themes.btnBackgroundPrimary.withValues(alpha: 0.4);
        }
        return themes.btnBackgroundPrimary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return themes.btnTextPrimary.withValues(alpha: 0.6);
        }
        return themes.btnTextPrimary;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return themes.btnBackgroundPrimary.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed)) {
          return themes.btnBackgroundPrimary.withValues(alpha: 0.2);
        }
        return null;
      }),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: themes.space16,
          vertical: themes.space12,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themes.radiusLg),
        ),
      ),
    ),
  );
}

TextButtonThemeData buildAppTextButtonTheme(AppCommon themes) {
  return TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return themes.brand.withValues(alpha: 0.5);
        }
        return themes.brand;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return themes.brand.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed)) {
          return themes.brand.withValues(alpha: 0.2);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: themes.borderDefault);
        }
        return BorderSide(color: themes.borderDefault);
      }),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: themes.space12,
          vertical: themes.space8,
        ),
      ),
    ),
  );
}

OutlinedButtonThemeData buildAppOutlinedButtonTheme(AppCommon themes) {
  return OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return themes.brand.withValues(alpha: 0.5);
        }
        return themes.brand;
      }),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return themes.brand.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed)) {
          return themes.brand.withValues(alpha: 0.2);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: themes.borderDefault.withValues(alpha: 0.5));
        }
        return BorderSide(color: themes.borderDefault);
      }),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: themes.space16,
          vertical: themes.space12,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themes.radiusLg),
        ),
      ),
    ),
  );
}
