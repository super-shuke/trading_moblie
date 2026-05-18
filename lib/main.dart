import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:traveling_app/component/travel/globe/unity_preloader.dart';
import 'package:traveling_app/route/index.dart';
import 'package:traveling_app/service/network/dio_quest.dart';
import 'package:traveling_app/service/socket/mainSocket.dart';
import 'package:traveling_app/styles/theme/app_theme.dart';
import 'package:traveling_app/store/common/common_store.dart';
import 'package:traveling_app/store/user/user_store.dart';
import 'package:traveling_app/store/app_providers.dart';
import 'package:traveling_app/store/travel/travel_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.main.init(baseUrl: 'http://localhost:3000/api/v1');

  await SocketApi.main.init(url: 'ws://localhost:3000/ws');

  // 预加载字体，避免运行时卡顿
  // await GoogleFonts.pendingFonts([
  //   GoogleFonts.fraunces(),
  //   GoogleFonts.fraunces(fontWeight: FontWeight.w700),
  // ]);

  // 可选：续期失败时跳登录页
  Api.main.onUnauthorized = () {
    SocketApi.main.disconnect();
    mainRouter.go('/login');
  };

  if (Api.main.isAuthenticated) {
    await SocketApi.main.connect();
  }

  runApp(const MyApp());
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
            builder: (context, child) {
              return Stack(
                children: [if (child != null) child, const UnityPreloader()],
              );
            },
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
}
