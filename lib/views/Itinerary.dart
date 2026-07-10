import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class ItineraryView extends StatefulWidget {
  const ItineraryView({super.key});

  @override
  State<ItineraryView> createState() => _ItineraryViewState();
}

class _ItineraryViewState extends State<ItineraryView> {
  bool _showDetail = false;
  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    final store = TravelStoreScope.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GeoBackground(
        child: SafeArea(
          bottom: false,
          child: GeoContent(
            maxWidth: 820,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _showDetail
                  ? _TripDetail(
                      key: const ValueKey('trip-detail'),
                      store: store,
                      selectedDay: _selectedDay,
                      onDayChanged: (value) =>
                          setState(() => _selectedDay = value),
                      onBack: () => setState(() => _showDetail = false),
                    )
                  : _TripOverview(
                      key: const ValueKey('trip-overview'),
                      store: store,
                      onContinue: () => setState(() => _showDetail = true),
                      onNewTrip: () => context.push('/itinerary/new'),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TripOverview extends StatelessWidget {
  final TravelStore store;
  final VoidCallback onContinue;
  final VoidCallback onNewTrip;

  const _TripOverview({
    super.key,
    required this.store,
    required this.onContinue,
    required this.onNewTrip,
  });

  @override
  Widget build(BuildContext context) {
    final itinerary = store.itinerary;
    final city = store.cityById(itinerary.cityId);
    final done = store.completedStopIds.length;
    return ListView(
      padding: const EdgeInsets.only(top: 24, bottom: 112),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TravelLabel('YOUR JOURNEYS'),
                  const SizedBox(height: 5),
                  Text(
                    'Trips',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: onNewTrip,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New trip'),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const TravelLabel('UPCOMING'),
        const SizedBox(height: 10),
        _UpcomingJourney(
          cityName: city?.name ?? 'Your journey',
          itinerary: itinerary,
          completed: done,
          onContinue: onContinue,
        ),
        const SizedBox(height: 28),
        const TravelLabel('PLANNING'),
        const SizedBox(height: 10),
        for (final trip in store.plannedTrips) ...[
          GeoGlassCard(
            onTap: onContinue,
            child: _SmallJourney(
              seed: '${trip.country}_${trip.city}',
              title: trip.name,
              subtitle: _plannedTripSubtitle(trip),
            ),
          ),
          const SizedBox(height: 10),
        ],
        GeoGlassCard(
          onTap: onNewTrip,
          child: const _SmallJourney(
            seed: 'barcelona',
            title: 'Weekend ideas',
            subtitle: 'Draft · no dates yet · 6 saved places',
          ),
        ),
        const SizedBox(height: 28),
        const TravelLabel('PAST TRIPS'),
        const SizedBox(height: 10),
        const GeoGlassCard(
          child: _SmallJourney(
            seed: 'archive',
            title: 'A quiet week in Paris',
            subtitle: '7 days · 21 places visited',
          ),
        ),
      ],
    );
  }

  String _plannedTripSubtitle(PlannedTrip trip) {
    final dates = trip.startDate == null
        ? 'No dates yet'
        : trip.endDate == null
        ? DateFormat.MMMd().format(trip.startDate!)
        : '${DateFormat.MMMd().format(trip.startDate!)} – ${DateFormat.MMMd().format(trip.endDate!)}';
    return '$dates · ${trip.travelers} ${trip.travelers == 1 ? 'traveler' : 'travelers'} · ${trip.city}';
  }
}

class _UpcomingJourney extends StatelessWidget {
  final String cityName;
  final Itinerary itinerary;
  final int completed;
  final VoidCallback onContinue;

  const _UpcomingJourney({
    required this.cityName,
    required this.itinerary,
    required this.completed,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final ratio = itinerary.stops.isEmpty
        ? 0.0
        : (completed / itinerary.stops.length).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: tokens.border),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 164,
              child: GeoGradientArt(
                seed: cityName,
                borderRadius: BorderRadius.zero,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TravelPill(
                        text: 'READY WHEN YOU ARE',
                        fillColor: Color(0x33000000),
                      ),
                      const Spacer(),
                      Text(
                        itinerary.title,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${DateFormat.MMMd().format(itinerary.date)} · ${itinerary.stops.length} stops · $cityName',
                        style: TextStyle(color: tokens.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: tokens.surface.withValues(alpha: 0.88),
              padding: const EdgeInsets.fromLTRB(16, 13, 12, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '$completed of ${itinerary.stops.length} stops completed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onContinue,
                        style: TextButton.styleFrom(side: BorderSide.none),
                        child: const Text('Continue →'),
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: ratio,
                      backgroundColor: tokens.border,
                      color: tokens.brand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallJourney extends StatelessWidget {
  final String seed;
  final String title;
  final String subtitle;

  const _SmallJourney({
    required this.seed,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 58, height: 58, child: GeoGradientArt(seed: seed)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const Icon(Icons.chevron_right),
      ],
    );
  }
}

class _TripDetail extends StatelessWidget {
  final TravelStore store;
  final int selectedDay;
  final ValueChanged<int> onDayChanged;
  final VoidCallback onBack;

  const _TripDetail({
    super.key,
    required this.store,
    required this.selectedDay,
    required this.onDayChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final itinerary = store.itinerary;
    final done = itinerary.stops
        .where((s) => store.isStopCompleted(s.id))
        .length;
    return ListView(
      padding: const EdgeInsets.only(top: 18, bottom: 112),
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: 'Back to trips',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itinerary.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${DateFormat.MMMd().format(itinerary.date)} · ${itinerary.stops.length} stops',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const TravelPill(
              text: 'IN PROGRESS',
              fillColor: Color(0x223DDC8B),
              borderColor: Color(0x6656D694),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: tokens.brand, size: 17),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Current location: ${store.userLocation.city} · progress updates when you complete a stop',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final active = index == selectedDay;
              return ChoiceChip(
                selected: active,
                onSelected: (_) => onDayChanged(index),
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Day ${index + 1}'),
                      Text(
                        DateFormat.MMMd().format(
                          itinerary.date.add(Duration(days: index)),
                        ),
                        style: const TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        if (selectedDay == 0)
          for (var i = 0; i < itinerary.stops.length; i++)
            _TimelineStop(
              stop: itinerary.stops[i],
              poi: store.poiById(itinerary.stops[i].poiId),
              completed: store.isStopCompleted(itinerary.stops[i].id),
              isLast: i == itinerary.stops.length - 1,
              onToggle: () => store.toggleStopCompleted(itinerary.stops[i].id),
            )
        else
          GeoGlassCard(
            child: Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: tokens.brand),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'This day is still open. Add discoveries from Explore when the plan feels right.',
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        GeoGlassCard(
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(child: Text("Today's summary")),
                  Text(
                    '$done / ${itinerary.stops.length}',
                    style: TextStyle(color: tokens.brand),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: itinerary.stops.isEmpty
                    ? 0
                    : done / itinerary.stops.length,
                minHeight: 5,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  done == 0
                      ? 'Tap a circle on the timeline when you complete a stop.'
                      : done == itinerary.stops.length
                      ? 'A full day, gently completed.'
                      : 'Keep the day flexible — the route can change as you go.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineStop extends StatelessWidget {
  final ItineraryStop stop;
  final Poi? poi;
  final bool completed;
  final bool isLast;
  final VoidCallback onToggle;

  const _TimelineStop({
    required this.stop,
    required this.poi,
    required this.completed,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 22),
              child: Text(
                DateFormat.Hm().format(stop.arriveAt),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: tokens.brand),
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onToggle,
                    customBorder: const CircleBorder(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: completed ? tokens.brand : tokens.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: tokens.brand, width: 2),
                      ),
                      child: completed
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: tokens.background,
                            )
                          : null,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 1, color: tokens.border)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GeoGlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: GeoGradientArt(
                        seed: poi?.coverImageRef ?? stop.id,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            poi?.name ?? stop.poiId,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  decoration: completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${poi?.category ?? 'place'} · ${stop.dwell.inMinutes} min${stop.note == null ? '' : ' · ${stop.note}'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
