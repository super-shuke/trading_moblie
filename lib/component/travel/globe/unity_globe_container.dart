import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:traveling_app/component/travel/earthGlobe/travel_earth_globe_view.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

const defaultUnityGlobeConfig = <String, Object>{
  'gesturesEnabled': false,
  'autoRotateEnabled': true,
  'autoRotateSpeed': 1.6,
};

class UnityGlobeCamera {
  final double longitude;
  final double latitude;
  final double height;

  const UnityGlobeCamera({
    required this.longitude,
    required this.latitude,
    required this.height,
  });

  Map<String, double> toJson() => {
    'lng': longitude,
    'lat': latitude,
    'height': height,
  };

  UnityGlobeCamera copyWith({
    double? longitude,
    double? latitude,
    double? height,
  }) {
    return UnityGlobeCamera(
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UnityGlobeCamera &&
            other.longitude == longitude &&
            other.latitude == latitude &&
            other.height == height;
  }

  @override
  int get hashCode => Object.hash(longitude, latitude, height);
}

class UnityGlobeContainer extends StatefulWidget {
  final double? size;
  final double? width;
  final double? height;
  final bool fillParent;
  final String? userLabel;
  final List<City> cities;
  final UserLocation userLocation;
  final void Function(City city)? onCityTap;
  final bool useUnity;
  final UnityGlobeCamera? camera;

  /// 控制是否开启 Unity 侧地球自转。
  /// 会覆盖 config['autoRotateEnabled']。
  final bool autoRotate;

  /// 传给 Unity GlobeOverviewCamera 的配置。
  /// 不传时默认关闭手势、开启自转、速度为 1.6。
  final Map<String, Object?> config;

  const UnityGlobeContainer({
    super.key,
    required this.userLabel,
    required this.cities,
    required this.userLocation,
    required this.onCityTap,
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
  State<UnityGlobeContainer> createState() => _UnityGlobeContainerState();
}

class _UnityGlobeContainerState extends State<UnityGlobeContainer> {
  static const _markerManagerObjectName = 'MarkerManager';
  static const _globeOverviewCameraObjectName = 'GlobeOverviewCamera';

  bool _unityReady = false;

  @override
  void didUpdateWidget(UnityGlobeContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cameraChanged = oldWidget.camera != widget.camera;
    final configChanged =
        oldWidget.autoRotate != widget.autoRotate ||
        !mapEquals(oldWidget.config, widget.config);
    final globeStateChanged =
        oldWidget.cities != widget.cities ||
        oldWidget.userLocation != widget.userLocation ||
        oldWidget.userLabel != widget.userLabel;

    if (!_unityReady) {
      return;
    }

    if (cameraChanged) {
      _sendCameraState();
    }
    if (configChanged) {
      _sendGlobeConfiguration();
    }
    if (globeStateChanged) {
      _sendGlobeState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final unitySupported =
        widget.useUnity &&
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = _resolveViewport(constraints);
        final markerBaseline = viewport.shortestSide;

        return SizedBox(
          width: viewport.width,
          height: viewport.height,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              unitySupported
                  ? ClipRect(
                      child: EmbedUnity(
                        onMessageFromUnity: _handleUnityMessage,
                      ),
                    )
                  : TravelEarthGlobeView(
                      size: markerBaseline,
                      cities: widget.cities,
                      userLocation: widget.userLocation,
                      onCityTap: widget.onCityTap,
                      autoRotate: widget.autoRotate,
                      rotationSpeed:
                          (_doubleConfigValue(
                                widget.config['autoRotateSpeed'],
                              ) ??
                              1.6) /
                          20,
                    ),
              if (widget.userLabel != null)
                Positioned(
                  bottom: markerBaseline * 0.1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.background.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF7AB8FF).withValues(alpha: 0.42),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Text(
                        widget.userLabel!,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: tokens.textPrimary),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Size _resolveViewport(BoxConstraints constraints) {
    const fallbackSize = 320.0;

    final fallbackWidth = widget.width ?? widget.size ?? fallbackSize;
    final fallbackHeight = widget.height ?? widget.size ?? fallbackSize;

    final width = _resolveAxis(
      explicitValue: widget.width,
      squareValue: widget.size,
      fallbackValue: fallbackWidth,
      maxConstraint: constraints.maxWidth,
      hasBoundedConstraint: constraints.hasBoundedWidth,
    );
    final height = _resolveAxis(
      explicitValue: widget.height,
      squareValue: widget.size,
      fallbackValue: fallbackHeight,
      maxConstraint: constraints.maxHeight,
      hasBoundedConstraint: constraints.hasBoundedHeight,
    );

    return Size(width, height);
  }

  double _resolveAxis({
    required double? explicitValue,
    required double? squareValue,
    required double fallbackValue,
    required double maxConstraint,
    required bool hasBoundedConstraint,
  }) {
    if (widget.fillParent && hasBoundedConstraint) {
      return maxConstraint;
    }

    if (explicitValue != null) {
      return explicitValue;
    }

    if (squareValue != null) {
      return squareValue;
    }

    if (hasBoundedConstraint) {
      return maxConstraint;
    }

    return fallbackValue;
  }

  void _handleUnityMessage(String message) {
    if (_isUnityReadyMessage(message)) {
      _unityReady = true;
      _sendUnityState();
      return;
    }

    final city = _cityFromUnityMessage(message);
    if (city != null) {
      widget.onCityTap?.call(city);
    }
  }

  bool _isUnityReadyMessage(String message) {
    if (message == 'scene_loaded' || message == 'globe_ready') {
      return true;
    }

    try {
      final decoded = jsonDecode(message);
      return decoded is Map<String, dynamic> &&
          (decoded['evt'] == 'ready' || decoded['type'] == 'ready');
    } on FormatException {
      return false;
    }
  }

  City? _cityFromUnityMessage(String message) {
    final prefixedCityId = message.startsWith('city:')
        ? message.substring('city:'.length)
        : null;

    if (prefixedCityId != null) {
      return _cityById(prefixedCityId);
    }

    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic> && decoded['type'] == 'cityTap') {
        final cityId = decoded['id'];
        if (cityId is String) {
          return _cityById(cityId);
        }
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  City? _cityById(String id) {
    for (final city in widget.cities) {
      if (city.id == id) {
        return city;
      }
    }
    return null;
  }

  void _sendUnityState() {
    _sendCameraState();
    _sendGlobeConfiguration();
    _sendGlobeState();
  }

  void _sendGlobeConfiguration() {
    final config = {...widget.config, 'autoRotateEnabled': widget.autoRotate};

    final gesturesEnabled = _boolConfigValue(config['gesturesEnabled']);
    if (gesturesEnabled != null) {
      sendToUnity(
        _globeOverviewCameraObjectName,
        'SetGesturesEnabled',
        gesturesEnabled.toString(),
      );
    }

    final autoRotateSpeed = _doubleConfigValue(config['autoRotateSpeed']);
    if (autoRotateSpeed != null) {
      sendToUnity(
        _globeOverviewCameraObjectName,
        'SetAutoRotateSpeed',
        autoRotateSpeed.toString(),
      );
    }

    final autoRotateEnabled = _boolConfigValue(config['autoRotateEnabled']);
    if (autoRotateEnabled != null) {
      sendToUnity(
        _globeOverviewCameraObjectName,
        'SetAutoRotateEnabled',
        autoRotateEnabled.toString(),
      );
    }
  }

  bool? _boolConfigValue(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      switch (value.trim().toLowerCase()) {
        case 'true':
        case '1':
        case 'on':
        case 'enable':
        case 'enabled':
          return true;
        case 'false':
        case '0':
        case 'off':
        case 'disable':
        case 'disabled':
          return false;
      }
    }
    return null;
  }

  double? _doubleConfigValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  void _sendCameraState() {
    final camera = widget.camera;
    if (camera == null) {
      return;
    }

    sendToUnity(
      _globeOverviewCameraObjectName,
      'SetCamera',
      jsonEncode(camera.toJson()),
    );
  }

  void _sendGlobeState() {
    sendToUnity(
      _markerManagerObjectName,
      'LoadPlacesFromJson',
      jsonEncode({
        'places': [
          {
            'id': widget.userLocation.id,
            'name': widget.userLocation.city,
            'country': widget.userLocation.country,
            'latitude': widget.userLocation.coordinates.lat,
            'longitude': widget.userLocation.coordinates.lon,
            'height': 1000,
            'kind': 'userLocation',
          },
          for (final city in widget.cities)
            {
              'id': city.id,
              'name': city.name,
              'latitude': city.location.lat,
              'longitude': city.location.lon,
              'height': 1000,
            },
        ],
      }),
    );
  }
}
