import 'package:flutter/material.dart';
import 'package:tradingMt1/views/Home.dart';
import 'package:tradingMt1/views/Kline.dart';
import 'package:tradingMt1/views/Setting.dart';
import 'package:tradingMt1/views/DialogDemo.dart';
import 'package:tradingMt1/views/secondDetails/CurrencyDetails.dart';
import 'package:go_router/go_router.dart';

final List<Map<String, dynamic>> routers = [
  {
    'path': '/home',
    'name': 'Home',
    'builder': (context, state) => const Home(),
  },
  {
    'path': '/kline',
    'name': 'Kline',
    'builder': (context, state) => const Kline(),
  },
  {
    'path': '/settings',
    'name': 'Settings',
    'builder': (context, state) => const Setting(),
  },
  {
    'path': '/dialog-demo',
    'name': 'DialogDemo',
    'builder': (context, state) => const DialogDemo(),
  },
];

final List<Map<String, dynamic>> secondaryRoutes = [
  {
    'path': '/home/currencyDetails/:symbol',
    'name': 'currencyDetails',
    'key': 'symbol',
    'builder': (BuildContext context, GoRouterState state) {
      final symbol = state.pathParameters['symbol']!;
      return CurrencyDetails(symbol: symbol);
    },
  },
];

final List<Map<String, dynamic>> routes = routers.map((route) {
  return {
    'path': route['path'],
    'name': route['name'],
    'builder': route['builder'],
  };
}).toList();
