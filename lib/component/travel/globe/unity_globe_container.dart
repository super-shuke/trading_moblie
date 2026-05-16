import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

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
}

class UnityGlobeContainer extends StatefulWidget {
  final double size;
  final String? userLabel;
  final List<City> cities;
  final UserLocation userLocation;
  final void Function(City city)? onCityTap;
  final bool useUnity;
  final UnityGlobeCamera? camera;
  final bool autoRotate;
  final double autoRotateDegreesPerSecond;

  const UnityGlobeContainer({
    super.key,
    required this.size,
    required this.userLabel,
    required this.cities,
    required this.userLocation,
    required this.onCityTap,
    this.useUnity = true,
    this.camera,
    this.autoRotate = false,
    this.autoRotateDegreesPerSecond = 6,
  });

  @override
  State<UnityGlobeContainer> createState() => _UnityGlobeContainerState();
}

class _UnityGlobeContainerState extends State<UnityGlobeContainer> {
  static const _markerManagerObjectName = 'MarkerManager';
  static const _orbitControllerObjectName = 'OrbitGlobeController';
  static const _defaultCamera = UnityGlobeCamera(
    longitude: 115,
    latitude: 0,
    height: 30000000,
  );

  bool _unityReady = false;
  Timer? _autoRotateTimer;
  UnityGlobeCamera? _autoRotateCamera;

  @override
  void initState() {
    super.initState();
    _autoRotateCamera = widget.camera ?? _defaultCamera;
    _syncAutoRotateTimer();
  }

  @override
  void didUpdateWidget(UnityGlobeContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_unityReady &&
        (oldWidget.cities != widget.cities ||
            oldWidget.userLocation != widget.userLocation ||
            oldWidget.userLabel != widget.userLabel ||
            oldWidget.camera != widget.camera ||
            oldWidget.autoRotate != widget.autoRotate ||
            oldWidget.autoRotateDegreesPerSecond !=
                widget.autoRotateDegreesPerSecond)) {
      if (oldWidget.camera != widget.camera) {
        _autoRotateCamera = widget.camera ?? _defaultCamera;
      }
      _syncAutoRotateTimer();
      _sendUnityState();
    }
  }

  @override
  void dispose() {
    _autoRotateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final unitySupported =
        widget.useUnity &&
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF173A63),
                  const Color(0xFF0D1F35),
                  tokens.background,
                ],
                stops: const [0.0, 0.72, 1.0],
              ),
              border: Border.all(color: tokens.border.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF66B8FF).withValues(alpha: 0.18),
                  blurRadius: 44,
                  spreadRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: unitySupported
                ? IgnorePointer(
                    ignoring: widget.autoRotate,
                    child: EmbedUnity(onMessageFromUnity: _handleUnityMessage),
                  )
                : _FallbackGlobe(tokens: tokens, size: widget.size),
          ),
          if (widget.userLabel != null)
            Positioned(
              bottom: widget.size * 0.1,
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
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
    _sendGlobeState();
  }

  void _sendCameraState() {
    final camera = widget.autoRotate
        ? (_autoRotateCamera ?? widget.camera ?? _defaultCamera)
        : widget.camera;
    if (camera == null) {
      return;
    }

    sendToUnity(
      _orbitControllerObjectName,
      'SetCamera',
      jsonEncode(camera.toJson()),
    );
  }

  void _syncAutoRotateTimer() {
    _autoRotateTimer?.cancel();
    _autoRotateTimer = null;

    if (!widget.autoRotate || !widget.useUnity) {
      return;
    }

    const tick = Duration(milliseconds: 250);
    _autoRotateTimer = Timer.periodic(tick, (_) {
      if (!_unityReady) {
        return;
      }

      final current = _autoRotateCamera ?? widget.camera ?? _defaultCamera;
      final delta =
          widget.autoRotateDegreesPerSecond *
          tick.inMilliseconds /
          Duration.millisecondsPerSecond;
      _autoRotateCamera = current.copyWith(
        longitude: _normalizeLongitude(current.longitude + delta),
      );
      _sendCameraState();
    });
  }

  double _normalizeLongitude(double longitude) {
    var value = longitude;
    while (value > 180) {
      value -= 360;
    }
    while (value < -180) {
      value += 360;
    }
    return value;
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

class _FallbackGlobe extends StatelessWidget {
  final AppCommon tokens;
  final double size;

  const _FallbackGlobe({required this.tokens, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.public,
        size: size * 0.72,
        color: tokens.textMuted.withValues(alpha: 0.46),
      ),
    );
  }
}
