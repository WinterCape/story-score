import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

const _hasOnboardedKey = 'has_onboarded';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasOnboardedKey, true);
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final pages = [
      _OnboardingPageData(
        icon: Icons.auto_stories_rounded,
        emoji: '\u{1F3AD}', // theater masks
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
      ),
      _OnboardingPageData(
        icon: Icons.touch_app_rounded,
        emoji: '\u{2728}', // sparkles
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
      ),
      _OnboardingPageData(
        icon: Icons.wifi_off_rounded,
        emoji: '\u{1F310}', // globe
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
      ),
    ];

    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorTokens.darkBackground,
              ColorTokens.darkSurface,
              ColorTokens.darkCard,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    l10n.skip,
                    style: const TextStyle(color: ColorTokens.mutedText),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.xxl,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Hero: 3 fanned card shapes
                          SizedBox(
                            height: 180,
                            width: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Left card (-10 degrees)
                                Positioned(
                                  left: 20,
                                  child: Transform.rotate(
                                    angle: -10 * math.pi / 180,
                                    child: _OnboardingCard(
                                      emoji: '\u{1F9D9}',
                                      size: 70,
                                      isCenter: false,
                                    ),
                                  ),
                                ),
                                // Right card (+10 degrees)
                                Positioned(
                                  right: 20,
                                  child: Transform.rotate(
                                    angle: 10 * math.pi / 180,
                                    child: _OnboardingCard(
                                      emoji: '\u{1F432}',
                                      size: 70,
                                      isCenter: false,
                                    ),
                                  ),
                                ),
                                // Center card (no rotation, bigger)
                                _OnboardingCard(
                                  emoji: page.emoji,
                                  size: 85,
                                  isCenter: true,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.xl),
                          // Title: gold, 26px, weight 800
                          Text(
                            'StoryScore',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: ColorTokens.goldAccent,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          Text(
                            page.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: ColorTokens.parchment,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          Text(
                            page.body,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: ColorTokens.dustyRose,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: SpacingTokens.xl),
                          // Feature list items with warm gradient icon tiles
                          _FeatureItem(
                            icon: page.icon,
                            title: page.title,
                            description: page.body,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page indicators + button
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Column(
                  children: [
                    // Gold page dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? ColorTokens.goldAccent
                                : ColorTokens.goldAccent
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.lg),

                    // CTA button with gradient (burgundy -> gold)
                    SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              ColorTokens.burgundy,
                              ColorTokens.goldAccent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(
                            SpacingTokens.radiusMd,
                          ),
                        ),
                        child: FilledButton(
                          onPressed: isLastPage
                              ? _finishOnboarding
                              : () => _controller.nextPage(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                  ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: SpacingTokens.md,
                            ),
                          ),
                          child: Text(
                            isLastPage ? l10n.letsPlay : l10n.next,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A card shape used in the onboarding hero section.
class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.emoji,
    required this.size,
    required this.isCenter,
  });

  final String emoji;
  final double size;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorTokens.lightBackground,
            ColorTokens.lightSurface,
            ColorTokens.lightCardBorder,
          ],
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: ColorTokens.goldAccent,
          width: isCenter ? 2 : 1,
        ),
        boxShadow: isCenter
            ? [
                BoxShadow(
                  color: ColorTokens.goldAccent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Color(0x4D000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : [
                const BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: TextStyle(fontSize: isCenter ? 32 : 24),
      ),
    );
  }
}

/// Feature list item with warm gradient icon tile.
class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorTokens.darkCard,
                ColorTokens.darkCardVariant,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorTokens.goldAccent.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: ColorTokens.goldAccent,
          ),
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: ColorTokens.parchment,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ColorTokens.mutedText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String emoji;
  final String title;
  final String body;

  const _OnboardingPageData({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.body,
  });
}
