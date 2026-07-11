import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class TravelSearchView extends StatefulWidget {
  const TravelSearchView({super.key});

  @override
  State<TravelSearchView> createState() => _TravelSearchViewState();
}

class _TravelSearchViewState extends State<TravelSearchView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final store = TravelStoreScope.of(context);
    final allPois = store.cities
        .expand((city) => store.poisForCity(city.id))
        .toList();
    final normalized = _query.trim().toLowerCase();
    final cities = store.cities.where((city) {
      return normalized.isNotEmpty &&
          '${city.name} ${city.country} ${city.tags.join(' ')}'
              .toLowerCase()
              .contains(normalized);
    }).toList();
    final pois = allPois.where((poi) {
      return normalized.isNotEmpty &&
          '${poi.name} ${poi.category} ${poi.shortDescription}'
              .toLowerCase()
              .contains(normalized);
    }).toList();
    const trending = <String>[
      'Tokyo',
      'Paris',
      'Barcelona',
      'Bali',
      'Senso-ji Temple',
      'teamLab Planets',
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GeoBackground(
        child: SafeArea(
          child: GeoContent(
            maxWidth: 760,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Back',
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/explore'),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TravelTextField(
                        key: const ValueKey('travel-search-field'),
                        controller: _controller,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) => setState(() => _query = value),
                        hintText: 'Search cities, places, shops…',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close, size: 19),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: _query.trim().isEmpty
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TravelLabel('TRENDING SEARCHES'),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final term in trending)
                                    ActionChip(
                                      label: Text(term),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 7,
                                      ),
                                      onPressed: () {
                                        _controller.text = term;
                                        _controller.selection =
                                            TextSelection.collapsed(
                                              offset: term.length,
                                            );
                                        setState(() => _query = term);
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            if (cities.isNotEmpty) ...[
                              const TravelLabel('DESTINATIONS'),
                              const SizedBox(height: 10),
                              for (final city in cities) ...[
                                _CitySearchResult(city: city),
                                const SizedBox(height: 10),
                              ],
                            ],
                            if (pois.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const TravelLabel('PLACES'),
                              const SizedBox(height: 10),
                              for (final poi in pois) ...[
                                _PoiSearchResult(poi: poi),
                                const SizedBox(height: 10),
                              ],
                            ],
                            if (cities.isEmpty && pois.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 80),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.travel_explore,
                                      size: 42,
                                      color: tokens.textMuted,
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'No thoughtful matches yet',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Try a city, a place, or a mood like “sunset”.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: tokens.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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

class _CitySearchResult extends StatelessWidget {
  final City city;

  const _CitySearchResult({required this.city});

  @override
  Widget build(BuildContext context) {
    return GeoGlassCard(
      padding: const EdgeInsets.all(11),
      onTap: () => context.push('/explore/city/${city.id}'),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: GeoGradientArt(seed: city.heroImageRef),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(city.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${city.country} · ${city.poiCount} places',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _PoiSearchResult extends StatelessWidget {
  final Poi poi;

  const _PoiSearchResult({required this.poi});

  @override
  Widget build(BuildContext context) {
    return GeoGlassCard(
      padding: const EdgeInsets.all(11),
      onTap: () => context.push('/explore/city/${poi.cityId}/poi/${poi.id}'),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: GeoGradientArt(seed: poi.coverImageRef),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(poi.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${poi.category} · ${poi.shortDescription}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
