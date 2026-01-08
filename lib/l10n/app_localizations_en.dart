// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'tradingMt1';

  @override
  String get homeTitle => 'Market';

  @override
  String get klineTitle => 'K-Line';

  @override
  String get currency => 'Currency';

  @override
  String get noData => 'No data';

  @override
  String get changeTheme => 'change Theme';
}
