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
class UserLocation {
  final String id;
  final String city;
  final String country;
  final LatLng coordinates;

  const UserLocation({
    required this.id,
    required this.city,
    required this.country,
    required this.coordinates,
  });

  @override
  bool operator ==(Object other) =>
      other is UserLocation &&
      other.id == id &&
      other.city == city &&
      other.country == country &&
      other.coordinates == coordinates;

  @override
  int get hashCode => Object.hash(id, city, country, coordinates);
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

@immutable
class LocalPlace {
  final String id;
  final String cityId;
  final String name;
  final String category;
  final LatLng location;
  final String shortDescription;
  final double rating;
  final int reviewCount;
  final String priceLevel;
  final List<String> tags;
  final String coverImageRef;

  const LocalPlace({
    required this.id,
    required this.cityId,
    required this.name,
    required this.category,
    required this.location,
    required this.shortDescription,
    required this.rating,
    required this.reviewCount,
    required this.priceLevel,
    required this.tags,
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

  static const shops = <LocalPlace>[
    LocalPlace(
      id: 'lisbon_shop_vida_portuguesa',
      cityId: 'lisbon',
      name: 'A Vida Portuguesa',
      category: 'shop',
      location: LatLng(38.7118, -9.1415),
      shortDescription:
          'Portuguese-made soaps, tins, notebooks, ceramics, and classic gifts.',
      rating: 4.7,
      reviewCount: 1840,
      priceLevel: r'$$',
      tags: ['gifts', 'design', 'local goods'],
      coverImageRef: 'shop_vida_portuguesa',
    ),
    LocalPlace(
      id: 'lisbon_shop_embaixada',
      cityId: 'lisbon',
      name: 'Embaixada',
      category: 'shop',
      location: LatLng(38.7167, -9.1479),
      shortDescription:
          'Independent fashion and lifestyle stores inside a neo-Moorish palace.',
      rating: 4.5,
      reviewCount: 920,
      priceLevel: r'$$$',
      tags: ['fashion', 'concept store', 'architecture'],
      coverImageRef: 'shop_embaixada',
    ),
    LocalPlace(
      id: 'tokyo_shop_beams_japan',
      cityId: 'tokyo',
      name: 'Beams Japan',
      category: 'shop',
      location: LatLng(35.6929, 139.7045),
      shortDescription:
          'Multi-floor edit of Japanese clothing, crafts, homeware, and souvenirs.',
      rating: 4.6,
      reviewCount: 2450,
      priceLevel: r'$$$',
      tags: ['fashion', 'craft', 'souvenirs'],
      coverImageRef: 'shop_beams_japan',
    ),
    LocalPlace(
      id: 'tokyo_shop_loft_shibuya',
      cityId: 'tokyo',
      name: 'Shibuya Loft',
      category: 'shop',
      location: LatLng(35.6602, 139.6995),
      shortDescription:
          'Stationery, beauty, kitchen tools, travel gear, and playful daily goods.',
      rating: 4.4,
      reviewCount: 5120,
      priceLevel: r'$$',
      tags: ['stationery', 'lifestyle', 'gifts'],
      coverImageRef: 'shop_shibuya_loft',
    ),
    LocalPlace(
      id: 'reykjavik_shop_kraum',
      cityId: 'reykjavik',
      name: 'Kraum',
      category: 'shop',
      location: LatLng(64.1477, -21.9399),
      shortDescription:
          'Icelandic design store with wool, ceramics, jewelry, and home objects.',
      rating: 4.5,
      reviewCount: 610,
      priceLevel: r'$$$',
      tags: ['icelandic design', 'wool', 'homeware'],
      coverImageRef: 'shop_kraum',
    ),
  ];

  static const restaurants = <LocalPlace>[
    LocalPlace(
      id: 'lisbon_restaurant_cervejaria_ramiro',
      cityId: 'lisbon',
      name: 'Cervejaria Ramiro',
      category: 'restaurant',
      location: LatLng(38.7201, -9.1351),
      shortDescription:
          'Classic seafood beer hall known for prawns, crab, clams, and steak sandwiches.',
      rating: 4.6,
      reviewCount: 15400,
      priceLevel: r'$$$',
      tags: ['seafood', 'classic', 'busy'],
      coverImageRef: 'restaurant_ramiro',
    ),
    LocalPlace(
      id: 'lisbon_restaurant_taberna_rua_flores',
      cityId: 'lisbon',
      name: 'Taberna da Rua das Flores',
      category: 'restaurant',
      location: LatLng(38.7095, -9.1458),
      shortDescription:
          'Small Portuguese tavern with a daily-changing blackboard menu.',
      rating: 4.5,
      reviewCount: 2600,
      priceLevel: r'$$',
      tags: ['portuguese', 'small plates', 'walk-in'],
      coverImageRef: 'restaurant_rua_flores',
    ),
    LocalPlace(
      id: 'tokyo_restaurant_tsuta',
      cityId: 'tokyo',
      name: 'Japanese Soba Noodles Tsuta',
      category: 'restaurant',
      location: LatLng(35.6695, 139.7064),
      shortDescription:
          'Refined ramen bowls with truffle aroma, clear broths, and precise noodles.',
      rating: 4.4,
      reviewCount: 3900,
      priceLevel: r'$$',
      tags: ['ramen', 'casual', 'noodles'],
      coverImageRef: 'restaurant_tsuta',
    ),
    LocalPlace(
      id: 'tokyo_restaurant_sushi_masuda',
      cityId: 'tokyo',
      name: 'Sushi Masuda',
      category: 'restaurant',
      location: LatLng(35.6656, 139.7161),
      shortDescription:
          'Omakase sushi counter focused on clean seasoning and careful rice temperature.',
      rating: 4.7,
      reviewCount: 980,
      priceLevel: r'$$$$',
      tags: ['sushi', 'omakase', 'reservation'],
      coverImageRef: 'restaurant_masuda',
    ),
    LocalPlace(
      id: 'reykjavik_restaurant_grillmarkadurinn',
      cityId: 'reykjavik',
      name: 'Grillmarkadurinn',
      category: 'restaurant',
      location: LatLng(64.1472, -21.9385),
      shortDescription:
          'Modern Icelandic grill with lamb, seafood, and a polished dining room.',
      rating: 4.6,
      reviewCount: 3400,
      priceLevel: r'$$$',
      tags: ['icelandic', 'grill', 'dinner'],
      coverImageRef: 'restaurant_grillmarkadurinn',
    ),
  ];

  static const bakeries = <LocalPlace>[
    LocalPlace(
      id: 'lisbon_bakery_manteigaria',
      cityId: 'lisbon',
      name: 'Manteigaria',
      category: 'bakery',
      location: LatLng(38.7085, -9.1434),
      shortDescription:
          'Warm pasteis de nata from an open bakery counter near Chiado.',
      rating: 4.8,
      reviewCount: 12600,
      priceLevel: r'$',
      tags: ['pastel de nata', 'quick stop', 'sweet'],
      coverImageRef: 'bakery_manteigaria',
    ),
    LocalPlace(
      id: 'lisbon_bakery_pao_pao_queijo_queijo',
      cityId: 'lisbon',
      name: 'Pao Pao Queijo Queijo',
      category: 'bakery',
      location: LatLng(38.6974, -9.2058),
      shortDescription:
          'Casual Belem stop for sandwiches, pastries, and fresh bread.',
      rating: 4.4,
      reviewCount: 2100,
      priceLevel: r'$',
      tags: ['bread', 'sandwiches', 'casual'],
      coverImageRef: 'bakery_pao_queijo',
    ),
    LocalPlace(
      id: 'tokyo_bakery_centre_the_bakery',
      cityId: 'tokyo',
      name: 'Centre The Bakery',
      category: 'bakery',
      location: LatLng(35.6722, 139.7668),
      shortDescription:
          'Ginza bakery known for soft shokupan and toast-focused cafe plates.',
      rating: 4.3,
      reviewCount: 2700,
      priceLevel: r'$$',
      tags: ['shokupan', 'toast', 'cafe'],
      coverImageRef: 'bakery_centre',
    ),
    LocalPlace(
      id: 'tokyo_bakery_kayaba',
      cityId: 'tokyo',
      name: 'Kayaba Bakery',
      category: 'bakery',
      location: LatLng(35.7214, 139.7705),
      shortDescription:
          'Neighborhood bakery near Yanaka with simple breads and morning pastries.',
      rating: 4.4,
      reviewCount: 880,
      priceLevel: r'$',
      tags: ['local', 'morning', 'bread'],
      coverImageRef: 'bakery_kayaba',
    ),
    LocalPlace(
      id: 'reykjavik_bakery_braud_co',
      cityId: 'reykjavik',
      name: 'Braud & Co',
      category: 'bakery',
      location: LatLng(64.1429, -21.9286),
      shortDescription:
          'Colorful bakery famous for cinnamon rolls, sourdough, and morning queues.',
      rating: 4.7,
      reviewCount: 4800,
      priceLevel: r'$$',
      tags: ['cinnamon rolls', 'sourdough', 'breakfast'],
      coverImageRef: 'bakery_braud_co',
    ),
  ];

  static List<LocalPlace> shopsForCity(String cityId) {
    return shops.where((place) => place.cityId == cityId).toList();
  }

  static List<LocalPlace> restaurantsForCity(String cityId) {
    return restaurants.where((place) => place.cityId == cityId).toList();
  }

  static List<LocalPlace> bakeriesForCity(String cityId) {
    return bakeries.where((place) => place.cityId == cityId).toList();
  }

  static List<LocalPlace> localPlacesForCity(String cityId) {
    return [
      ...shopsForCity(cityId),
      ...restaurantsForCity(cityId),
      ...bakeriesForCity(cityId),
    ];
  }

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
