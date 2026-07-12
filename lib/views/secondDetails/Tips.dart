import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traveling_app/component/common/bubble/index.dart';
import 'package:traveling_app/component/common/pageContent/index.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/component/travel/review_composer.dart';
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

  Future<void> _openReviewComposer() async {
    final store = TravelStoreScope.of(context);
    final posted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: TravelReviewComposer(
                title: 'Write a review',
                hintText: 'Share what other travelers should know',
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                onSubmit: (body, images) {
                  store.addTip(
                    Tip(
                      id: 'tip_${DateTime.now().microsecondsSinceEpoch}',
                      poiId: widget.poiId,
                      authorName: store.profile.name,
                      kind: TipKind.neutral,
                      body: body,
                      createdAt: DateTime.now(),
                      likes: 0,
                      images: images,
                    ),
                  );
                  Navigator.pop(sheetContext, true);
                },
              ),
            ),
          ),
        );
      },
    );
    if (posted != true || !mounted) return;

    setState(() => _filter = null);
    TravelBubble.show(context, message: 'Your comment was posted.');
  }

  Future<void> _openReplyComposer(Tip parent) async {
    final store = TravelStoreScope.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: TravelReviewComposer(
                title: 'Reply to ${parent.authorName}',
                hintText: 'Write a helpful reply',
                submitLabel: 'Reply',
                submitIcon: Icons.reply_outlined,
                autofocus: true,
                minLines: 2,
                maxLines: 4,
                onSubmit: (body, images) {
                  store.addTipReply(
                    parentTipId: parent.id,
                    reply: Tip(
                      id: 'reply_${DateTime.now().microsecondsSinceEpoch}',
                      poiId: parent.poiId,
                      authorName: store.profile.name,
                      kind: TipKind.neutral,
                      body: body,
                      createdAt: DateTime.now(),
                      likes: 0,
                      images: images,
                    ),
                  );
                  Navigator.pop(sheetContext);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final tips = store.tipsForPoi(widget.poiId);
    final filtered = _filter == null
        ? tips
        : tips.where((tip) => tip.kind == _filter).toList();

    return PageContent(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Tips')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: TravelPrimaryActionButton(
        onPressed: _openReviewComposer,
        icon: Icons.rate_review_outlined,
        label: 'Write a review',
        light: true,
      ),
      body: Column(
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
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _TipThread(
                  tip: filtered[index],
                  store: store,
                  onReply: _openReplyComposer,
                );
              },
            ),
          ),
        ],
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

class _TipThread extends StatelessWidget {
  final Tip tip;
  final TravelStore store;
  final ValueChanged<Tip> onReply;
  final int depth;

  const _TipThread({
    required this.tip,
    required this.store,
    required this.onReply,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final accent = tip.kind == TipKind.avoid ? tokens.priceDown : tokens.brand;
    final isReply = depth > 0;
    final kindLabel = switch (tip.kind) {
      TipKind.positive => 'TIP',
      TipKind.avoid => 'AVOID',
      TipKind.neutral => 'NOTE',
    };

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 18 : 0),
      child: Container(
        padding: EdgeInsets.all(isReply ? 12 : 16),
        decoration: BoxDecoration(
          color: isReply ? Colors.transparent : tokens.surface,
          borderRadius: isReply
              ? BorderRadius.zero
              : BorderRadius.circular(tokens.radiusLg),
          border: Border(
            left: BorderSide(
              color: isReply ? tokens.border : accent,
              width: isReply ? 2 : 3,
            ),
          ),
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
                Flexible(
                  child: Text(
                    tip.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                TravelLabel(kindLabel, color: accent),
                const Spacer(),
                TravelLabel(DateFormat.MMMd().format(tip.createdAt), size: 10),
              ],
            ),
            if (tip.body.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(tip.body, style: Theme.of(context).textTheme.bodyLarge),
            ],
            if (tip.images.isNotEmpty) ...[
              const SizedBox(height: 12),
              _TipImageGallery(images: tip.images, compact: isReply),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _TipAction(
                  tooltip: 'Like',
                  icon: store.isTipLiked(tip.id)
                      ? Icons.thumb_up
                      : Icons.thumb_up_outlined,
                  count: tip.likes,
                  active: store.isTipLiked(tip.id),
                  activeColor: tokens.brand,
                  onPressed: () => store.toggleTipLike(tip.poiId, tip.id),
                ),
                const SizedBox(width: 4),
                _TipAction(
                  tooltip: 'Dislike',
                  icon: store.isTipDisliked(tip.id)
                      ? Icons.thumb_down
                      : Icons.thumb_down_outlined,
                  count: tip.dislikes,
                  active: store.isTipDisliked(tip.id),
                  activeColor: tokens.priceDown,
                  onPressed: () => store.toggleTipDislike(tip.poiId, tip.id),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Reply',
                  onPressed: () => onReply(tip),
                  icon: const Icon(Icons.reply_outlined),
                  visualDensity: VisualDensity.compact,
                ),
                if (tip.children.isNotEmpty)
                  Text(
                    '${tip.children.length}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                if (store.canDeleteTip(tip)) ...[
                  const Spacer(),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline),
                    color: tokens.priceDown,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            for (final child in tip.children) ...[
              const SizedBox(height: 8),
              _TipThread(
                tip: child,
                store: store,
                onReply: onReply,
                depth: depth + 1,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await TravelBubble.show(
      context,
      title: 'Delete comment?',
      content: 'This action cannot be undone.',
      icon: Icons.delete_outline,
      showActions: true,
      confirmLabel: 'Delete',
    );
    if (confirmed != true || !context.mounted) return;

    if (store.deleteTip(tip.poiId, tip.id)) {
      TravelBubble.show(
        context,
        message: 'Your comment was deleted.',
        position: Alignment.bottomCenter,
      );
    }
  }
}

class _TipImageGallery extends StatelessWidget {
  final List<TipImage> images;
  final bool compact;

  const _TipImageGallery({required this.images, required this.compact});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = images.length == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final image in images)
              SizedBox(
                width: imageWidth,
                height: compact ? 110 : 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    image.bytes,
                    fit: BoxFit.cover,
                    semanticLabel: image.name,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TipAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final int count;
  final bool active;
  final Color activeColor;
  final VoidCallback onPressed;

  const _TipAction({
    required this.tooltip,
    required this.icon,
    required this.count,
    required this.active,
    required this.activeColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon),
          color: active ? activeColor : tokens.textMuted,
          visualDensity: VisualDensity.compact,
        ),
        Text('$count', style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
