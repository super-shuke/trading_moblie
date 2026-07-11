import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class NewTripView extends StatefulWidget {
  const NewTripView({super.key});

  @override
  State<NewTripView> createState() => _NewTripViewState();
}

class _NewTripViewState extends State<NewTripView> {
  final _nameController = TextEditingController();
  String? _country;
  String? _cityId;
  DateTime? _startDate;
  DateTime? _endDate;
  int _travelers = 1;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? _startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (start) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  void _create() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final store = TravelStoreScope.of(context);
    final city = store.cityById(_cityId ?? '') ?? store.cities.first;
    store.addPlannedTrip(
      PlannedTrip(
        id: 'trip_${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        country: city.country,
        city: city.name,
        startDate: _startDate,
        endDate: _endDate,
        travelers: _travelers,
      ),
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/itinerary');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = TravelStoreScope.of(context);
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final countries = store.cities.map((city) => city.country).toSet().toList();
    _country ??= countries.first;
    final cities = store.cities
        .where((city) => city.country == _country)
        .toList();
    if (cities.every((city) => city.id != _cityId)) {
      _cityId = cities.first.id;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GeoBackground(
        child: SafeArea(
          child: GeoContent(
            maxWidth: 760,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(top: 16, bottom: 40),
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Back to trips',
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/itinerary'),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New trip',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _nameController.text.trim().isEmpty
                          ? null
                          : _create,
                      child: const Text('Create'),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const TravelLabel('TRIP NAME'),
                const SizedBox(height: 8),
                TravelTextField(
                  controller: _nameController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  hintText: 'e.g. Tokyo food crawl',
                ),
                const SizedBox(height: 20),
                const TravelLabel('COUNTRY'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final country in countries)
                      ChoiceChip(
                        label: Text(country),
                        selected: _country == country,
                        onSelected: (_) => setState(() {
                          _country = country;
                          _cityId = null;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                const TravelLabel('CITY'),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cities.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 210,
                    mainAxisExtent: 82,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final city = cities[index];
                    return _CityChoice(
                      city: city,
                      selected: city.id == _cityId,
                      onTap: () => setState(() => _cityId = city.id),
                    );
                  },
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 460;
                    final fields = [
                      _DateField(
                        label: 'START',
                        value: _startDate,
                        onTap: () => _pickDate(start: true),
                      ),
                      _DateField(
                        label: 'END',
                        value: _endDate,
                        onTap: () => _pickDate(start: false),
                      ),
                    ];
                    if (compact) {
                      return Row(
                        children: [
                          Expanded(child: fields[0]),
                          const SizedBox(width: 12),
                          Expanded(child: fields[1]),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        SizedBox(width: 220, child: fields[0]),
                        const SizedBox(width: 12),
                        SizedBox(width: 220, child: fields[1]),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const TravelLabel('TRAVELERS'),
                const SizedBox(height: 9),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.surface.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _StepperButton(
                          icon: Icons.remove,
                          enabled: _travelers > 1,
                          onTap: () => setState(() => _travelers--),
                        ),
                        SizedBox(
                          width: 54,
                          child: Text(
                            '$_travelers',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        _StepperButton(
                          icon: Icons.add,
                          enabled: _travelers < 12,
                          onTap: () => setState(() => _travelers++),
                        ),
                      ],
                    ),
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

class _CityChoice extends StatelessWidget {
  final City city;
  final bool selected;
  final VoidCallback onTap;

  const _CityChoice({
    required this.city,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return GeoTapSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      semanticLabel: city.name,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            width: 2,
            color: selected ? tokens.brand : Colors.transparent,
          ),
        ),
        child: GeoGradientArt(
          seed: city.heroImageRef,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      city.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (selected)
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: tokens.brand,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: tokens.background,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TravelLabel(label),
        const SizedBox(height: 8),
        Material(
          color: tokens.surface.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value == null
                          ? 'Select'
                          : DateFormat.yMMMd().format(value!),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: value == null
                            ? tokens.textMuted
                            : tokens.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 17,
                    color: tokens.brand,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Material(
      color: tokens.brand.withValues(alpha: enabled ? 0.14 : 0.05),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? tokens.brand : tokens.textMuted,
          ),
        ),
      ),
    );
  }
}
