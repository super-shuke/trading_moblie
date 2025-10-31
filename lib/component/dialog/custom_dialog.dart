import 'package:flutter/material.dart';

/// 自定义弹窗配置类
class CustomDialogConfig {
  /// 是否显示遮罩
  final bool showMask;

  /// 遮罩颜色
  final Color maskColor;

  /// 是否可以点击遮罩关闭弹窗
  final bool dismissible;

  /// 弹窗动画时长
  final Duration animationDuration;

  const CustomDialogConfig({
    this.showMask = true,
    this.maskColor = const Color(0x80000000), // 默认半透明黑色
    this.dismissible = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });
}

/// 自定义弹窗组件
class CustomDialog extends StatefulWidget {
  /// 弹窗配置
  final CustomDialogConfig config;

  /// 自定义内容Widget
  final Widget child;

  /// 是否显示弹窗
  final bool isVisible;

  /// 弹窗关闭回调
  final VoidCallback? onClose;

  const CustomDialog({
    super.key,
    required this.child,
    required this.isVisible,
    this.config = const CustomDialogConfig(),
    this.onClose,
  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.config.animationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CustomDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleClose() {
    if (widget.config.dismissible && widget.onClose != null) {
      widget.onClose!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible && _controller.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Visibility(
          visible: widget.isVisible || _controller.status != AnimationStatus.dismissed,
          child: Stack(
            children: [
              // 遮罩层
              if (widget.config.showMask)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _handleClose,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                        color: widget.config.maskColor,
                      ),
                    ),
                  ),
                ),
              // 弹窗内容
              Center(
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: widget.child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 自定义弹窗控制器
class CustomDialogController extends ChangeNotifier {
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  /// 显示弹窗
  void show() {
    if (!_isVisible) {
      _isVisible = true;
      notifyListeners();
    }
  }

  /// 隐藏弹窗
  void hide() {
    if (_isVisible) {
      _isVisible = false;
      notifyListeners();
    }
  }

  /// 切换弹窗显示状态
  void toggle() {
    _isVisible = !_isVisible;
    notifyListeners();
  }
}
