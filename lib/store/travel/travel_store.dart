import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:traveling_app/service/travel_data.dart';

/// 旅行域状态容器。
///
/// 保持当前项目原有的 `ChangeNotifier + Scope` 架构，
/// 集中管理探索、详情、行程和个人页共享的数据。
class TravelStore extends ChangeNotifier {
  final List<City> _cities = TravelMockData.cities;
  LatLng _userLocation = const LatLng(22.3193, 114.1694);
  UserProfile _profile = TravelMockData.profile;
  Itinerary _itinerary = TravelMockData.defaultItinerary();
  bool _isLocating = false;
  bool _hasRequestedLocation = false;
  String? _locationError;

  List<City> get cities => _cities;
  LatLng get userLocation => _userLocation;
  UserProfile get profile => _profile;
  Itinerary get itinerary => _itinerary;
  bool get isLocating => _isLocating;
  bool get hasRequestedLocation => _hasRequestedLocation;
  String? get locationError => _locationError;
  City? get nearestCity {
    City? match;
    var distance = double.infinity;

    for (final city in _cities) {
      final currentDistance = Geolocator.distanceBetween(
        _userLocation.lat,
        _userLocation.lon,
        city.location.lat,
        city.location.lon,
      );
      print(currentDistance);
      print(distance);
      print(city.name);
      if (currentDistance < distance) {
        distance = currentDistance;
        match = city;
      }
    }

    return match;
  }

  /// 根据 id 获取城市详情。
  City? cityById(String id) {
    for (final city in _cities) {
      if (city.id == id) {
        return city;
      }
    }
    return null;
  }

  /// 返回某个城市下的全部 POI。
  List<Poi> poisForCity(String cityId) => TravelMockData.poisForCity(cityId);

  /// 根据 id 获取单个 POI。
  Poi? poiById(String id) => TravelMockData.poiById(id);

  /// 返回某个 POI 的用户 tips。
  List<Tip> tipsForPoi(String poiId) => TravelMockData.tipsForPoi(poiId);

  /// 请求系统定位权限并刷新当前坐标。
  Future<void> requestUserLocation() async {
    if (_isLocating || _hasRequestedLocation) {
      return;
    }

    _hasRequestedLocation = true;
    _isLocating = true;
    _locationError = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Location services are disabled.';
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _locationError = 'Location permission denied.';
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Location permission denied forever.';
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final pos = await Geolocator.getCurrentPosition();

      print('定位信息：${position}');
      print('当前定位信息：${pos.latitude},${pos.longitude}');
      final place = placemarks.first;

      print(place.locality); // 城市（如：Denpasar）
      print(place.subAdministrativeArea); // 区
      print(place.country); // 国家

      _userLocation = LatLng(position.latitude, position.longitude);
    } catch (error) {
      _locationError = error.toString();
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  /// 调整 itinerary 中 stop 的顺序。
  void reorderStop(int oldIndex, int newIndex) {
    final stops = [..._itinerary.stops];
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final stop = stops.removeAt(oldIndex);
    stops.insert(newIndex, stop);
    _itinerary = _itinerary.copyWith(stops: stops);
    notifyListeners();
  }

  /// 收藏一个 POI，并同步更新个人页 saved 列表。
  void savePoi(String poiId) {
    if (_profile.savedPoiIds.contains(poiId)) {
      return;
    }
    _profile = _profile.copyWith(savedPoiIds: [..._profile.savedPoiIds, poiId]);
    notifyListeners();
  }

  /// 取消收藏一个 POI。
  void unsavePoi(String poiId) {
    if (!_profile.savedPoiIds.contains(poiId)) {
      return;
    }
    _profile = _profile.copyWith(
      savedPoiIds: _profile.savedPoiIds.where((id) => id != poiId).toList(),
    );
    notifyListeners();
  }
}

/// TravelStore 的注入作用域，供现有 Widget 树按需读取状态。
class TravelStoreScope extends InheritedNotifier<TravelStore> {
  const TravelStoreScope({
    super.key,
    required TravelStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  static TravelStore of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<TravelStoreScope>();
    if (scope?.notifier == null) {
      throw StateError('TravelStoreScope not found in widget tree.');
    }
    return scope!.notifier!;
  }
}
