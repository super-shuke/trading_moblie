import 'dart:async';

import 'package:flutter/material.dart';

/// 显示在当前页面上方的轻量气泡提示。
///
/// 通过 [show] 插入 Overlay，自动执行淡入、停留和淡出动画。
class TravelBubble extends StatefulWidget {
  /// 气泡中显示的提示文本。
  final String? message;

  /// 确认气泡的标题。
  final String? title;

  /// 确认气泡的正文。
  final String? content;

  /// 提示文本左侧的状态图标。
  final IconData icon;

  /// 气泡完全显示后的停留时间。
  final Duration visibleDuration;

  /// 淡入和淡出各自使用的动画时长。
  final Duration fadeDuration;

  /// 气泡在页面中的位置，默认水平和垂直居中。
  final Alignment position;

  /// 是否显示确认和取消操作，默认仅作为自动消失的提示。
  final bool showActions;

  /// 自定义确认按钮文本，默认使用系统本地化文本。
  final String? confirmLabel;

  /// 自定义取消按钮文本，默认使用系统本地化文本。
  final String? cancelLabel;

  /// 淡出结束后调用，用于从 Overlay 移除气泡。
  final ValueChanged<bool?> onDismiss;

  const TravelBubble({
    super.key,
    this.message,
    this.title,
    this.content,
    required this.onDismiss,
    this.icon = Icons.check_circle_outline,
    this.visibleDuration = const Duration(milliseconds: 1800),
    this.fadeDuration = const Duration(milliseconds: 220),
    this.position = Alignment.center,
    this.showActions = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : assert(
         showActions ? title != null && content != null : message != null,
         'Confirmation bubbles require title and content; notification bubbles require message.',
       );

  static OverlayEntry? _activeEntry;
  static Completer<bool?>? _activeCompleter;

  /// 在最上层 Overlay 显示一个气泡提示，同一时间只保留一个气泡。
  static Future<bool?> show(
    BuildContext context, {
    String? message,
    String? title,
    String? content,
    IconData icon = Icons.check_circle_outline,
    Duration visibleDuration = const Duration(milliseconds: 1800),
    Duration fadeDuration = const Duration(milliseconds: 220),
    Alignment position = Alignment.center,
    bool showActions = false,
    String? confirmLabel,
    String? cancelLabel,
  }) {
    assert(
      showActions ? title != null && content != null : message != null,
      'Confirmation bubbles require title and content; notification bubbles require message.',
    );
    _activeEntry?.remove();
    if (!(_activeCompleter?.isCompleted ?? true)) {
      _activeCompleter!.complete();
    }

    final overlay = Overlay.of(context, rootOverlay: true);
    final completer = Completer<bool?>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => TravelBubble(
        message: message,
        title: title,
        content: content,
        icon: icon,
        visibleDuration: visibleDuration,
        fadeDuration: fadeDuration,
        position: position,
        showActions: showActions,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onDismiss: (result) {
          if (entry.mounted) {
            entry.remove();
          }
          if (!completer.isCompleted) {
            completer.complete(result);
          }
          if (identical(_activeEntry, entry)) {
            _activeEntry = null;
            _activeCompleter = null;
          }
        },
      ),
    );
    _activeEntry = entry;
    _activeCompleter = completer;
    overlay.insert(entry);
    return completer.future;
  }

  @override
  State<TravelBubble> createState() => _TravelBubbleState();
}

class _TravelBubbleState extends State<TravelBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
      reverseDuration: widget.fadeDuration,
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAnimation());
  }

  Future<void> _runAnimation() async {
    await _controller.forward();
    if (widget.showActions) return;
    await Future<void>.delayed(widget.visibleDuration);
    if (!mounted) return;
    await _dismiss();
  }

  Future<void> _dismiss([bool? result]) async {
    if (_isDismissing) return;
    _isDismissing = true;
    await _controller.reverse();
    if (mounted) {
      widget.onDismiss(result);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = MaterialLocalizations.of(context);
    final semanticsLabel = widget.showActions
        ? '${widget.title}. ${widget.content}'
        : widget.message!;
    return Positioned.fill(
      child: Stack(
        children: [
          if (widget.showActions)
            ModalBarrier(
              dismissible: false,
              color: colorScheme.scrim.withValues(alpha: 0.24),
            ),
          SafeArea(
            child: IgnorePointer(
              ignoring: !widget.showActions,
              child: Align(
                alignment: widget.position,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FadeTransition(
                    opacity: _opacity,
                    child: Semantics(
                      liveRegion: true,
                      label: semanticsLabel,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Material(
                          color: colorScheme.surfaceContainerHigh,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          elevation: 6,
                          shadowColor: colorScheme.shadow,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              14,
                              16,
                              widget.showActions ? 10 : 14,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.showActions) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        widget.icon,
                                        size: 22,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          widget.title!,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: colorScheme.onSurface,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.content!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => _dismiss(false),
                                        child: Text(
                                          widget.cancelLabel ??
                                              localizations.cancelButtonLabel,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton(
                                        onPressed: () => _dismiss(true),
                                        child: Text(
                                          widget.confirmLabel ??
                                              localizations.okButtonLabel,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        widget.icon,
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          widget.message!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colorScheme.onSurface,
                                              ),
                                        ),
                                      ),
                                    ],
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
          ),
        ],
      ),
    );
  }
}
