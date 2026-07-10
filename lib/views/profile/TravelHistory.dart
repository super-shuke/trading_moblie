import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class TravelHistoryView extends StatelessWidget {
  const TravelHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final records = TravelStoreScope.of(context).travelRecords;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GeoBackground(
        child: SafeArea(
          child: GeoContent(
            maxWidth: 760,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Back to profile',
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/profile'),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Travel history',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/profile/history/add'),
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('Add record'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: records.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.adjust,
                                  size: 40,
                                  color: tokens.brand,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No records yet — add your first trip memory.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: tokens.textMuted),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 32),
                          itemCount: records.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _RecordCard(record: records[index]),
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

class _RecordCard extends StatelessWidget {
  final TravelRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final isCountry = record.type == TravelRecordType.country;
    final meta = isCountry
        ? 'Country · ${DateFormat.yMMMd().format(record.date)}'
        : '${record.city} · ${record.category} · ${DateFormat.yMMMd().format(record.date)}';

    return GeoGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.brand.withValues(alpha: 0.12),
              border: Border.all(color: tokens.brand.withValues(alpha: 0.3)),
            ),
            child: Icon(
              isCountry ? Icons.public : Icons.location_on_outlined,
              size: 19,
              color: tokens.brand,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(meta, style: Theme.of(context).textTheme.bodySmall),
                if (record.comment.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    '“${record.comment}”',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textSecondary,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
