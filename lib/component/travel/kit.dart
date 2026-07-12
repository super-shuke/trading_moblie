import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

/// 详情页统一的全宽主操作按钮。
class TravelPrimaryActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool light;

  const TravelPrimaryActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: double.infinity),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: FilledButton.styleFrom(
              elevation: 6,
              backgroundColor: light ? tokens.surfaceElevated : null,
              foregroundColor: light ? tokens.textPrimary : null,
              side: light ? BorderSide(color: tokens.border) : null,
            ),
          ),
        ),
      ),
    );
  }
}

/// 应用统一输入框。
///
/// 集中管理输入文字、提示文字、填充背景、边框、聚焦态和禁用态样式，
/// 同时保留单行、多行、密码、前后图标及键盘操作等原生输入能力。
class TravelTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;

  const TravelTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final radius = BorderRadius.circular(tokens.radiusMd);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: tokens.border.withValues(alpha: 0.9)),
    );

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      cursorColor: tokens.brand,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: tokens.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixIconColor: tokens.textSecondary,
        suffixIconColor: tokens.textSecondary,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        filled: true,
        fillColor: enabled
            ? tokens.surface.withValues(alpha: 0.78)
            : tokens.surface.withValues(alpha: 0.45),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines == 1 ? 13 : 14,
        ),
        border: border,
        enabledBorder: border,
        disabledBorder: border.copyWith(
          borderSide: BorderSide(color: tokens.border.withValues(alpha: 0.5)),
        ),
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: tokens.brand, width: 1.5),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: tokens.priceDown),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: BorderSide(color: tokens.priceDown, width: 1.5),
        ),
      ),
    );
  }
}

/// 小型大写标签。
///
/// 用于表单字段名、分类名和卡片辅助信息，默认应用较宽的字间距。
class TravelLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;
  final double spacing;

  const TravelLabel(
    this.text, {
    super.key,
    this.color,
    this.size = 10,
    this.spacing = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color ?? tokens.textPrimary,
        letterSpacing: spacing,
        fontSize: size,
      ),
    );
  }
}

/// 带定位图标的品牌或地点标识。
///
/// 默认显示 `GEOTRAVEL`，也可通过 [location] 显示当前地点名称。
class TravelLocationIcon extends StatelessWidget {
  final String location;

  const TravelLocationIcon({super.key, this.location = 'GEOTRAVEL'});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.location_searching_sharp,
          size: 28,
          color: tokens.textPrimarySameBtn,
        ),
        const SizedBox(width: 8),
        Text(
          location,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: tokens.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 详情页通用的可展开粘性导航栏。
///
/// 收起到工具栏附近时显示居中标题，页面可自定义标题、操作区和展开内容。
class TravelDetailSliverAppBar extends StatelessWidget {
  /// 导航栏接近完全收起时淡入显示的居中标题。
  final Widget collapsedTitle;

  /// 导航栏展开区域的内容，通常传入带背景图片的 [FlexibleSpaceBar]。
  final Widget flexibleSpace;

  /// 导航栏左侧组件，通常用于放置返回按钮。
  final Widget? leading;

  /// 导航栏右侧操作组件，例如收藏或分享按钮。
  final List<Widget>? actions;

  /// 导航栏完全展开时的高度，默认为 330 逻辑像素。
  final double expandedHeight;

  /// 标题相对完全收起位置提前显示的距离；数值越大，标题出现得越早。
  final double titleRevealOffset;

  const TravelDetailSliverAppBar({
    super.key,
    required this.collapsedTitle,
    required this.flexibleSpace,
    this.leading,
    this.actions,
    this.expandedHeight = 330,
    this.titleRevealOffset = 72,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: tokens.background.withValues(alpha: 0.9),
      surfaceTintColor: Colors.transparent,
      title: Builder(
        builder: (context) {
          final settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
          final showTitle =
              settings != null &&
              settings.currentExtent <= settings.minExtent + titleRevealOffset;

          return AnimatedOpacity(
            opacity: showTitle ? 1 : 0,
            duration: const Duration(milliseconds: 160),
            child: collapsedTitle,
          );
        },
      ),
      centerTitle: true,
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      leading: leading,
      actions: actions,
      flexibleSpace: flexibleSpace,
    );
  }
}

/// 紧凑的胶囊标签。
///
/// 适合展示状态、排名和分类，可选配前置图标及自定义填充、边框和文字颜色。
class TravelPill extends StatelessWidget {
  final String text;
  final Color? fillColor;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;

  const TravelPill({
    super.key,
    required this.text,
    this.fillColor,
    this.borderColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fillColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor ?? tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor ?? tokens.textPrimary),
            const SizedBox(width: 6),
          ],
          TravelLabel(
            text,
            color: textColor ?? tokens.textPrimary,
            spacing: 1.2,
          ),
        ],
      ),
    );
  }
}

/// 使用次级文字颜色的辅助标题。
///
/// 基于 [TravelLabel] 构建，适合层级较低的分组标题或说明标签。
class TravelSecondaryTitle extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;

  const TravelSecondaryTitle(
    this.text, {
    super.key,
    this.color,
    this.size = 10,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;

    return TravelLabel(text, color: color ?? tokens.textSecondary, size: size);
  }
}

/// 可配置的通用展示标题。
///
/// 默认使用 Fraunces 字体；设置 [isSystemFont] 后沿用主题字体，适合需要
/// 自定义字号、颜色、字重、行高或字间距的标题场景。
class TravelCommonTitle extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;

  /// 文本行高倍数。
  final double? height;

  /// 字符之间的额外间距。
  final double? letterSpacing;

  /// 是否使用主题字体，而不应用 Google Fonts。
  final bool? isSystemFont;

  const TravelCommonTitle(
    this.text, {
    super.key,
    this.size = 12,
    this.color,
    this.fontWeight,
    this.height,
    this.letterSpacing,
    this.fontStyle,
    this.isSystemFont,
  });
  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>();

    // 1. 构造基础样式（不含 fontFamily）
    final baseStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontStyle: fontStyle,
      fontWeight: FontWeight.w600,
      color: color ?? tokens!.textPrimary,
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
    );

    final finalStyle = isSystemFont == true
        ? baseStyle // 用系统字体
        : GoogleFonts.fraunces(textStyle: baseStyle); // 套 Fraunces

    return Text(text, style: finalStyle);
  }
}

/// 根据种子字符串生成稳定渐变的图片占位组件。
///
/// 相同 [seed] 会得到相同配色，适合真实图片尚未接入时维持可辨识的视觉占位。
class TravelPlaceholderImage extends StatelessWidget {
  final String seed;
  final double? width;
  final double? height;
  final BorderRadius? radius;

  const TravelPlaceholderImage({
    super.key,
    required this.seed,
    this.width,
    this.height,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final hash = seed.codeUnits.fold<int>(0, (sum, item) => sum + item);
    final hue = (hash * 37) % 360;
    final colorA = HSLColor.fromAHSL(1, hue.toDouble(), 0.35, 0.36).toColor();
    final colorB = HSLColor.fromAHSL(
      1,
      (hue + 45) % 360.0,
      0.45,
      0.18,
    ).toColor();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius ?? BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorA, colorB],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.white.withValues(alpha: 0.18),
          size: 32,
        ),
      ),
    );
  }
}

/// 将旅行多维评分展示为一组横向进度条。
///
/// 固定显示氛围、照片、拥挤度和可达性，并使用主题中的不同语义色区分维度。
class TravelRatingBars extends StatelessWidget {
  final MultiRating rating;

  const TravelRatingBars({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Column(
      children: [
        _TravelRatingBar(
          label: 'Atmosphere',
          value: rating.atmosphere,
          color: tokens.brand,
        ),
        const SizedBox(height: 12),
        _TravelRatingBar(
          label: 'Photos',
          value: rating.photos,
          color: tokens.amber,
        ),
        const SizedBox(height: 12),
        _TravelRatingBar(
          label: 'Crowds',
          value: rating.crowds,
          color: tokens.priceDown,
        ),
        const SizedBox(height: 12),
        _TravelRatingBar(
          label: 'Access',
          value: rating.access,
          color: tokens.accentAlt,
        ),
      ],
    );
  }
}

/// [TravelRatingBars] 内部使用的单项评分行。
///
/// 负责组合维度标签、0 至 5 分的比例条和右侧数字分值。
class _TravelRatingBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _TravelRatingBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Row(
      children: [
        SizedBox(width: 92, child: TravelLabel(label, size: 10)),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: tokens.border.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (value / 5).clamp(0.0, 1.0),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 34,
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
