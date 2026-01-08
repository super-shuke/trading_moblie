import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tradingMt1/l10n/app_localizations.dart';
import 'package:tradingMt1/route/index.dart';
import 'package:tradingMt1/styles/theme/app_theme.dart';
import 'package:tradingMt1/store/common/common_store.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final CommonStore _commonStore = CommonStore(
    initialThemeMode: AppTheme.defaultThemeMode,
  );

  @override
  Widget build(BuildContext context) {
    return CommonStoreScope(
      notifier: _commonStore,
      child: AnimatedBuilder(
        animation: _commonStore,
        builder: (context, _) {
          return MaterialApp.router(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)!.appTitle,
            routerConfig: mainRouter,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _commonStore.themeMode,
            locale: _commonStore.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
