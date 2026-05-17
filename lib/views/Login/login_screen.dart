import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:traveling_app/component/travel/earth_globe.dart';
import 'package:traveling_app/component/travel/kit.dart';
import 'package:traveling_app/service/google_auth_service.dart';
// import 'package:traveling_app/store/common/common_store.dart';
import 'package:traveling_app/store/travel/travel_store.dart';
import 'package:traveling_app/store/user/user_store.dart';
import 'package:traveling_app/styles/buttonStyle/index.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _requestedLocation = false;
  bool _isSigningIn = false;
  String? _errorMessage;

  Future<void> _signInWithGoogle() async {
    if (_isSigningIn) {
      return;
    }

    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final user = await GoogleAuthService.instance.signIn();
      if (!mounted) {
        return;
      }

      UserStoreScope.of(context).login(user.displayName, email: user.email);
      context.go('/explore');
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Google 登录失败，请检查 client ID 配置后重试。\n$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppCommon>()!;
    final titleStyle = Theme.of(context).textTheme.displayLarge;
    final bodyStyle = Theme.of(context).textTheme.bodyLarge;
    final travelStore = TravelStoreScope.of(context);

    if (!_requestedLocation && !travelStore.hasRequestedLocation) {
      _requestedLocation = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        await travelStore.requestUserLocation();
      });
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const TravelPlaceholderImage(
            seed: 'login-hero',
            radius: BorderRadius.zero,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  tokens.background.withValues(alpha: 0.16),
                  tokens.background.withValues(alpha: 0.56),
                  tokens.background,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 920;
                final horizontalPadding = isWide ? 40.0 : 24.0;
                final globeSize = isWide
                    ? 360.0
                    : constraints.maxWidth.clamp(300.0, 375.0).toDouble();

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),

                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      scrollbars: false, // 不显示滚动条
                      overscroll: false, // 也不显示 Android 的边缘过度滚动效果
                      physics:
                          const BouncingScrollPhysics(), // 可选：用 iOS 风格的弹性滚动
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TravelLocationIcon(
                            location: travelStore.userLocation.city,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 260,
                            child: OverflowBox(
                              maxHeight: 338,
                              alignment: Alignment.topCenter,
                              child: _LoginGlobeStage(
                                tokens: tokens,
                                store: travelStore,
                                globeSize: globeSize,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _LoginHero(
                                tokens: tokens,
                                titleStyle: titleStyle,
                                bodyStyle: bodyStyle,
                                compact: true,
                              ),
                              const SizedBox(height: 30),
                              _LoginCard(
                                tokens: tokens,
                                isSigningIn: _isSigningIn,
                                errorMessage: _errorMessage,
                                onGoogleSignIn: _signInWithGoogle,
                                onContinueAsGuest: () {
                                  UserStoreScope.of(context).login('Guest');
                                  context.go('/explore');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  final AppCommon tokens;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;
  final bool compact;

  const _LoginHero({
    required this.tokens,
    required this.titleStyle,
    required this.bodyStyle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 520 : 620),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TravelSecondaryTitle(
            'EST. 20260 A LOCATIONS OS',
            color: tokens.textSecondary,
            size: 10,
          ),
          const SizedBox(height: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TravelCommonTitle(
                'Travel',
                size: 48,
                color: tokens.textPrimary,
                height: 0.95,
              ),
              TravelCommonTitle(
                'like a local',
                size: 48,
                color: tokens.textPrimarySameBtn,
                height: 0.95,
                fontStyle: FontStyle.italic,
              ),
              TravelCommonTitle(
                'knows it.',
                size: 48,
                color: tokens.textPrimary,
                height: 0.95,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 280,
            height: 64,
            child: Text(
              'A 3D map of every city worth visiting — with the tips, tricks and traps from people who actually went.',
              style: bodyStyle?.copyWith(
                color: tokens.textSecondary,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginGlobeStage extends StatelessWidget {
  final AppCommon tokens;
  final TravelStore store;
  final double globeSize;

  const _LoginGlobeStage({
    required this.tokens,
    required this.store,
    required this.globeSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        TravelEarthGlobe(
          size: globeSize,
          cities: store.cities,
          userLocation: store.userLocation,
          userLabel: store.isLocating ? null : store.userLocation.city,
          useUnity: true,
          camera: const UnityGlobeCamera(
            longitude: 115,
            latitude: 0,
            height: 30000000,
          ),
          autoRotate: true,
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  final AppCommon tokens;
  final bool isSigningIn;
  final String? errorMessage;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onContinueAsGuest;

  const _LoginCard({
    required this.tokens,
    required this.isSigningIn,
    required this.errorMessage,
    required this.onGoogleSignIn,
    required this.onContinueAsGuest,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: CommonButtonStyle.submitBtn(context).copyWith(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                  onPressed: isSigningIn ? null : onGoogleSignIn,
                  icon: isSigningIn
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.mail_outline),
                  label: TravelCommonTitle(
                    isSigningIn ? 'Signing in...' : 'Continue with Email',
                    size: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    isSystemFont: true,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: CommonButtonStyle.outlineBtn(context).copyWith(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                  onPressed: isSigningIn ? null : onContinueAsGuest,
                  child: TravelCommonTitle(
                    'Continue with Google',
                    size: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    isSystemFont: true,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 14,
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              'Skip — explore the map →',
              style: TextStyle(
                color: tokens.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: tokens.accentAlt.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(
                  color: tokens.accentAlt.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                errorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: tokens.textPrimary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
