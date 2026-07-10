import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/geo_surface.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/store/user/user_store.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _didLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    final userStore = UserStoreScope.of(context);
    final fallback = TravelStoreScope.of(context).profile;
    _nameController.text = userStore.isLoggedIn
        ? userStore.username
        : fallback.name;
    _bioController.text = userStore.bio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    UserStoreScope.of(
      context,
    ).updateProfile(name: name, bio: _bioController.text.trim());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final initials = _nameController.text
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GeoBackground(
        child: SafeArea(
          child: GeoContent(
            maxWidth: 680,
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 30),
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Edit profile',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ElevatedButton(onPressed: _save, child: const Text('Save')),
                  ],
                ),
                const SizedBox(height: 34),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Choose a profile photo.'),
                                    ),
                                  ),
                              child: Container(
                                width: 108,
                                height: 108,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      tokens.brand.withValues(alpha: 0.46),
                                      tokens.surfaceElevated,
                                    ],
                                  ),
                                  border: Border.all(color: tokens.brand),
                                ),
                                child: Center(
                                  child: Text(
                                    initials.isEmpty ? 'GT' : initials,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(color: tokens.brand),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: IgnorePointer(
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: tokens.brand,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: tokens.background,
                                    width: 3,
                                  ),
                                ),
                                child: Icon(
                                  Icons.photo_camera_outlined,
                                  size: 16,
                                  color: tokens.background,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tap photo to change',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                const TravelLabel('NAME'),
                const SizedBox(height: 9),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Your name',
                  ),
                ),
                const SizedBox(height: 24),
                const TravelLabel('BIO'),
                const SizedBox(height: 9),
                TextField(
                  controller: _bioController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'A line about you',
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
