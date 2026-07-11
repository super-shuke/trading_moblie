import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/route/routers.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  void _goTo(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 900;
        if (useRail) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Row(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _DesktopRail(
                      selectedIndex: navigationShell.currentIndex,
                      onTap: _goTo,
                    ),
                  ),
                ),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: navigationShell,
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: _FloatingNavigation(
              selectedIndex: navigationShell.currentIndex,
              onTap: _goTo,
            ),
          ),
        );
      },
    );
  }
}

class _FloatingNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavigation({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: tokens.background.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: tabRoutes.asMap().entries.map((entry) {
              final selected = entry.key == selectedIndex;
              return Expanded(
                child: Semantics(
                  selected: selected,
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: ValueKey('bottom-nav-${entry.value['name']}'),
                      onTap: () => onTap(entry.key),
                      splashColor: tokens.brand.withValues(alpha: 0.2),
                      child: AnimatedContainer(
                        height: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: selected
                              ? tokens.brand.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: selected
                                ? tokens.brand.withValues(alpha: 0.38)
                                : Colors.transparent,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: tokens.brand.withValues(alpha: 0.12),
                                    blurRadius: 14,
                                  ),
                                ]
                              : const [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              entry.value['icon'] as IconData,
                              size: 20,
                              color: selected ? tokens.brand : tokens.textMuted,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                entry.value['name'] as String,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      color: selected
                                          ? tokens.brand
                                          : tokens.textMuted,
                                      fontSize: 10.5,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _DesktopRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _DesktopRail({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: tokens.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Icon(Icons.public, color: tokens.brand, size: 30),
          const SizedBox(height: 36),
          for (final entry in tabRoutes.asMap().entries) ...[
            _RailItem(
              icon: entry.value['icon'] as IconData,
              label: entry.value['name'] as String,
              selected: entry.key == selectedIndex,
              onTap: () => onTap(entry.key),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: tokens.brand.withValues(alpha: 0.2),
        child: AnimatedContainer(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: selected
                ? tokens.brand.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? tokens.brand.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? tokens.brand : tokens.textMuted),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? tokens.brand : tokens.textMuted,
                  fontSize: 9,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
