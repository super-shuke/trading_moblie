import 'package:flutter/material.dart';
import 'package:tradingMt1/styles/theme/app_button.dart';

class CommonButtonStyle {
  CommonButtonStyle._();

  static ButtonStyle submitBtn(BuildContext context) {
    return Theme.of(context).extension<AppButtonStyles>()!.elevated;
  }

  static ButtonStyle textBtn(BuildContext context) {
    return Theme.of(context).extension<AppButtonStyles>()!.text;
  }

  static ButtonStyle outlineBtn(BuildContext context) {
    return Theme.of(context).extension<AppButtonStyles>()!.outlined;
  }
}
