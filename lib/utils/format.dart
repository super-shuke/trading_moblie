import 'package:decimal/decimal.dart';

class FormatUtils {
  FormatUtils._();

  // 计算价格涨跌百分比
  String _formatPrice(String lastPrice, String openPrice) {
    if (lastPrice.isEmpty || openPrice.isEmpty) return '0.00%';
    try {
      final price = Decimal.parse(lastPrice);
      final open = Decimal.parse(openPrice);

      // 先得到 Rational，再转回 Decimal
      final ratio = ((price - open) / open).toDecimal() * Decimal.fromInt(100);

      return '${ratio.truncate(scale: 2)}%';
    } catch (e) {
      return '0.00%';
    }
  }

  /// 判断价格涨跌
  static bool isPriceUp(dynamic lastPrice, dynamic openPrice) {
    try {
      double last = double.parse(lastPrice.toString());
      double open = double.parse(openPrice.toString());
      return last >= open;
    } catch (e) {
      return false;
    }
  }

  /// 格式化参数，保留指定小数位
  static String formatCount(
    dynamic count, {
    int decimals = 2,
    bool? ratio = false,
  }) {
    try {
      Decimal p = Decimal.parse(count.toString());
      return p.truncate(scale: decimals).toString() +
          (ratio == true ? '%' : '');
    } catch (e) {
      return '0.${'0' * decimals}';
    }
  }

  // 格式化时间戳为时分秒
  static String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime dateTime;
    if (timestamp is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      dateTime = DateTime.parse(timestamp);
    } else {
      return '';
    }

    // 手动格式化时分秒
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');

    return '$hour:$minute:$second';
  }
}
