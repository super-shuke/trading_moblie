import 'package:flutter/foundation.dart';

@immutable
class LatLng {
  final double lat;
  final double lon;

  const LatLng(this.lat, this.lon);

  @override
  bool operator ==(Object other) =>
      other is LatLng && other.lat == lat && other.lon == lon;

  @override
  int get hashCode => Object.hash(lat, lon);
}

@immutable
class MultiRating {
  final double atmosphere;
  final double photos;
  final double crowds;
  final double access;

  const MultiRating({
    required this.atmosphere,
    required this.photos,
    required this.crowds,
    required this.access,
  });
}

@immutable
class City {
  final String id;
  final String name;
  final String country;
  final LatLng location;
  final String tagline;
  final List<String> bestSeasons;
  final String heroImageRef;
  final int poiCount;
  final List<String> tags;

  const City({
    required this.id,
    required this.name,
    required this.country,
    required this.location,
    required this.tagline,
    required this.bestSeasons,
    required this.heroImageRef,
    required this.poiCount,
    required this.tags,
  });
}

@immutable
class Poi {
  final String id;
  final String cityId;
  final String name;
  final String category;
  final LatLng location;
  final String shortDescription;
  final String longDescription;
  final MultiRating rating;
  final int tipCount;
  final List<String> bestTimeOfDay;
  final String coverImageRef;

  const Poi({
    required this.id,
    required this.cityId,
    required this.name,
    required this.category,
    required this.location,
    required this.shortDescription,
    required this.longDescription,
    required this.rating,
    required this.tipCount,
    required this.bestTimeOfDay,
    required this.coverImageRef,
  });
}

enum TipKind { positive, neutral, avoid }

@immutable
class Tip {
  final String id;
  final String poiId;
  final String authorName;
  final TipKind kind;
  final String body;
  final DateTime createdAt;
  final int likes;

  const Tip({
    required this.id,
    required this.poiId,
    required this.authorName,
    required this.kind,
    required this.body,
    required this.createdAt,
    required this.likes,
  });
}

@immutable
class ItineraryStop {
  final String id;
  final String poiId;
  final DateTime arriveAt;
  final Duration dwell;
  final String? note;

  const ItineraryStop({
    required this.id,
    required this.poiId,
    required this.arriveAt,
    required this.dwell,
    this.note,
  });
}

@immutable
class Itinerary {
  final String id;
  final String cityId;
  final String title;
  final DateTime date;
  final List<ItineraryStop> stops;

  const Itinerary({
    required this.id,
    required this.cityId,
    required this.title,
    required this.date,
    required this.stops,
  });

  Itinerary copyWith({String? title, List<ItineraryStop>? stops}) {
    return Itinerary(
      id: id,
      cityId: cityId,
      title: title ?? this.title,
      date: date,
      stops: stops ?? this.stops,
    );
  }
}

@immutable
class UserProfile {
  final String name;
  final String email;
  final List<String> visitedCityIds;
  final List<String> savedPoiIds;
  final int countriesVisited;
  final int citiesVisited;
  final int tipsContributed;

  const UserProfile({
    required this.name,
    required this.email,
    required this.visitedCityIds,
    required this.savedPoiIds,
    required this.countriesVisited,
    required this.citiesVisited,
    required this.tipsContributed,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    List<String>? visitedCityIds,
    List<String>? savedPoiIds,
    int? countriesVisited,
    int? citiesVisited,
    int? tipsContributed,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      visitedCityIds: visitedCityIds ?? this.visitedCityIds,
      savedPoiIds: savedPoiIds ?? this.savedPoiIds,
      countriesVisited: countriesVisited ?? this.countriesVisited,
      citiesVisited: citiesVisited ?? this.citiesVisited,
      tipsContributed: tipsContributed ?? this.tipsContributed,
    );
  }
}

class TravelMockData {
  static const cities = <City>[
    City(
      id: 'lisbon',
      name: 'Lisbon',
      country: 'Portugal',
      location: LatLng(38.7223, -9.1393),
      tagline: 'Light, tile, and the ocean at the edge of Europe.',
      bestSeasons: ['Apr', 'May', 'Sep', 'Oct'],
      heroImageRef: 'lisbon_hero',
      poiCount: 47,
      tags: ['coastal', 'historic', 'walkable', 'sunsets'],
    ),
    City(
      id: 'tokyo',
      name: 'Tokyo',
      country: 'Japan',
      location: LatLng(35.6762, 139.6503),
      tagline: 'Density, neon, and quiet backstreets in the same block.',
      bestSeasons: ['Mar', 'Apr', 'Oct', 'Nov'],
      heroImageRef: 'tokyo_hero',
      poiCount: 89,
      tags: ['mega-city', 'food', 'design', 'nightlife'],
    ),
    City(
      id: 'reykjavik',
      name: 'Reykjavik',
      country: 'Iceland',
      location: LatLng(64.1466, -21.9426),
      tagline: 'A compact capital with volcanic edges and long light.',
      bestSeasons: ['Jun', 'Jul', 'Aug'],
      heroImageRef: 'reykjavik_hero',
      poiCount: 23,
      tags: ['nordic', 'aurora', 'volcanic', 'small'],
    ),
  ];

  static const _pois = <Poi>[
    Poi(
      id: 'miradouro_senhora_monte',
      cityId: 'lisbon',
      name: 'Miradouro da Senhora do Monte',
      category: 'viewpoint',
      location: LatLng(38.7195, -9.1306),
      shortDescription: 'The highest natural viewpoint in the city.',
      longDescription:
          'A terraced garden behind a chapel looking west over the old town. '
          'Locals come here with wine at dusk and the atmosphere is the point.',
      rating: MultiRating(
        atmosphere: 4.9,
        photos: 4.7,
        crowds: 2.4,
        access: 4.2,
      ),
      tipCount: 142,
      bestTimeOfDay: ['sunset'],
      coverImageRef: 'monte',
    ),
    Poi(
      id: 'time_out_market',
      cityId: 'lisbon',
      name: 'Time Out Market',
      category: 'food',
      location: LatLng(38.7065, -9.1454),
      shortDescription: 'Curated food hall in a 19th-century market.',
      longDescription:
          'A food hall where the citys top chefs have stalls. Great range, but '
          'it is crowded, so go off-hours if you want a calmer meal.',
      rating: MultiRating(
        atmosphere: 3.8,
        photos: 3.5,
        crowds: 4.6,
        access: 4.0,
      ),
      tipCount: 318,
      bestTimeOfDay: ['lunch', 'late night'],
      coverImageRef: 'timeout',
    ),
    Poi(
      id: 'lx_factory',
      cityId: 'lisbon',
      name: 'LX Factory',
      category: 'neighborhood',
      location: LatLng(38.7036, -9.1788),
      shortDescription: 'An industrial block turned creative quarter.',
      longDescription:
          'Bookstores, design studios, restaurants, and a Sunday market. '
          'Weekday mornings are calm and Saturday nights are packed.',
      rating: MultiRating(
        atmosphere: 4.5,
        photos: 4.6,
        crowds: 3.8,
        access: 4.5,
      ),
      tipCount: 201,
      bestTimeOfDay: ['afternoon', 'evening'],
      coverImageRef: 'lx',
    ),
    Poi(
      id: 'castelo_sao_jorge',
      cityId: 'lisbon',
      name: 'Castelo de Sao Jorge',
      category: 'historic',
      location: LatLng(38.7139, -9.1335),
      shortDescription: 'An 11th-century hilltop castle over the city.',
      longDescription:
          'The walls and the view are the highlight. First entry of the day is '
          'the only time it feels quiet.',
      rating: MultiRating(
        atmosphere: 4.2,
        photos: 4.7,
        crowds: 4.3,
        access: 3.5,
      ),
      tipCount: 287,
      bestTimeOfDay: ['morning'],
      coverImageRef: 'castelo',
    ),
  ];

  static List<Poi> poisForCity(String cityId) {
    return _pois.where((poi) => poi.cityId == cityId).toList();
  }

  static Poi? poiById(String id) {
    for (final poi in _pois) {
      if (poi.id == id) {
        return poi;
      }
    }
    return null;
  }

  static List<Tip> tipsForPoi(String poiId) {
    final base = DateTime(2025, 4, 12);
    switch (poiId) {
      case 'miradouro_senhora_monte':
        return [
          Tip(
            id: 't1',
            poiId: poiId,
            authorName: 'Marta',
            kind: TipKind.positive,
            body:
                'Bring a blanket. The stone benches get cold once the sun is down.',
            createdAt: base.subtract(const Duration(days: 4)),
            likes: 87,
          ),
          Tip(
            id: 't2',
            poiId: poiId,
            authorName: 'Diogo',
            kind: TipKind.avoid,
            body:
                'Do not take a car up here on Friday evening. Walk the last part.',
            createdAt: base.subtract(const Duration(days: 9)),
            likes: 134,
          ),
        ];
      default:
        return [
          Tip(
            id: 't_$poiId',
            poiId: poiId,
            authorName: 'Local guide',
            kind: TipKind.neutral,
            body: 'Tips coming soon. Be the first to share one.',
            createdAt: base,
            likes: 0,
          ),
        ];
    }
  }

  static Itinerary defaultItinerary() {
    return Itinerary(
      id: 'lisbon_day_1',
      cityId: 'lisbon',
      title: 'Lisbon, Day 1',
      date: DateTime(2025, 5, 14),
      stops: [
        ItineraryStop(
          id: 's1',
          poiId: 'castelo_sao_jorge',
          arriveAt: DateTime(2025, 5, 14, 9, 30),
          dwell: Duration(minutes: 90),
          note: 'Go early for the quietest view.',
        ),
        ItineraryStop(
          id: 's2',
          poiId: 'time_out_market',
          arriveAt: DateTime(2025, 5, 14, 12, 30),
          dwell: Duration(minutes: 75),
        ),
        ItineraryStop(
          id: 's3',
          poiId: 'lx_factory',
          arriveAt: DateTime(2025, 5, 14, 15, 30),
          dwell: Duration(hours: 2),
        ),
        ItineraryStop(
          id: 's4',
          poiId: 'miradouro_senhora_monte',
          arriveAt: DateTime(2025, 5, 14, 19, 15),
          dwell: Duration(minutes: 60),
          note: 'Sunset stop.',
        ),
      ],
    );
  }

  static const profile = UserProfile(
    name: 'Aviv K.',
    email: 'aviv@geotravel.app',
    visitedCityIds: ['lisbon', 'tokyo', 'reykjavik'],
    savedPoiIds: ['miradouro_senhora_monte', 'lx_factory'],
    countriesVisited: 14,
    citiesVisited: 38,
    tipsContributed: 22,
  );
}
