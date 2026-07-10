import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

const geoStarfieldAsset = 'assets/earth_globe/2k_stars.jpg';

/// The single app-wide background. Route pages stay transparent above it so
/// transitions never flash a different color or generate a second starfield.
class GeoStarfieldBackground extends StatelessWidget {
  final Widget child;

  const GeoStarfieldBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF02060C),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            geoStarfieldAsset,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF02060C)),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(color: Color(0x52000000)),
          ),
          child,
        ],
      ),
    );
  }
}

class GeoBackground extends StatelessWidget {
  final Widget child;

  const GeoBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x18000000), Color(0x42000000), Color(0x76000000)],
          stops: [0, 0.52, 1],
        ),
      ),
      child: child,
    );
  }
}

class GeoContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const GeoContent({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class GeoGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const GeoGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final radius = borderRadius ?? BorderRadius.circular(18);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: color ?? tokens.surface.withValues(alpha: 0.78),
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: tokens.border.withValues(alpha: 0.85)),
          ),
          clipBehavior: Clip.antiAlias,
          child: onTap == null
              ? Padding(padding: padding, child: child)
              : InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  splashFactory: InkRipple.splashFactory,
                  splashColor: tokens.brand.withValues(alpha: 0.18),
                  highlightColor: tokens.brand.withValues(alpha: 0.08),
                  child: Padding(padding: padding, child: child),
                ),
        ),
      ),
    );
  }
}

/// Clips the ripple to the same rounded boundary as its visual content.
/// Useful for gradient cards where a regular InkWell would paint underneath
/// the opaque decoration and make the interaction look missing.
class GeoTapSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final String? semanticLabel;

  const GeoTapSurface({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            child,
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: borderRadius,
                  splashFactory: InkRipple.splashFactory,
                  splashColor: tokens.brand.withValues(alpha: 0.2),
                  highlightColor: tokens.brand.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GeoSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const GeoSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(side: BorderSide.none),
            child: Text(
              actionLabel!,
              style: TextStyle(color: tokens.brand, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class GeoGradientArt extends StatelessWidget {
  final String seed;
  final Widget? child;
  final BorderRadius? borderRadius;

  const GeoGradientArt({
    super.key,
    required this.seed,
    this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final hash = seed.codeUnits.fold<int>(17, (sum, value) => sum * 31 + value);
    final palettes = <List<Color>>[
      const [Color(0xFFE08162), Color(0xFF753C4E), Color(0xFF101827)],
      const [Color(0xFF6F8FE8), Color(0xFF344C92), Color(0xFF111828)],
      const [Color(0xFF69B78D), Color(0xFF245C5C), Color(0xFF0D1723)],
      const [Color(0xFFE4B85A), Color(0xFF8B6334), Color(0xFF151926)],
    ];
    final palette = palettes[hash.abs() % palettes.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -34,
            top: -26,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class GeoRatingDots extends StatelessWidget {
  final double value;
  final int count;

  const GeoRatingDots({super.key, required this.value, this.count = 5});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final active = value >= index + 0.6;
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? tokens.brand : tokens.border,
            ),
          ),
        );
      }),
    );
  }
}
