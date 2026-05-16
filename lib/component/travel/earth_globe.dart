import 'package:flutter/material.dart';
import 'package:traveling_app/component/travel/globe/unity_globe_container.dart';
import 'package:traveling_app/service/travel_data.dart';

export 'package:traveling_app/component/travel/globe/unity_globe_container.dart'
    show UnityGlobeCamera;

class TravelEarthGlobe extends StatelessWidget {
  final List<City> cities;
  final UserLocation userLocation;
  final String? userLabel;
  final void Function(City city)? onCityTap;
  final double size;
  final bool useUnity;
  final UnityGlobeCamera? camera;
  final bool autoRotate;
  final double autoRotateDegreesPerSecond;

  const TravelEarthGlobe({
    super.key,
    required this.cities,
    required this.userLocation,
    this.userLabel,
    this.onCityTap,
    this.size = 320,
    this.useUnity = true,
    this.camera,
    this.autoRotate = false,
    this.autoRotateDegreesPerSecond = 6,
  });

  @override
  Widget build(BuildContext context) {
    return UnityGlobeContainer(
      size: size,
      userLabel: userLabel,
      cities: cities,
      userLocation: userLocation,
      onCityTap: onCityTap,
      useUnity: useUnity,
      camera: camera,
      autoRotate: autoRotate,
      autoRotateDegreesPerSecond: autoRotateDegreesPerSecond,
    );
  }
}
