import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class NavigationView extends StatelessWidget {
  final String poiId;

  const NavigationView({super.key, required this.poiId});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final poi = TravelStoreScope.of(context).poiById(poiId);

    if (poi == null) {
      return const Scaffold(
        body: Center(child: Text('Navigation unavailable')),
      );
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: TravelPlaceholderImage(
              seed: 'map-$poiId',
              radius: BorderRadius.zero,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    tokens.background.withValues(alpha: 0.56),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/explore');
                          }
                        },
                        icon: const Icon(Icons.close),
                      ),
                      const Spacer(),
                      const TravelPill(
                        text: 'Walk · 12 min',
                        icon: Icons.directions_walk,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TravelLabel('Next'),
                        const SizedBox(height: 8),
                        Text(
                          'Turn left at Rua de Sao Tome',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'In 180 m · then continue uphill',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: tokens.textMuted),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/explore');
                              }
                            },
                            icon: const Icon(Icons.flag_outlined),
                            label: Text('Arrive · ${poi.name}'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
