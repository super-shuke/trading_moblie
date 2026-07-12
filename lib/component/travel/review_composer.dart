import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/travel_data.dart';

/// 评论编辑器提交回调，返回正文和用户选择的全部图片。
typedef TravelReviewSubmit =
    FutureOr<void> Function(String body, List<TipImage> images);

/// 可复用的评论与回复编辑器。
///
/// 集中处理文本输入、多图选择、图片预览删除以及提交状态。
class TravelReviewComposer extends StatefulWidget {
  /// 编辑器顶部标题。
  final String title;

  /// 输入框未输入内容时显示的提示文本。
  final String hintText;

  /// 右下角提交按钮文字。
  final String submitLabel;

  /// 提交按钮使用的图标。
  final IconData submitIcon;

  /// 编辑器显示后是否自动聚焦输入框。
  final bool autofocus;

  /// 输入框的最小文本行数。
  final int minLines;

  /// 输入框允许显示的最大文本行数。
  final int maxLines;

  /// 提交正文和多张图片时调用的业务回调。
  final TravelReviewSubmit onSubmit;

  const TravelReviewComposer({
    super.key,
    required this.title,
    required this.onSubmit,
    this.hintText = 'Share what other travelers should know',
    this.submitLabel = 'Post',
    this.submitIcon = Icons.send_outlined,
    this.autofocus = false,
    this.minLines = 4,
    this.maxLines = 8,
  });

  @override
  State<TravelReviewComposer> createState() => _TravelReviewComposerState();
}

class _TravelReviewComposerState extends State<TravelReviewComposer> {
  final _controller = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<TipImage> _images = [];
  bool _isPickingImages = false;
  bool _isSubmitting = false;

  bool get _canSubmit =>
      !_isSubmitting &&
      (_controller.text.trim().isNotEmpty || _images.isNotEmpty);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_isPickingImages) return;
    setState(() => _isPickingImages = true);
    try {
      final files = await _imagePicker.pickMultiImage(
        imageQuality: 82,
        maxWidth: 1800,
      );
      if (files.isEmpty || !mounted) return;
      final images = await Future.wait(
        files.map(
          (file) async =>
              TipImage(bytes: await file.readAsBytes(), name: file.name),
        ),
      );
      if (!mounted) return;
      setState(() => _images.addAll(images));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open those photos.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(
        _controller.text.trim(),
        List<TipImage>.unmodifiable(_images),
      );
      if (!mounted) return;
      _controller.clear();
      setState(() => _images.clear());
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to submit right now.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GeoGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TravelTextField(
            controller: _controller,
            autofocus: widget.autofocus,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            hintText: widget.hintText,
            onChanged: (_) => setState(() {}),
          ),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < _images.length; index++)
                  _ReviewImagePreview(
                    image: _images[index],
                    onRemove: () => setState(() => _images.removeAt(index)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _isPickingImages ? null : _pickImages,
                icon: _isPickingImages
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add photos'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _canSubmit ? _submit : null,
                icon: _isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(widget.submitIcon),
                label: Text(widget.submitLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewImagePreview extends StatelessWidget {
  final TipImage image;
  final VoidCallback onRemove;

  const _ReviewImagePreview({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 84,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              image.bytes,
              fit: BoxFit.cover,
              semanticLabel: image.name,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filled(
              tooltip: 'Remove photo',
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 16),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
