import 'package:flutter/material.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class TripMapView extends StatelessWidget {
  const TripMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final store = TravelStoreScope.of(context);
    final itinerary = store.itinerary;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _AbstractMapPainter()),
              ),
              for (var i = 0; i < itinerary.stops.length; i++)
                _MapPin(
                  index: i,
                  total: itinerary.stops.length,
                  stop: itinerary.stops[i],
                  poi: store.poiById(itinerary.stops[i].poiId),
                  completed: store.isStopCompleted(itinerary.stops[i].id),
                ),
              SafeArea(
                bottom: false,
                child: GeoContent(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${itinerary.title} · Day 1',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).extension<AppCommon>()!.brand,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Map',
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                            ],
                          ),
                        ),
                        GeoGlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 9,
                          ),
                          child: Text('●  ${itinerary.stops.length} stops'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final int index;
  final int total;
  final ItineraryStop stop;
  final Poi? poi;
  final bool completed;

  const _MapPin({
    required this.index,
    required this.total,
    required this.stop,
    required this.poi,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final positions = const <Alignment>[
      Alignment(-0.52, -0.28),
      Alignment(0.36, -0.02),
      Alignment(-0.05, 0.42),
      Alignment(0.52, 0.7),
    ];
    return Align(
      alignment: positions[index % positions.length],
      child: Semantics(
        button: true,
        label: 'Stop ${index + 1}: ${poi?.name ?? stop.poiId}',
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => showModalBottomSheet<void>(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (context) => _StopSheet(
                index: index,
                stop: stop,
                poi: poi,
                completed: completed,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: completed ? tokens.priceUp : tokens.brand,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                      bottomLeft: Radius.circular(22),
                      bottomRight: Radius.circular(4),
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 12),
                    ],
                  ),
                  transform: Matrix4.rotationZ(0.78),
                  child: Transform.rotate(
                    angle: -0.78,
                    child: completed
                        ? Icon(Icons.check, color: tokens.background)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: tokens.background,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  constraints: const BoxConstraints(maxWidth: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.background.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: tokens.border),
                  ),
                  child: Text(
                    poi?.name ?? stop.poiId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _StopSheet extends StatelessWidget {
  final int index;
  final ItineraryStop stop;
  final Poi? poi;
  final bool completed;

  const _StopSheet({
    required this.index,
    required this.stop,
    required this.poi,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: tokens.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: completed ? tokens.priceUp : tokens.brand,
            foregroundColor: tokens.background,
            child: Text('${index + 1}'),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poi?.name ?? stop.poiId,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${poi?.category ?? 'Place'} · ${stop.dwell.inMinutes} minutes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (completed) Icon(Icons.check_circle, color: tokens.priceUp),
        ],
      ),
    );
  }
}

class _AbstractMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0B1726),
    );

    final grid = Paint()
      ..color = const Color(0x143C5570)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 58) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 58) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final park = Paint()..color = const Color(0x252E715E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.06,
          size.height * 0.18,
          size.width * 0.28,
          122,
        ),
        const Radius.circular(24),
      ),
      park,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.56,
          size.height * 0.62,
          size.width * 0.33,
          180,
        ),
        const Radius.circular(28),
      ),
      park,
    );

    final road = Paint()
      ..color = const Color(0xFF19283A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round;
    final pathA = Path()
      ..moveTo(-30, size.height * 0.34)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.29,
        size.width * 0.68,
        size.height * 0.42,
        size.width + 40,
        size.height * 0.35,
      );
    canvas.drawPath(pathA, road);
    final pathB = Path()
      ..moveTo(size.width * 0.72, -20)
      ..cubicTo(
        size.width * 0.63,
        size.height * 0.32,
        size.width * 0.57,
        size.height * 0.68,
        size.width * 0.47,
        size.height + 30,
      );
    canvas.drawPath(pathB, road);
    canvas.drawPath(
      pathB,
      Paint()
        ..color = const Color(0x1F91C9F9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
