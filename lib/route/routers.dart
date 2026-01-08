import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tradingMt1/views/Home.dart';
import 'package:tradingMt1/views/Kline.dart';
import 'package:tradingMt1/views/Setting.dart';
import 'package:tradingMt1/views/secondDetails/CurrencyDetails.dart';

typedef RouteBuilder = Widget Function(BuildContext, GoRouterState);

// height Router used fade, other router used slide
enum PageTransition { fade, slideLeft, slideRight }

final List<Map<String, dynamic>> tabRoutes = [
  {
    'path': '/home',
    'name': 'Home',
    'icon': Icons.trending_up_outlined,
    'builder': (BuildContext context, GoRouterState state) => const Home(),
  },
  {
    'path': '/kline',
    'name': 'Kline',
    'icon': Icons.candlestick_chart_outlined,
    'builder': (BuildContext context, GoRouterState state) => const Kline(),
  },
  {
    'path': '/settings',
    'name': 'Settings',
    'icon': Icons.settings,
    'builder': (BuildContext context, GoRouterState state) => const Setting(),
  },
];

final List<Map<String, dynamic>> secondaryRoutes = [
  {
    'path': '/home/currencyDetails/:symbol',
    'name': 'currencyDetails',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) {
      final symbol = state.pathParameters['symbol']!;
      return CurrencyDetails(symbol: symbol);
    },
  },
];
