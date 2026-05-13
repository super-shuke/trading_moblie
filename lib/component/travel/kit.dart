import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

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
        Icon(Icons.location_searching_sharp, size: 28, color: tokens.textPrimarySameBtn),
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

class TravelCommonTitle extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle; // style
  final double? height; // 行高
  final double? letterSpacing; // 字间距
  final bool? isSystemFont; // 是否使用系统字体（不受 GoogleFonts 影响）

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
