// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'tradingMt1';

  @override
  String get homeTitle => '行情';

  @override
  String get klineTitle => 'K线图';

  @override
  String get currency => '币种';

  @override
  String get noData => '暂无数据';

  @override
  String get changeTheme => '修改主题';
}
