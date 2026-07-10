import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/earthGlobe/travel_earth_globe_view.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

enum _GlobeDemoLayer { satellite, hybrid, night }

class GlobeDemo extends StatefulWidget {
  const GlobeDemo({super.key});

  @override
  State<GlobeDemo> createState() => _GlobeDemoState();
}

class _GlobeDemoState extends State<GlobeDemo> {
  _GlobeDemoLayer _layer = _GlobeDemoLayer.satellite;
  bool _autoRotate = true;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final cities = store.cities.take(10).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _SpaceBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _GlobeStage(
                      layer: _layer,
                      cities: cities,
                      userLocation: store.userLocation,
                      autoRotate: _autoRotate,
                      compact: compact,
                      onCityTap: (city) =>
                          context.push('/explore/city/${city.id}'),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      top: 16,
                      child: _TopBar(tokens: tokens),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: compact ? 20 : 28,
                      child: compact
                          ? _BottomSheetControls(
                              layer: _layer,
                              autoRotate: _autoRotate,
                              cities: cities,
                              onLayerChanged: (layer) {
                                setState(() => _layer = layer);
                              },
                              onAutoRotateChanged: (value) {
                                setState(() => _autoRotate = value);
                              },
                            )
                          : _DesktopControls(
                              layer: _layer,
                              autoRotate: _autoRotate,
                              cities: cities,
                              onLayerChanged: (layer) {
                                setState(() => _layer = layer);
                              },
                              onAutoRotateChanged: (value) {
                                setState(() => _autoRotate = value);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GlobeStage extends StatelessWidget {
  final _GlobeDemoLayer layer;
  final List<City> cities;
  final UserLocation userLocation;
  final bool autoRotate;
  final bool compact;
  final ValueChanged<City> onCityTap;

  const _GlobeStage({
    required this.layer,
    required this.cities,
    required this.userLocation,
    required this.autoRotate,
    required this.compact,
    required this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Size from the actual stage constraints so the globe remains centered
        // in resizable windows instead of following the physical screen size.
        final shortestSide = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final size = math.min(
          compact ? constraints.maxWidth * 1.04 : shortestSide * 0.9,
          compact ? 520.0 : 760.0,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: ColorFiltered(
                  colorFilter: _layerFilter(layer),
                  child: TravelEarthGlobeView(
                    size: size,
                    showBackground: false,
                    cities: cities,
                    userLocation: userLocation,
                    onCityTap: onCityTap,
                    autoRotate: autoRotate,
                    rotationSpeed: 0.035,
                    maxMarkers: cities.length,
                    showLabels: layer == _GlobeDemoLayer.hybrid,
                    zoom: compact ? -0.06 : 0.02,
                    sphereAlignment: Alignment.center,
                    spherePadding: EdgeInsets.all(compact ? 20 : 36),
                    dayNightCycleEnabled: false,
                    surfaceLightingEnabled: false,
                    lightIntensity: 0,
                    ambientLight: 1,
                    atmosphereOpacity: 0.18,
                    atmosphereThickness: 0.026,
                    atmosphereBlur: 18,
                    shadowColor: const Color(0x3338BDF8),
                    shadowBlurSigma: 14,
                    showGradientOverlay: true,
                    gradientOverlay: RadialGradient(
                      center: const Alignment(-0.18, -0.24),
                      colors: [
                        Colors.white.withValues(alpha: 0.04),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.16),
                      ],
                      stops: const [0, 0.58, 1],
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.5),
                    radius: compact ? 0.68 : 0.58,
                    colors: const [
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x66030712),
                    ],
                    stops: const [0, 0.68, 1],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  ColorFilter _layerFilter(_GlobeDemoLayer layer) {
    switch (layer) {
      case _GlobeDemoLayer.satellite:
        return const ColorFilter.mode(Colors.transparent, BlendMode.dst);
      case _GlobeDemoLayer.hybrid:
        return const ColorFilter.mode(Color(0x2238BDF8), BlendMode.screen);
      case _GlobeDemoLayer.night:
        return const ColorFilter.mode(Color(0xAA020617), BlendMode.multiply);
    }
  }
}

class _TopBar extends StatelessWidget {
  final AppCommon tokens;

  const _TopBar({required this.tokens});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: Colors.white,
                  tooltip: 'Back',
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Satellite Globe Demo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const _GlassPill(
                  icon: Icons.satellite_alt_outlined,
                  text: 'Local texture',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetControls extends StatelessWidget {
  final _GlobeDemoLayer layer;
  final bool autoRotate;
  final List<City> cities;
  final ValueChanged<_GlobeDemoLayer> onLayerChanged;
  final ValueChanged<bool> onAutoRotateChanged;

  const _BottomSheetControls({
    required this.layer,
    required this.autoRotate,
    required this.cities,
    required this.onLayerChanged,
    required this.onAutoRotateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LayerControls(
            layer: layer,
            autoRotate: autoRotate,
            onLayerChanged: onLayerChanged,
            onAutoRotateChanged: onAutoRotateChanged,
          ),
          const SizedBox(height: 14),
          _CityStrip(cities: cities),
        ],
      ),
    );
  }
}

class _DesktopControls extends StatelessWidget {
  final _GlobeDemoLayer layer;
  final bool autoRotate;
  final List<City> cities;
  final ValueChanged<_GlobeDemoLayer> onLayerChanged;
  final ValueChanged<bool> onAutoRotateChanged;

  const _DesktopControls({
    required this.layer,
    required this.autoRotate,
    required this.cities,
    required this.onLayerChanged,
    required this.onAutoRotateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _CityStrip(cities: cities)),
        const SizedBox(width: 16),
        SizedBox(
          width: 360,
          child: _GlassPanel(
            child: _LayerControls(
              layer: layer,
              autoRotate: autoRotate,
              onLayerChanged: onLayerChanged,
              onAutoRotateChanged: onAutoRotateChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _LayerControls extends StatelessWidget {
  final _GlobeDemoLayer layer;
  final bool autoRotate;
  final ValueChanged<_GlobeDemoLayer> onLayerChanged;
  final ValueChanged<bool> onAutoRotateChanged;

  const _LayerControls({
    required this.layer,
    required this.autoRotate,
    required this.onLayerChanged,
    required this.onAutoRotateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Map style',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _LayerChip(
              label: 'Satellite',
              icon: Icons.public,
              selected: layer == _GlobeDemoLayer.satellite,
              onTap: () => onLayerChanged(_GlobeDemoLayer.satellite),
            ),
            _LayerChip(
              label: 'Hybrid',
              icon: Icons.map_outlined,
              selected: layer == _GlobeDemoLayer.hybrid,
              onTap: () => onLayerChanged(_GlobeDemoLayer.hybrid),
            ),
            _LayerChip(
              label: 'Night',
              icon: Icons.dark_mode_outlined,
              selected: layer == _GlobeDemoLayer.night,
              onTap: () => onLayerChanged(_GlobeDemoLayer.night),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Auto rotate',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            Switch.adaptive(
              value: autoRotate,
              activeThumbColor: const Color(0xFF38BDF8),
              activeTrackColor: const Color(0xFF38BDF8).withValues(alpha: 0.32),
              onChanged: onAutoRotateChanged,
            ),
          ],
        ),
        const Text(
          'Demo uses local satellite-style earth textures. Real map data can be swapped in later with Mapbox, MapTiler, or Google 3D Tiles.',
          style: TextStyle(color: Colors.white54, fontSize: 11, height: 1.35),
        ),
      ],
    );
  }
}

class _LayerChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _LayerChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF38BDF8).withValues(alpha: 0.24)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? const Color(0xFF7DD3FC)
                  : Colors.white.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: Colors.white),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityStrip extends StatelessWidget {
  final List<City> cities;

  const _CityStrip({required this.cities});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) => _CityTile(city: cities[index]),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  final City city;

  const _CityTile({required this.city});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/explore/city/${city.id}'),
        child: Container(
          width: 168,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              TravelPlaceholderImage(
                seed: city.heroImageRef,
                width: 58,
                height: 68,
                radius: BorderRadius.circular(12),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      city.country,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${city.poiCount} places',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;

  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF020617).withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Padding(padding: const EdgeInsets.all(14), child: child),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceBackdrop extends StatelessWidget {
  const _SpaceBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/earth_globe/2k_stars.jpg', fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF020617).withValues(alpha: 0.16),
                const Color(0xFF020617).withValues(alpha: 0.72),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
