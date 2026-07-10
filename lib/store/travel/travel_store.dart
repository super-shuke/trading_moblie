import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:traveling_app/service/travel_data.dart';

enum TravelRecordType { country, place }

class TravelRecord {
  final String id;
  final TravelRecordType type;
  final String title;
  final String city;
  final String category;
  final DateTime date;
  final String comment;

  const TravelRecord({
    required this.id,
    required this.type,
    required this.title,
    this.city = '',
    this.category = '',
    required this.date,
    this.comment = '',
  });
}

class PlannedTrip {
  final String id;
  final String name;
  final String country;
  final String city;
  final DateTime? startDate;
  final DateTime? endDate;
  final int travelers;

  const PlannedTrip({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    this.startDate,
    this.endDate,
    required this.travelers,
  });
}

/// 旅行域状态容器。
///
/// 保持当前项目原有的 `ChangeNotifier + Scope` 架构，
/// 集中管理探索、详情、行程和个人页共享的数据。
class TravelStore extends ChangeNotifier {
  final List<City> _cities = TravelMockData.cities;
  UserLocation _userLocation = const UserLocation(
    id: 'current_location',
    city: 'Hong Kong',
    country: 'Hong Kong',
    coordinates: LatLng(22.3193, 114.1694),
  );
  UserProfile _profile = TravelMockData.profile;
  Itinerary _itinerary = TravelMockData.defaultItinerary();
  final Set<String> _completedStopIds = <String>{};
  final List<TravelRecord> _travelRecords = <TravelRecord>[];
  final List<PlannedTrip> _plannedTrips = <PlannedTrip>[];
  bool _isLocating = false;
  bool _hasRequestedLocation = false;
  String? _locationError;

  List<City> get cities => _cities;
  UserLocation get userLocation => _userLocation;
  UserProfile get profile => _profile;
  Itinerary get itinerary => _itinerary;
  Set<String> get completedStopIds => Set.unmodifiable(_completedStopIds);
  List<TravelRecord> get travelRecords => List.unmodifiable(_travelRecords);
  List<PlannedTrip> get plannedTrips => List.unmodifiable(_plannedTrips);
  bool get isLocating => _isLocating;
  bool get hasRequestedLocation => _hasRequestedLocation;
  String? get locationError => _locationError;
  City? get nearestCity {
    City? match;
    var distance = double.infinity;

    for (final city in _cities) {
      final currentDistance = Geolocator.distanceBetween(
        _userLocation.coordinates.lat,
        _userLocation.coordinates.lon,
        city.location.lat,
        city.location.lon,
      );
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
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      _userLocation = _locationFromPosition(
        position,
        placemarks.isEmpty ? null : placemarks.first,
      );
    } catch (error) {
      _locationError = error.toString();
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  UserLocation _locationFromPosition(Position position, Placemark? place) {
    final cityName = _firstNonEmpty([
      place?.locality,
      place?.subAdministrativeArea,
      place?.administrativeArea,
    ]);
    final country = _firstNonEmpty([place?.country, place?.isoCountryCode]);

    return UserLocation(
      id: 'current_${_slug(cityName ?? 'location')}',
      city: cityName ?? 'Current Location',
      country: country ?? 'Unknown',
      coordinates: LatLng(position.latitude, position.longitude),
    );
  }

  String? _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  String _slug(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return normalized.isEmpty ? 'location' : normalized;
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

  bool isStopCompleted(String stopId) => _completedStopIds.contains(stopId);

  void toggleStopCompleted(String stopId) {
    if (!_completedStopIds.add(stopId)) {
      _completedStopIds.remove(stopId);
    }
    notifyListeners();
  }

  bool isPoiInItinerary(String poiId) =>
      _itinerary.stops.any((stop) => stop.poiId == poiId);

  /// Adds a discovery to the current journey at the next sensible time.
  void addPoiToItinerary(String poiId) {
    if (isPoiInItinerary(poiId)) return;
    final previous = _itinerary.stops.isEmpty ? null : _itinerary.stops.last;
    final arriveAt = previous == null
        ? DateTime(
            _itinerary.date.year,
            _itinerary.date.month,
            _itinerary.date.day,
            9,
          )
        : previous.arriveAt.add(previous.dwell + const Duration(minutes: 45));
    final stop = ItineraryStop(
      id: 's_${DateTime.now().microsecondsSinceEpoch}',
      poiId: poiId,
      arriveAt: arriveAt,
      dwell: const Duration(minutes: 75),
      note: 'Added from Explore.',
    );
    _itinerary = _itinerary.copyWith(stops: [..._itinerary.stops, stop]);
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

  void addTravelRecord(TravelRecord record) {
    _travelRecords.insert(0, record);
    notifyListeners();
  }

  void addPlannedTrip(PlannedTrip trip) {
    _plannedTrips.insert(0, trip);
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
