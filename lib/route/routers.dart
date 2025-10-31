import 'package:flutter/material.dart';
import 'package:tradingMt1/views/Home.dart';
import 'package:tradingMt1/views/Kline.dart';
import 'package:tradingMt1/views/Setting.dart';
import 'package:tradingMt1/views/DialogDemo.dart';
import 'package:tradingMt1/views/SimpleDialogExample.dart';
import 'package:tradingMt1/views/TradingConfirmExample.dart';
import 'package:tradingMt1/views/DialogExamplesHub.dart';
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
    'path': '/examples-hub',
    'name': 'ExamplesHub',
    'builder': (context, state) => const DialogExamplesHub(),
  },
  {
    'path': '/dialog-demo',
    'name': 'DialogDemo',
    'builder': (context, state) => const DialogDemo(),
  },
  {
    'path': '/simple-dialog',
    'name': 'SimpleDialog',
    'builder': (context, state) => const SimpleDialogExample(),
  },
  {
    'path': '/trading-confirm',
    'name': 'TradingConfirm',
    'builder': (context, state) => const TradingConfirmExample(),
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
