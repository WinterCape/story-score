import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';
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
        illustration: AppAssets.onboarding1,
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
      ),
      _OnboardingPageData(
        icon: Icons.touch_app_rounded,
        illustration: AppAssets.onboarding2,
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
      ),
      _OnboardingPageData(
        icon: Icons.wifi_off_rounded,
        illustration: AppAssets.onboarding3,
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
      ),
    ];

    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.storyTheme.backgroundGradient,
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
                    style: TextStyle(color: context.storyTheme.secondaryText),
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
                          // Hero illustration
                          Image.asset(
                            page.illustration,
                            width: 280,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: SpacingTokens.xl),
                          // Title: gold, 26px, weight 800
                          Text(
                            'StoryScore',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: context.storyTheme.primaryAccent,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          Text(
                            page.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: context.storyTheme.primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: SpacingTokens.md),
                          Text(
                            page.body,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: context.storyTheme.dustyRose,
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
                                ? context.storyTheme.primaryAccent
                                : context.storyTheme.primaryAccent
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
                          gradient: context.storyTheme.accentGradient,
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
            gradient: context.storyTheme.cardGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.storyTheme.primaryAccent.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: context.storyTheme.primaryAccent,
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
                  color: context.storyTheme.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.storyTheme.secondaryText,
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
  final String illustration;
  final String title;
  final String body;

  const _OnboardingPageData({
    required this.icon,
    required this.illustration,
    required this.title,
    required this.body,
  });
}
