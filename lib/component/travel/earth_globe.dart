import 'package:flutter/material.dart';
import 'package:traveling_app/component/travel/globe/unity_globe_container.dart';
import 'package:traveling_app/service/travel_data.dart';

export 'package:traveling_app/component/travel/globe/unity_globe_container.dart'
    show UnityGlobeCamera, defaultUnityGlobeConfig;

class TravelEarthGlobe extends StatelessWidget {
  final List<City> cities;
  final UserLocation userLocation;
  final String? userLabel;
  final void Function(City city)? onCityTap;
  final double? size;
  final double? width;
  final double? height;
  final bool fillParent;
  final bool useUnity;
  final UnityGlobeCamera? camera;

  /// 控制是否开启 Unity 侧地球自转。
  /// 会覆盖 config['autoRotateEnabled']。
  final bool autoRotate;

  /// 传给 Unity GlobeOverviewCamera 的配置。
  /// 不传时默认关闭手势、开启自转、速度为 1.6。
  final Map<String, Object?> config;

  const TravelEarthGlobe({
    super.key,
    required this.cities,
    required this.userLocation,
    this.userLabel,
    this.onCityTap,
    this.size,
    this.width,
    this.height,
    this.fillParent = false,
    this.useUnity = true,
    this.camera,
    this.autoRotate = true,
    this.config = defaultUnityGlobeConfig,
  });

  @override
  Widget build(BuildContext context) {
    return UnityGlobeContainer(
      size: size,
      width: width,
      height: height,
      fillParent: fillParent,
      userLabel: userLabel,
      cities: cities,
      userLocation: userLocation,
      onCityTap: onCityTap,
      useUnity: useUnity,
      camera: camera,
      autoRotate: autoRotate,
      config: config,
    );
  }
}
