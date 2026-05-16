import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/earth_globe.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _requestedLocation = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final cities = store.cities;

    if (!_requestedLocation && !store.hasRequestedLocation) {
      _requestedLocation = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        store.requestUserLocation();
      });
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(tokens: tokens, store: store),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.maxWidth.clamp(280.0, 360.0);
                        return Center(
                          child: TravelEarthGlobe(
                            size: size,
                            cities: cities,
                            userLocation: store.userLocation,
                            userLabel: store.userLocation.city,
                            camera: const UnityGlobeCamera(
                              longitude: 115,
                              latitude: 0,
                              height: 30000000,
                            ),
                            onCityTap: (city) {
                              context.push('/explore/city/${city.id}');
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 88,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: cities.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return _CityCard(city: city);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _BottomBar(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppCommon tokens;
  final TravelStore store;

  const _Header({required this.tokens, required this.store});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TravelLabel('YOUR ATLAS · 38 CITIES'),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: const TravelLabel('PROFILE →'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Where to next?',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 4),
          Text(
            _locationStatus(store),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }

  String _locationStatus(TravelStore store) {
    if (store.isLocating) {
      return 'Finding your location...';
    }
    if (store.locationError != null) {
      return 'Location unavailable · using saved map context';
    }
    return 'Current city · ${store.userLocation.city}';
  }
}

class _CityCard extends StatelessWidget {
  final City city;

  const _CityCard({required this.city});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return InkWell(
      onTap: () => context.push('/explore/city/${city.id}'),
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            TravelPlaceholderImage(
              seed: city.heroImageRef,
              width: 56,
              height: 56,
              radius: BorderRadius.circular(tokens.radiusMd),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    city.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TravelLabel('${city.poiCount} places · ${city.country}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.go('/itinerary'),
              icon: const Icon(Icons.calendar_month_outlined),
              label: const Text('Plan a Trip'),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(onPressed: () {}, child: const Text('Search')),
        ],
      ),
    );
  }
}
