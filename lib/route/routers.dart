import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/views/Itinerary.dart';
import 'package:traveling_app/views/Home.dart';
import 'package:traveling_app/views/GlobeDemo.dart';
import 'package:traveling_app/views/Login/login_screen.dart';
import 'package:traveling_app/views/Profile.dart';
import 'package:traveling_app/views/Search.dart';
import 'package:traveling_app/views/TripMap.dart';
import 'package:traveling_app/views/profile/EditProfile.dart';
import 'package:traveling_app/views/profile/AddTravelRecord.dart';
import 'package:traveling_app/views/profile/TravelHistory.dart';
import 'package:traveling_app/views/trips/NewTrip.dart';
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
    'name': 'Trips',
    'icon': Icons.card_travel_outlined,
    'builder': (BuildContext context, GoRouterState state) =>
        const ItineraryView(),
  },
  {
    'path': '/map',
    'name': 'Map',
    'icon': Icons.map_outlined,
    'builder': (BuildContext context, GoRouterState state) =>
        const TripMapView(),
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
    'path': '/globe-demo',
    'name': 'globeDemo',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) => const GlobeDemo(),
  },
  {
    'path': '/login',
    'name': 'login',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) =>
        const LoginScreen(),
  },
  {
    'path': '/search',
    'name': 'search',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) =>
        const TravelSearchView(),
  },
  {
    'path': '/profile/edit',
    'name': 'editProfile',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) =>
        const EditProfileView(),
  },
  {
    'path': '/profile/history',
    'name': 'travelHistory',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) =>
        const TravelHistoryView(),
  },
  {
    'path': '/profile/history/add',
    'name': 'addTravelRecord',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) =>
        const AddTravelRecordView(),
  },
  {
    'path': '/itinerary/new',
    'name': 'newTrip',
    'coverBottomBar': true,
    'builder': (BuildContext context, GoRouterState state) =>
        const NewTripView(),
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
