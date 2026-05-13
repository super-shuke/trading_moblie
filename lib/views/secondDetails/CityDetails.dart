import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class CityDetails extends StatelessWidget {
  final String cityId;

  const CityDetails({super.key, required this.cityId});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final city = store.cityById(cityId);
    final pois = store.poisForCity(cityId);

    if (city == null) {
      return const Scaffold(body: Center(child: Text('City not found')));
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: tokens.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/explore');
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  TravelPlaceholderImage(
                    seed: city.heroImageRef,
                    radius: BorderRadius.zero,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          tokens.background.withValues(alpha: 0.4),
                          tokens.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            sliver: SliverList.list(
              children: [
                TravelLabel(city.country.toUpperCase()),
                const SizedBox(height: 8),
                Text(
                  city.name,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  city.tagline,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const TravelPill(text: 'BEST', icon: Icons.calendar_today),
                    for (final season in city.bestSeasons)
                      TravelPill(text: season),
                  ],
                ),
                const SizedBox(height: 24),
                const TravelSecondaryTitle('PLACES'),
                const SizedBox(height: 12),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList.separated(
              itemCount: pois.length,
              itemBuilder: (_, index) =>
                  _PoiTile(poiId: pois[index].id, cityId: cityId),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _PoiTile extends StatelessWidget {
  final String poiId;
  final String cityId;

  const _PoiTile({required this.poiId, required this.cityId});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final poi = store.poiById(poiId)!;

    return InkWell(
      onTap: () => context.push('/explore/city/$cityId/poi/${poi.id}'),
      borderRadius: BorderRadius.circular(tokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tokens.surface,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TravelPlaceholderImage(
              seed: poi.coverImageRef,
              width: 96,
              height: 96,
              radius: BorderRadius.circular(tokens.radiusMd),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TravelLabel(poi.category.toUpperCase()),
                  const SizedBox(height: 4),
                  Text(
                    poi.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    poi.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 12,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 4),
                      TravelLabel('${poi.tipCount} TIPS', size: 10),
                      const SizedBox(width: 12),
                      ...poi.bestTimeOfDay.map(
                        (time) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: TravelPill(text: time),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
