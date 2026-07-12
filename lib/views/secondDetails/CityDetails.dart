import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class CityDetails extends StatefulWidget {
  final String cityId;

  const CityDetails({super.key, required this.cityId});

  @override
  State<CityDetails> createState() => _CityDetailsState();
}

class _CityDetailsState extends State<CityDetails> {
  String _category = 'All';
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final city = store.cityById(widget.cityId);
    final allPois = store.poisForCity(widget.cityId);
    final categories = <String>[
      'All',
      ...allPois.map((poi) => poi.category).toSet(),
    ];
    final pois = _category == 'All'
        ? allPois
        : allPois.where((poi) => poi.category == _category).toList();

    if (city == null) {
      return const Scaffold(body: Center(child: Text('City not found')));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          TravelDetailSliverAppBar(
            expandedHeight: 330,
            collapsedTitle: Text(city.name),
            leading: IconButton.filledTonal(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/explore'),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
            actions: [
              IconButton.filledTonal(
                onPressed: () => setState(() => _saved = !_saved),
                icon: Icon(_saved ? Icons.favorite : Icons.favorite_border),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GeoGradientArt(
                seed: city.heroImageRef,
                borderRadius: BorderRadius.zero,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        tokens.background.withValues(alpha: 0.12),
                        tokens.background,
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1120),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TravelLabel(city.country, color: tokens.brand),
                              const SizedBox(height: 5),
                              Text(
                                city.name,
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${city.poiCount} places · Best in ${city.bestSeasons.take(2).join('–')} · independent picks',
                                style: TextStyle(color: tokens.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: GeoContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ChoiceChip(
                          label: Text(
                            category == 'All'
                                ? category
                                : '${category[0].toUpperCase()}${category.substring(1)}',
                          ),
                          selected: category == _category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        );
                      },
                    ),
                  ),
                  GeoSectionHeader(
                    title: _category == 'All'
                        ? 'Top places'
                        : 'Best of $_category',
                    actionLabel: 'Map view',
                    onAction: () => context.go('/map'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.crossAxisExtent >= 820
                    ? 2
                    : 1;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 132,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _PoiTile(poi: pois[index], store: store),
                    childCount: pois.length,
                  ),
                );
              },
            ),
          ),
          if (pois.isEmpty)
            SliverToBoxAdapter(
              child: GeoContent(
                child: GeoGlassCard(
                  child: Text(
                    'This city collection is being built slowly with local notes, not paid placement.',
                    style: TextStyle(color: tokens.textMuted),
                  ),
                ),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: TravelPrimaryActionButton(
        onPressed: () => context.go('/itinerary'),
        icon: Icons.route_outlined,
        label: 'Plan a trip to ${city.name}',
        light: true,
      ),
    );
  }
}

class _PoiTile extends StatelessWidget {
  final Poi poi;
  final TravelStore store;

  const _PoiTile({required this.poi, required this.store});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final average =
        (poi.rating.atmosphere + poi.rating.photos + poi.rating.access) / 3;
    final added = store.isPoiInItinerary(poi.id);
    return GeoGlassCard(
      padding: const EdgeInsets.all(10),
      onTap: () => context.push('/explore/city/${poi.cityId}/poi/${poi.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 102, child: GeoGradientArt(seed: poi.coverImageRef)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  poi.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    GeoRatingDots(value: average),
                    const SizedBox(width: 6),
                    Text(
                      '${average.toStringAsFixed(1)} · ${poi.tipCount} notes',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${poi.category} · ${poi.bestTimeOfDay.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: 5),
                Text(
                  poi.shortDescription,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: added ? 'Already in trip' : 'Add to trip',
            onPressed: added
                ? null
                : () {
                    store.addPoiToItinerary(poi.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${poi.name} added to your trip')),
                    );
                  },
            icon: Icon(added ? Icons.check : Icons.add),
          ),
        ],
      ),
    );
  }
}
