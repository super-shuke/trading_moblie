import 'package:flutter/material.dart';
import 'package:tradingMt1/styles/theme/app_common.dart';

class CommonTextStyle {
  CommonTextStyle._();

  // 标题样式
  static TextStyle title(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!;
  }

  // 副标题样式
  static TextStyle subtitle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!;
  }

  // 正文样式
  static TextStyle normal(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!;
  }

  // 小字体样式
  static TextStyle caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!;
  }

  // 小字体加粗样式
  static TextStyle captionBold(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!;
  }

  // 价格样式
  static TextStyle price(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!;
  }

  // 价格上涨样式
  static TextStyle priceUp(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Theme.of(
      context,
    ).textTheme.labelMedium!.copyWith(color: tokens.priceUp);
  }

  // 价格下跌样式
  static TextStyle priceDown(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Theme.of(
      context,
    ).textTheme.labelMedium!.copyWith(color: tokens.priceDown);
  }
}
