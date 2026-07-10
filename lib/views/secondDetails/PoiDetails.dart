import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class PoiDetails extends StatefulWidget {
  final String cityId;
  final String poiId;

  const PoiDetails({super.key, required this.cityId, required this.poiId});

  @override
  State<PoiDetails> createState() => _PoiDetailsState();
}

class _PoiDetailsState extends State<PoiDetails> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final poi = store.poiById(widget.poiId);

    if (poi == null) {
      return const Scaffold(body: Center(child: Text('Place not found')));
    }

    final saved = store.profile.savedPoiIds.contains(poi.id);
    final inTrip = store.isPoiInItinerary(poi.id);
    final tips = store.tipsForPoi(poi.id);
    final nearby = store
        .poisForCity(widget.cityId)
        .where((item) => item.id != poi.id)
        .take(4)
        .toList();
    final average =
        (poi.rating.atmosphere + poi.rating.photos + poi.rating.access) / 3;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 350,
            backgroundColor: tokens.background.withValues(alpha: 0.9),
            leading: IconButton.filledTonal(
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.go('/explore/city/${widget.cityId}'),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
            actions: [
              IconButton.filledTonal(
                onPressed: () =>
                    saved ? store.unsavePoi(poi.id) : store.savePoi(poi.id),
                icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GeoGradientArt(
                seed: poi.coverImageRef,
                borderRadius: BorderRadius.zero,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        tokens.background.withValues(alpha: 0.08),
                        tokens.background,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              poi.name,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                GeoRatingDots(value: average),
                                const SizedBox(width: 8),
                                Text(
                                  '${average.toStringAsFixed(1)} · ${poi.tipCount} traveler notes',
                                  style: TextStyle(color: tokens.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '${poi.category} · ${poi.bestTimeOfDay.join(' · ')} · independent listing',
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
          SliverToBoxAdapter(
            child: GeoContent(
              maxWidth: 820,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 118),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GeoGlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'Best time',
                            value: poi.bestTimeOfDay.join(' / '),
                          ),
                          Divider(height: 1, color: tokens.border),
                          _InfoRow(
                            label: 'Atmosphere',
                            value:
                                '${poi.rating.atmosphere.toStringAsFixed(1)} / 5',
                          ),
                          Divider(height: 1, color: tokens.border),
                          _InfoRow(
                            label: 'Access',
                            value:
                                '${poi.rating.access.toStringAsFixed(1)} / 5',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      poi.longDescription,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    GeoGlassCard(
                      onTap: () => context.push('/navigate/${poi.id}'),
                      child: Row(
                        children: [
                          Icon(Icons.near_me_outlined, color: tokens.brand),
                          const SizedBox(width: 10),
                          const Expanded(child: Text('Navigate to this place')),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                    if (nearby.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      GeoGlassCard(
                        onTap: () =>
                            context.go('/explore/city/${widget.cityId}'),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: tokens.brand,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('Nearby places')),
                            Text(
                              '${nearby.length}  ›',
                              style: TextStyle(color: tokens.brand),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Traveler notes',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(
                            '/explore/city/${widget.cityId}/poi/${poi.id}/tips',
                          ),
                          style: TextButton.styleFrom(side: BorderSide.none),
                          child: Text('See all ${poi.tipCount}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (final tip in tips.take(2)) ...[
                      GeoGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip.authorName,
                              style: TextStyle(color: tokens.brand),
                            ),
                            const SizedBox(height: 7),
                            Text(tip.body),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Share a useful, non-promotional note',
                        filled: true,
                        fillColor: tokens.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: tokens.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.tonalIcon(
                        onPressed: () {
                          if (_noteController.text.trim().isEmpty) return;
                          _noteController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Your note is ready for review.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_outlined, size: 17),
                        label: const Text('Post note'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: inTrip
                ? () => context.go('/itinerary')
                : () {
                    store.addPoiToItinerary(poi.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${poi.name} added to ${store.itinerary.title}',
                        ),
                      ),
                    );
                  },
            child: Text(
              inTrip
                  ? 'View in ${store.itinerary.title}'
                  : 'Add to ${store.itinerary.title}',
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: tokens.textMuted)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}
