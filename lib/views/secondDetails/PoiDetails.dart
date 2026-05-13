import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class PoiDetails extends StatelessWidget {
  final String cityId;
  final String poiId;

  const PoiDetails({super.key, required this.cityId, required this.poiId});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final poi = store.poiById(poiId);

    if (poi == null) {
      return const Scaffold(body: Center(child: Text('Not found')));
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 320,
            backgroundColor: tokens.background,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/explore/city/$cityId');
                }
              },
            ),
            actions: [
              IconButton(
                icon: Icon(
                  store.profile.savedPoiIds.contains(poi.id)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                onPressed: () {
                  if (store.profile.savedPoiIds.contains(poi.id)) {
                    store.unsavePoi(poi.id);
                  } else {
                    store.savePoi(poi.id);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: TravelPlaceholderImage(
                seed: poi.coverImageRef,
                radius: BorderRadius.zero,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            sliver: SliverList.list(
              children: [
                TravelLabel(poi.category.toUpperCase()),
                const SizedBox(height: 8),
                Text(poi.name, style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    for (final time in poi.bestTimeOfDay)
                      TravelPill(text: time.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 24),
                const TravelSecondaryTitle('LOCAL TAKE'),
                const SizedBox(height: 16),
                TravelRatingBars(rating: poi.rating),
                const SizedBox(height: 24),
                const TravelSecondaryTitle('ABOUT'),
                const SizedBox(height: 12),
                Text(
                  poi.longDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            '/explore/city/$cityId/poi/${poi.id}/tips',
                          );
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text('Read ${poi.tipCount} Tips'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.push('/navigate/${poi.id}'),
                      child: const Text('Navigate'),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
