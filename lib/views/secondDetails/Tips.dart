import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traveling_app/component/common/pageContent/index.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class TipsView extends StatefulWidget {
  final String poiId;

  const TipsView({super.key, required this.poiId});

  @override
  State<TipsView> createState() => _TipsViewState();
}

class _TipsViewState extends State<TipsView> {
  TipKind? _filter;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final tips = TravelStoreScope.of(context).tipsForPoi(widget.poiId);
    final filtered = _filter == null
        ? tips
        : tips.where((tip) => tip.kind == _filter).toList();

    return PageContent(
      appBar: AppBar(title: const Text('Tips')),
      body: Container(
        color: tokens.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterPill(
                    label: 'All',
                    active: _filter == null,
                    onTap: () => setState(() => _filter = null),
                  ),
                  _FilterPill(
                    label: 'Tips',
                    active: _filter == TipKind.positive,
                    onTap: () => setState(() => _filter = TipKind.positive),
                  ),
                  _FilterPill(
                    label: 'Avoid',
                    active: _filter == TipKind.avoid,
                    activeColor: tokens.priceDown,
                    onTap: () => setState(() => _filter = TipKind.avoid),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _TipCard(tip: filtered[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final Color? activeColor;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.active,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final color = activeColor ?? tokens.brand;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: TravelPill(
          text: label,
          fillColor: active ? color : Colors.transparent,
          borderColor: active ? color : tokens.border,
          textColor: active ? tokens.background : tokens.textPrimary,
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final Tip tip;

  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final accent = tip.kind == TipKind.avoid ? tokens.priceDown : tokens.brand;
    final kindLabel = switch (tip.kind) {
      TipKind.positive => 'TIP',
      TipKind.avoid => 'AVOID',
      TipKind.neutral => 'NOTE',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: tokens.surfaceElevated,
                child: Text(
                  tip.authorName[0],
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: tokens.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                tip.authorName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              TravelLabel(kindLabel, color: accent),
              const Spacer(),
              TravelLabel(DateFormat.MMMd().format(tip.createdAt), size: 10),
            ],
          ),
          const SizedBox(height: 12),
          Text(tip.body, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 14, color: tokens.textMuted),
              const SizedBox(width: 4),
              Text(
                '${tip.likes}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
