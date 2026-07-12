import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:traveling_app/route/index.dart';
import 'package:traveling_app/service/network/dio_quest.dart';
import 'package:traveling_app/service/socket/mainSocket.dart';
import 'package:traveling_app/styles/theme/app_theme.dart';
import 'package:traveling_app/store/common/common_store.dart';
import 'package:traveling_app/store/user/user_store.dart';
import 'package:traveling_app/store/app_providers.dart';
import 'package:traveling_app/store/travel/travel_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Render the first frame immediately. Secure storage and local development
  // services can be slow or unavailable on first launch; waiting for them
  // before runApp leaves the native window completely blank.
  runApp(const MyApp());
  unawaited(_initializeServices());
}

Future<void> _initializeServices() async {
  try {
    await Api.main.init(baseUrl: 'http://localhost:3000/api/v1');
    await SocketApi.main.init(url: 'ws://localhost:3000/ws');

    // 可选：续期失败时跳登录页
    Api.main.onUnauthorized = () {
      SocketApi.main.disconnect();
      mainRouter.go('/login');
    };

    if (Api.main.isAuthenticated) {
      await SocketApi.main.connect();
    }
  } catch (error, stackTrace) {
    debugPrint('Service bootstrap failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 1. 在这里实例化所有的 Store，确保它们的生命周期跟 App 一样长

  final UserStore _userStore = UserStore();
  final TravelStore _travelStore = TravelStore();
  final CommonStore _commonStore = CommonStore();
  bool _didPrecacheGlobeAssets = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheGlobeAssets) {
      return;
    }
    _didPrecacheGlobeAssets = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _precacheGlobeAssets(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. 传给 AppProviders 进行注入
    return AppProviders(
      commonStore: _commonStore,
      userStore: _userStore,
      travelStore: _travelStore,
      child: AnimatedBuilder(
        animation: _commonStore, // 3. 只需要监听影响 MaterialApp 配置的 Store
        builder: (context, _) {
          return MaterialApp.router(
            onGenerateTitle: (context) => 'GeoTravel',
            routerConfig: mainRouter,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              scrollbars: false,
            ),
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _commonStore.themeMode,
            locale: _commonStore.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('zh')],
          );
        },
      ),
    );
  }

  void _precacheGlobeAssets(BuildContext context) {
    for (final asset in const [
      'assets/earth_globe/2k_stars.jpg',
      'assets/earth_globe/2k_earth-day.jpg',
      'assets/earth_globe/2k_earth-night.jpg',
    ]) {
      precacheImage(AssetImage(asset), context);
    }
  }
}
