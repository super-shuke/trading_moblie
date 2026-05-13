import 'package:flutter/material.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class UnityGlobeContainer extends StatelessWidget {
  final double size;
  final String? userLabel;
  final List<City> cities;
  final LatLng userLocation;
  final void Function(City city)? onCityTap;

  const UnityGlobeContainer({
    super.key,
    required this.size,
    required this.userLabel,
    required this.cities,
    required this.userLocation,
    required this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF173A63),
                  const Color(0xFF0D1F35),
                  tokens.background,
                ],
                stops: const [0.0, 0.72, 1.0],
              ),
              border: Border.all(color: tokens.border.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF66B8FF).withValues(alpha: 0.18),
                  blurRadius: 44,
                  spreadRadius: 2,
                ),
              ],
            ),
           
          ),
          // Positioned(
          //   top: size * 0.08,
          //   left: 0,
          //   child: TravelPill(
          //     text: 'Unity bridge target',
          //     fillColor: tokens.surface.withValues(alpha: 0.84),
          //     borderColor: tokens.border.withValues(alpha: 0.7),
          //     textColor: tokens.textPrimary,
          //   ),
          // ),
          // if (userLabel != null)
          //   Positioned(
          //     bottom: size * 0.12,
          //     right: size * 0.02,
          //     child: TravelPill(
          //       text: userLabel!,
          //       fillColor: tokens.background.withValues(alpha: 0.9),
          //       borderColor: const Color(0xFF7AB8FF).withValues(alpha: 0.5),
          //       textColor: tokens.textPrimary,
          //       icon: Icons.near_me_outlined,
          //     ),
          //   ),
        ],
      ),
    );
  }
}
