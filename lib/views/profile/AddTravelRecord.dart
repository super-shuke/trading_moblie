import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class AddTravelRecordView extends StatefulWidget {
  const AddTravelRecordView({super.key});

  @override
  State<AddTravelRecordView> createState() => _AddTravelRecordViewState();
}

class _AddTravelRecordViewState extends State<AddTravelRecordView> {
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _placeController = TextEditingController();
  final _reviewController = TextEditingController();
  TravelRecordType _type = TravelRecordType.country;
  String _category = 'Shop';

  bool get _canSave => _type == TravelRecordType.country
      ? _countryController.text.trim().isNotEmpty
      : _cityController.text.trim().isNotEmpty &&
            _placeController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    _placeController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_canSave) return;
    final now = DateTime.now();
    final title = _type == TravelRecordType.country
        ? _countryController.text.trim()
        : _placeController.text.trim();
    TravelStoreScope.of(context).addTravelRecord(
      TravelRecord(
        id: 'record_${now.microsecondsSinceEpoch}',
        type: _type,
        title: title,
        city: _cityController.text.trim(),
        category: _category,
        date: now,
        comment: _reviewController.text.trim(),
      ),
    );
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile/history');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GeoBackground(
        child: SafeArea(
          child: GeoContent(
            maxWidth: 680,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(top: 16, bottom: 40),
              children: [
                _Header(onSave: _canSave ? _save : null),
                const SizedBox(height: 22),
                _TypePicker(
                  value: _type,
                  onChanged: (value) => setState(() => _type = value),
                ),
                const SizedBox(height: 12),
                Text(
                  'Countries you add are pinned on your Explore globe. Places join that city’s local list and can include your own review.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: tokens.textMuted),
                ),
                const SizedBox(height: 22),
                if (_type == TravelRecordType.country) ...[
                  const TravelLabel('COUNTRY'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _countryController,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'e.g. Portugal',
                    ),
                  ),
                ] else ...[
                  const TravelLabel('CITY'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cityController,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'e.g. Lisbon',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const TravelLabel('PLACE'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _placeController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Shop, hotel, restaurant, or sight',
                    ),
                  ),
                  const SizedBox(height: 18),
                  const TravelLabel('CATEGORY'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final category in const [
                        'Shop',
                        'Hotel',
                        'Food',
                        'Sight',
                      ])
                        ChoiceChip(
                          label: Text(category),
                          selected: category == _category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const TravelLabel('YOUR REVIEW'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'What should another thoughtful traveler know?',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback? onSave;

  const _Header({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filledTonal(
          tooltip: 'Back to travel history',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/profile/history'),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Add record',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ElevatedButton(onPressed: onSave, child: const Text('Save')),
      ],
    );
  }
}

class _TypePicker extends StatelessWidget {
  final TravelRecordType value;
  final ValueChanged<TravelRecordType> onChanged;

  const _TypePicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Material(
        color: tokens.surface.withValues(alpha: 0.78),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              for (final type in TravelRecordType.values)
                Expanded(
                  child: Material(
                    color: value == type ? tokens.brand : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => onChanged(type),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Text(
                          type == TravelRecordType.country
                              ? 'Country'
                              : 'Place',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: value == type
                                ? tokens.background
                                : tokens.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
