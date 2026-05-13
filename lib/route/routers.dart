import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/views/Itinerary.dart';
import 'package:traveling_app/views/Home.dart';
import 'package:traveling_app/views/Login/login_screen.dart';
import 'package:traveling_app/views/Profile.dart';
import 'package:traveling_app/views/secondDetails/CityDetails.dart';
import 'package:traveling_app/views/secondDetails/Navigation.dart';
import 'package:traveling_app/views/secondDetails/PoiDetails.dart';
import 'package:traveling_app/views/secondDetails/Tips.dart';

typedef RouteBuilder = Widget Function(BuildContext, GoRouterState);

// height Router used fade, other router used slide
enum PageTransition { fade, slideLeft, slideRight }

final List<Map<String, dynamic>> tabRoutes = [
  {
    'path': '/explore',
    'name': 'Explore',
    'icon': Icons.public_outlined,
    'builder': (BuildContext context, GoRouterState state) => const Home(),
  },
  {
    'path': '/itinerary',
    'name': 'Itinerary',
    'icon': Icons.route_outlined,
    'builder': (BuildContext context, GoRouterState state) =>
        const ItineraryView(),
  },
  {
    'path': '/profile',
    'name': 'Profile',
    'icon': Icons.person_outline,
    'builder': (BuildContext context, GoRouterState state) =>
        const ProfileView(),
  },
];

final List<Map<String, dynamic>> secondaryRoutes = [
  {
    'path': '/login',
    'name': 'login',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) =>
        const LoginScreen(),
  },
  {
    'path': '/explore/city/:cityId',
    'name': 'cityDetails',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) {
      final cityId = state.pathParameters['cityId']!;
      return CityDetails(cityId: cityId);
    },
  },
  {
    'path': '/explore/city/:cityId/poi/:poiId',
    'name': 'poiDetails',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) {
      final cityId = state.pathParameters['cityId']!;
      final poiId = state.pathParameters['poiId']!;
      return PoiDetails(cityId: cityId, poiId: poiId);
    },
  },
  {
    'path': '/explore/city/:cityId/poi/:poiId/tips',
    'name': 'tips',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) {
      final poiId = state.pathParameters['poiId']!;
      return TipsView(poiId: poiId);
    },
  },
  {
    'path': '/navigate/:poiId',
    'name': 'navigate',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) {
      final poiId = state.pathParameters['poiId']!;
      return NavigationView(poiId: poiId);
    },
  },
];
