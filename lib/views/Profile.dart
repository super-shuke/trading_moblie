import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/store/common/common_store.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/store/user/user_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final travelStore = TravelStoreScope.of(context);
    final userStore = UserStoreScope.of(context);
    final commonStore = CommonStoreScope.of(context);
    final profile = travelStore.profile;
    final name = userStore.isLoggedIn ? userStore.username : profile.name;
    final initials = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GeoBackground(
        child: SafeArea(
          bottom: false,
          child: GeoContent(
            maxWidth: 720,
            child: ListView(
              padding: const EdgeInsets.only(top: 26, bottom: 112),
              children: [
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              tokens.brand.withValues(alpha: 0.44),
                              tokens.surfaceElevated,
                            ],
                          ),
                          border: Border.all(color: tokens.brand, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: tokens.brand.withValues(alpha: 0.2),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: Text(
                          initials.isEmpty ? 'GT' : initials,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: tokens.brand),
                        ),
                      ),
                      Positioned(
                        right: -3,
                        bottom: 2,
                        child: Material(
                          color: tokens.brand,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => context.push('/profile/edit'),
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: tokens.background,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  userStore.email.isEmpty
                      ? 'Traveling thoughtfully since 2024'
                      : userStore.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 22),
                GeoGlassCard(
                  child: Row(
                    children: [
                      _Stat(
                        value: '${profile.countriesVisited}',
                        label: 'Countries',
                      ),
                      _StatDivider(color: tokens.border),
                      _Stat(value: '${profile.citiesVisited}', label: 'Places'),
                      _StatDivider(color: tokens.border),
                      _Stat(
                        value: '${profile.visitedCityIds.length}',
                        label: 'Trips',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GeoGlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsRow(
                        label: 'Edit profile',
                        onTap: () => context.push('/profile/edit'),
                      ),
                      _SettingsDivider(color: tokens.border),
                      _SettingsRow(
                        label: 'Travel history',
                        trailing: '${travelStore.travelRecords.length}  ›',
                        onTap: () => context.push('/profile/history'),
                      ),
                      _SettingsDivider(color: tokens.border),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Expanded(child: Text('Language')),
                            SegmentedButton<String>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(value: 'en', label: Text('EN')),
                                ButtonSegment(value: 'zh', label: Text('中文')),
                              ],
                              selected: {
                                commonStore.locale?.languageCode ?? 'en',
                              },
                              onSelectionChanged: (value) =>
                                  commonStore.setLocale(Locale(value.first)),
                            ),
                          ],
                        ),
                      ),
                      _SettingsDivider(color: tokens.border),
                      _SettingsRow(
                        label: 'Appearance',
                        trailing: commonStore.themeMode == ThemeMode.dark
                            ? 'Dark  ›'
                            : 'Light  ›',
                        onTap: commonStore.toggleLightDark,
                      ),
                      _SettingsDivider(color: tokens.border),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 7, 8, 7),
                        child: Row(
                          children: [
                            const Expanded(child: Text('Notifications')),
                            Switch.adaptive(
                              value: _notifications,
                              onChanged: (value) =>
                                  setState(() => _notifications = value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.priceDown,
                    side: BorderSide(
                      color: tokens.priceDown.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    userStore.logout();
                    context.go('/login');
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          TravelLabel(label, size: 9),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final Color color;

  const _StatDivider({required this.color});

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 50, color: color);
}

class _SettingsDivider extends StatelessWidget {
  final Color color;

  const _SettingsDivider({required this.color});

  @override
  Widget build(BuildContext context) => Divider(height: 1, color: color);
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String trailing;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.label,
    this.trailing = '›',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(trailing, style: TextStyle(color: tokens.textMuted)),
          ],
        ),
      ),
    );
  }
}
