import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class ItineraryView extends StatelessWidget {
  const ItineraryView({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final itinerary = store.itinerary;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        backgroundColor: tokens.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TravelLabel(
                  DateFormat(
                    'EEE · MMM d',
                  ).format(itinerary.date).toUpperCase(),
                ),
                const SizedBox(height: 8),
                Text(
                  itinerary.title,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag to reorder · ${itinerary.stops.length} stops',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              itemCount: itinerary.stops.length,
              onReorder: store.reorderStop,
              itemBuilder: (_, index) {
                final stop = itinerary.stops[index];
                final poi = store.poiById(stop.poiId);
                return _StopCard(
                  key: ValueKey(stop.id),
                  index: index,
                  title: poi?.name ?? stop.poiId,
                  time: DateFormat('HH:mm').format(stop.arriveAt),
                  note: stop.note,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  final int index;
  final String title;
  final String time;
  final String? note;

  const _StopCard({
    super.key,
    required this.index,
    required this.title,
    required this.time,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TravelLabel(time),
                  const SizedBox(height: 2),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (note != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      note!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.drag_handle, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}
