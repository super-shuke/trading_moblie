import 'package:flutter/material.dart';

class CommonTextStyle {
  CommonTextStyle._();

  // 标题样式
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );

  // 副标题样式
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color.fromRGBO(97, 97, 97, 1),
  );

  // 正文样式
  static const TextStyle normal = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    color: Colors.black87,
  );

  // 小字体样式
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    color: Color.fromRGBO(84, 84, 84, 1),
  );

  // 小字体加粗样式
  static const TextStyle captionBold = TextStyle(
    fontSize: 10,
    color: Color.fromRGBO(89, 89, 89, 1),
    fontWeight: FontWeight.w500,
  );

  // 价格样式
  static const TextStyle price = TextStyle(
    fontSize: 10,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );

  // 价格上涨样式
  static const TextStyle priceUp = TextStyle(
    fontSize: 10,
    color: Color.fromRGBO(25, 118, 210, 1),
    fontWeight: FontWeight.w500,
  );

  // 价格下跌样式
  static const TextStyle priceDown = TextStyle(
    fontSize: 10,
    color: Color.fromRGBO(211, 47, 47, 1),
    fontWeight: FontWeight.w500,
  );
}
