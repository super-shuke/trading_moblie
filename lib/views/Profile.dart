import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/earth_globe.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/store/user/user_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final travelStore = TravelStoreScope.of(context);
    final userStore = UserStoreScope.of(context);
    final profile = travelStore.profile;
    final cities = travelStore.cities;
    final visited = cities
        .where((city) => profile.visitedCityIds.contains(city.id))
        .toList();

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/explore'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
        children: [
          const TravelLabel('PROFILE'),
          const SizedBox(height: 8),
          Text(
            userStore.isLoggedIn ? userStore.username : profile.name,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 4),
          Text(
            userStore.isLoggedIn && userStore.email.isNotEmpty
                ? userStore.email
                : profile.email,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: tokens.textMuted),
          ),
          const SizedBox(height: 24),
          Center(
            child: TravelEarthGlobe(
              size: 240,
              cities: visited,
              userLocation: travelStore.userLocation,
              userLabel: null,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatBlock(
                  value: '${profile.countriesVisited}',
                  label: 'COUNTRIES',
                ),
              ),
              Expanded(
                child: _StatBlock(
                  value: '${profile.citiesVisited}',
                  label: 'CITIES',
                ),
              ),
              Expanded(
                child: _StatBlock(
                  value: '${profile.tipsContributed}',
                  label: 'TIPS',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const TravelSecondaryTitle('SAVED'),
          const SizedBox(height: 12),
          for (final poiId in profile.savedPoiIds)
            _SavedCard(poiId: poiId, store: travelStore),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;

  const _StatBlock({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 4),
        TravelLabel(label),
      ],
    );
  }
}

class _SavedCard extends StatelessWidget {
  final String poiId;
  final TravelStore store;

  const _SavedCard({required this.poiId, required this.store});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final poi = store.poiById(poiId);
    if (poi == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            TravelPlaceholderImage(
              seed: poi.coverImageRef,
              width: 48,
              height: 48,
              radius: BorderRadius.circular(tokens.radiusMd),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TravelLabel(poi.category.toUpperCase()),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark, size: 20),
              onPressed: () => store.unsavePoi(poi.id),
            ),
          ],
        ),
      ),
    );
  }
}
