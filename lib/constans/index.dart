// 将第三方交易数据对象映射到我们的 'trades' 表 schema
import '../utils/format.dart';

Map<String, dynamic> mapThirdPartyTrade(Map<String, dynamic> thirdPartyTrade) {
  // thirdPartyTrade 中的字段可能是字符串；我们保证以字符串解析为 Decimal 或 double
  double parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String && v.isNotEmpty) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  double price = parseDouble(thirdPartyTrade['p']);
  double quantity = parseDouble(thirdPartyTrade['q']);
  double quoteQuantity = price * quantity;

  return {
    'symbol': thirdPartyTrade['s'],
    'price': thirdPartyTrade['p'],
    'qty': thirdPartyTrade['q'],
    'quoteQty': quoteQuantity.toString(),
    'isBuyerMaker': thirdPartyTrade['m'],
    'time': DateTime.fromMillisecondsSinceEpoch(thirdPartyTrade['T']),
    'isRPITrade': false,
  };
}
// 将第三方 ticker 数据对象映射到我们的 'trickers' 表 schema

Map<String, dynamic> mapThirdPartyTicker(Map<String, dynamic> t) {
  return {
    'symbol': t['s'],
    'priceChange': t['p'],
    'priceChangePercent': FormatUtils.formatCount(
      t['P'],
      decimals: 2,
      ratio: true,
    ),
    'weightedAvgPrice': t['w'],
    'lastPrice': t['c'],
    'buy': t['b'],
    'sell': t['a'],
    'buyCount': t['B'],
    'sellCount': t['A'],
    'lastQty': t['Q'],
    'openPrice': t['o'],
    'highPrice': t['h'],
    'lowPrice': t['l'],
    'volume': t['v'],
    'quoteVolume': t['q'],
    'openTime': FormatUtils.formatTimestamp(t['O']),
    'closeTime': FormatUtils.formatTimestamp(t['C']),
    'firstId': t['F'],
    'lastId': t['L'],
    'count': t['n'],
  };
}
