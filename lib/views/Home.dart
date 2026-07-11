import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/earthGlobe/travel_earth_globe_view.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
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
  bool _isGlobeInteracting = false;

  void _openSearch() => context.push('/search');

  void _handleGlobeInteractionChanged(bool isInteracting) {
    if (!mounted || _isGlobeInteracting == isInteracting) {
      return;
    }
    setState(() => _isGlobeInteracting = isInteracting);
  }

  @override
  Widget build(BuildContext context) {
    final store = TravelStoreScope.of(context);
    final recommendations = store.cities
        .expand((city) => store.poisForCity(city.id))
        .take(6)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GeoBackground(
        child: SafeArea(
          bottom: false,
          child: GeoContent(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _ExploreHeader(
                    store: store,
                    onSearch: _openSearch,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    physics: _isGlobeInteracting
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    children: [
                      _ExploreGlobe(
                        store: store,
                        onInteractionChanged: _handleGlobeInteractionChanged,
                      ),
                      const SizedBox(height: 22),
                      GeoSectionHeader(
                        title: 'Top destinations',
                        actionLabel: 'See all',
                        onAction: _openSearch,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 300,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: store.cities.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) => _DestinationCard(
                            city: store.cities[index],
                            rank: index + 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const GeoSectionHeader(title: 'Recommended for you'),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recommendations.length,
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 230,
                                  mainAxisExtent: 252,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemBuilder: (context, index) => _PlaceCard(
                              poi: recommendations[index],
                              tag: index == 0
                                  ? 'FOR YOU'
                                  : index == 1
                                  ? 'QUIET FIND'
                                  : 'LOCAL PICK',
                            ),
                          );
                        },
                      ),
                      if (recommendations.isEmpty)
                        const GeoGlassCard(
                          child: Text(
                            'Recommendations will appear as local collections are added.',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  final TravelStore store;
  final VoidCallback onSearch;

  const _ExploreHeader({required this.store, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            store.isLocating
                ? 'Finding your location…'
                : '${store.userLocation.city}, ${store.userLocation.country}',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: tokens.brand),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Explore',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search, size: 17),
                label: const Text('Search'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExploreGlobe extends StatelessWidget {
  final TravelStore store;
  final ValueChanged<bool> onInteractionChanged;

  const _ExploreGlobe({
    required this.store,
    required this.onInteractionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 400,
      child: Center(
        child: TravelEarthGlobeView(
          width: double.infinity,
          height: 400,
          globeAlignment: Alignment.center,
          sphereAlignment: Alignment.center,
          showBackground: true,
          cities: store.cities,
          userLocation: store.userLocation,
          autoRotate: true,
          rotationSpeed: 0.025,
          zoomEnabled: false,
          onInteractionChanged: onInteractionChanged,
          dayNightCycleEnabled: false,
          surfaceLightingEnabled: false,
          lightIntensity: 0,
          ambientLight: 1,
        ),
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final City city;
  final int rank;

  const _DestinationCard({required this.city, required this.rank});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return SizedBox(
      width: 292,
      child: GeoTapSurface(
        onTap: () => context.push('/explore/city/${city.id}'),
        semanticLabel: '${city.name}, ${city.country}',
        borderRadius: BorderRadius.circular(22),
        child: GeoGradientArt(
          seed: city.heroImageRef,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TravelPill(
                  text: rank == 1 ? 'TRENDING' : '#$rank',
                  fillColor: Colors.black.withValues(alpha: 0.18),
                  borderColor: Colors.white.withValues(alpha: 0.14),
                ),
                const Spacer(),
                TravelLabel(city.country, color: tokens.textSecondary),
                const SizedBox(height: 4),
                Text(
                  city.name,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${city.poiCount} places · ${city.tags.take(2).join(' · ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Poi poi;
  final String tag;

  const _PlaceCard({required this.poi, required this.tag});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final average =
        (poi.rating.atmosphere + poi.rating.photos + poi.rating.access) / 3;
    return GeoGlassCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/explore/city/${poi.cityId}/poi/${poi.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: 145,
            child: GeoGradientArt(
              seed: poi.coverImageRef,
              borderRadius: BorderRadius.zero,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: TravelPill(
                    text: tag,
                    fillColor: Colors.black.withValues(alpha: 0.18),
                    borderColor: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poi.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    poi.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      GeoRatingDots(value: average),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          average.toStringAsFixed(1),
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
