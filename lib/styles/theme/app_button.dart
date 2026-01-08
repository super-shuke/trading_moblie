import 'package:flutter/material.dart';
import 'package:tradingMt1/styles/theme/app_common.dart';

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
      backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.disabled)) {
          return themes.btnBackgroundPrimary.withOpacity(0.4);
        }
        return themes.btnBackgroundPrimary;
      }),
      foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.disabled)) {
          return themes.btnTextPrimary.withOpacity(0.6);
        }
        return themes.btnTextPrimary;
      }),
      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.hovered)) {
          return themes.btnBackgroundPrimary.withOpacity(0.12);
        }
        if (states.contains(MaterialState.focused) ||
            states.contains(MaterialState.pressed)) {
          return themes.btnBackgroundPrimary.withOpacity(0.2);
        }
        return null;
      }),
      padding: MaterialStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: themes.space16,
          vertical: themes.space12,
        ),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themes.radiusMd),
        ),
      ),
    ),
  );
}

TextButtonThemeData buildAppTextButtonTheme(AppCommon themes) {
  return TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.disabled)) {
          return themes.brand.withOpacity(0.5);
        }
        return themes.brand;
      }),
      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.hovered)) {
          return themes.brand.withOpacity(0.12);
        }
        if (states.contains(MaterialState.focused) ||
            states.contains(MaterialState.pressed)) {
          return themes.brand.withOpacity(0.2);
        }
        return null;
      }),
      padding: MaterialStateProperty.all(
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
      foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.disabled)) {
          return themes.brand.withOpacity(0.5);
        }
        return themes.brand;
      }),
      overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
        if (states.contains(MaterialState.hovered)) {
          return themes.brand.withOpacity(0.12);
        }
        if (states.contains(MaterialState.focused) ||
            states.contains(MaterialState.pressed)) {
          return themes.brand.withOpacity(0.2);
        }
        return null;
      }),
      side: MaterialStateProperty.resolveWith<BorderSide?>((states) {
        if (states.contains(MaterialState.disabled)) {
          return BorderSide(color: themes.border);
        }
        return BorderSide(color: themes.brand);
      }),
      padding: MaterialStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: themes.space16,
          vertical: themes.space12,
        ),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themes.radiusMd),
        ),
      ),
    ),
  );
}
