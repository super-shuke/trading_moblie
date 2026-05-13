import 'package:flutter/material.dart';
import 'package:traveling_app/component/travel/globe/unity_globe_container.dart';
import 'package:traveling_app/service/travel_data.dart';

class TravelEarthGlobe extends StatelessWidget {
  final List<City> cities;
  final LatLng userLocation;
  final String? userLabel;
  final void Function(City city)? onCityTap;
  final double size;

  const TravelEarthGlobe({
    super.key,
    required this.cities,
    required this.userLocation,
    this.userLabel,
    this.onCityTap,
    this.size = 320,
  });

  @override
  Widget build(BuildContext context) {
    return UnityGlobeContainer(
      size: size,
      userLabel: userLabel,
      cities: cities,
      userLocation: userLocation,
      onCityTap: onCityTap,
    );
  }
}
