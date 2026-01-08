import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tradingMt1/l10n/app_localizations.dart';
import 'package:tradingMt1/route/index.dart';
import 'package:tradingMt1/styles/theme/app_theme.dart';
import 'package:tradingMt1/store/common/common_store.dart';
import 'package:tradingMt1/store/user/user_store.dart';
import 'package:tradingMt1/store/app_providers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 1. 在这里实例化所有的 Store，确保它们的生命周期跟 App 一样长
  final CommonStore _commonStore = CommonStore(
    initialThemeMode: AppTheme.defaultThemeMode,
  );
  final UserStore _userStore = UserStore();

  @override
  Widget build(BuildContext context) {
    // 2. 传给 AppProviders 进行注入
    return AppProviders(
      commonStore: _commonStore,
      userStore: _userStore,
      child: AnimatedBuilder(
        animation: _commonStore, // 3. 只需要监听影响 MaterialApp 配置的 Store
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
