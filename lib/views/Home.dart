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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/earth_globe/2k_stars.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(tokens: tokens, store: store),
                Expanded(child: _HomeGlobeStage(store: store)),
                _HomeHotLocation(list: cities),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeGlobeStage extends StatelessWidget {
  final TravelStore store;

  const _HomeGlobeStage({required this.store});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TravelEarthGlobe(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          cities: store.cities,
          userLocation: store.userLocation,
          useUnity: false,
          minLatitude: -75,
          maxLatitude: 75,
          autoRotate: true,
          config: const {
            'gesturesEnabled': true,
            'autoRotateEnabled': true,
            'autoRotateSpeed': 1,
          },
          camera: const UnityGlobeCamera(
            longitude: 0,
            latitude: 0,
            height: 18000000,
          ),
        );
      },
    );
  }
}

class _HomeHotLocation extends StatelessWidget {
  final List<City> list;

  const _HomeHotLocation({required this.list});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TravelLabel('HOT LOCATIONS'),
              GestureDetector(
                onTap: () => context.push('/explore'),
                child: const TravelLabel('SEE ALL →'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _CityCard(city: list[index]),
            ),
          ),
        ],
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
        width: 130,
        height: 140,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        child: Column(
          children: [
            TravelPlaceholderImage(
              seed: city.heroImageRef,
              width: double.infinity,
              height: 76,
              radius: BorderRadius.zero,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(color: tokens.surface),
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${city.name}, ${city.country}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 8,
                        color: tokens.textMuted,
                      ),
                    ),
                    Text(
                      city.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
