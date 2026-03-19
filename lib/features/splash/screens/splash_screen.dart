import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';

const _hasOnboardedKey = 'has_onboarded';

/// Splash / loading screen shown on app launch.
///
/// Displays the StoryScore logo with an ornate divider, subtitle, and
/// three pulsing gold dots. After a brief delay it navigates to either
/// onboarding or the home screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _dotController;

  @override
  void initState() {
    super.initState();

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool(_hasOnboardedKey) ?? false;

    if (!mounted) return;
    if (hasOnboarded) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorTokens.darkBackground,
              ColorTokens.darkSurface,
              ColorTokens.darkCard,
              ColorTokens.darkSurface,
              ColorTokens.darkBackground,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Sparkle decorations
            const _SplashSparkles(),

            // Centered content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ornate divider
                  Image.asset(
                    AppAssets.dividerOrnate,
                    width: 200,
                    color: ColorTokens.goldAccent,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 200,
                      height: 20,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // App title — gold serif style
                  const Text(
                    'StoryScore',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: ColorTokens.goldAccent,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  const Text(
                    'A magical companion for storytelling nights',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorTokens.mutedText,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            // Pulsing dots at the bottom
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _PulsingDots(controller: _dotController),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three pulsing gold dots used as a loading indicator.
class _PulsingDots extends StatelessWidget {
  const _PulsingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            // Stagger each dot by 0.2
            final phase = (controller.value + index * 0.2) % 1.0;
            final opacity = 0.3 + 0.7 * _pulse(phase);
            final scale = 0.8 + 0.4 * _pulse(phase);

            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorTokens.goldAccent.withValues(alpha: opacity),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  /// Smooth pulse curve: peaks at 0.5, troughs at 0.0 and 1.0
  double _pulse(double t) {
    return (1 - (2 * t - 1).abs()).clamp(0.0, 1.0);
  }
}

/// Decorative sparkle elements scattered across the splash background.
class _SplashSparkles extends StatelessWidget {
  const _SplashSparkles();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned(
            top: 80,
            right: 50,
            child: _SparkleChar(
              char: '\u2726',
              color: ColorTokens.goldAccent,
              opacity: 0.15,
              size: 10,
            ),
          ),
          Positioned(
            top: 200,
            left: 10,
            child: _SparkleChar(
              char: '\u2726',
              color: ColorTokens.goldAccent,
              opacity: 0.10,
              size: 14,
            ),
          ),
          Positioned(
            top: 160,
            right: 80,
            child: _SparkleChar(
              char: '\u25C7',
              color: ColorTokens.dustyRose,
              opacity: 0.08,
              size: 8,
            ),
          ),
          Positioned(
            bottom: 250,
            right: 40,
            child: _SparkleChar(
              char: '\u2726',
              color: ColorTokens.goldAccent,
              opacity: 0.12,
              size: 12,
            ),
          ),
          Positioned(
            bottom: 180,
            left: 60,
            child: _SparkleChar(
              char: '\u25C7',
              color: ColorTokens.dustyRose,
              opacity: 0.10,
              size: 10,
            ),
          ),
          Positioned(
            top: 350,
            left: 30,
            child: _SparkleChar(
              char: '\u25C7',
              color: ColorTokens.goldAccent,
              opacity: 0.08,
              size: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleChar extends StatelessWidget {
  const _SparkleChar({
    required this.char,
    required this.color,
    required this.opacity,
    required this.size,
  });

  final String char;
  final Color color;
  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Text(
        char,
        style: TextStyle(fontSize: size, color: color),
      ),
    );
  }
}
