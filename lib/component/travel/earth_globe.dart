import 'package:flutter/material.dart';
import 'package:traveling_app/component/travel/earthGlobe/travel_earth_globe_view.dart';
import 'package:traveling_app/service/travel_data.dart';

/// App-wide globe surface.
///
/// Every globe in the app is rendered by the same Flutter canvas
/// implementation used on the login screen, keeping visuals and gestures
/// consistent across platforms.
class TravelEarthGlobe extends StatelessWidget {
  final List<City> cities;
  final UserLocation userLocation;
  final void Function(City city)? onCityTap;
  final double? size;
  final double? width;
  final double? height;
  final bool gesturesEnabled;
  final bool autoRotate;
  final bool showLabels;
  final bool showBackground;
  final double minLatitude;
  final double maxLatitude;
  final double rotationSpeed;

  const TravelEarthGlobe({
    super.key,
    required this.cities,
    required this.userLocation,
    this.onCityTap,
    this.size,
    this.width,
    this.height,
    this.gesturesEnabled = true,
    this.autoRotate = true,
    this.showLabels = false,
    this.showBackground = false,
    this.minLatitude = -90,
    this.maxLatitude = 90,
    this.rotationSpeed = 0.04,
  });

  @override
  Widget build(BuildContext context) {
    return TravelEarthGlobeView(
      size: size ?? 400,
      width: width,
      height: height,
      backgroundSize: Size(width ?? size ?? 400, height ?? size ?? 400),
      globeAlignment: Alignment.center,
      cities: cities,
      userLocation: userLocation,
      onCityTap: onCityTap,
      gesturesEnabled: gesturesEnabled,
      autoRotate: autoRotate,
      rotationSpeed: rotationSpeed,
      showLabels: showLabels,
      showBackground: showBackground,
      minLatitude: minLatitude,
      maxLatitude: maxLatitude,
    );
  }
}
