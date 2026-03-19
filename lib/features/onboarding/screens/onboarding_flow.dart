import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:story_score/app/theme/color_tokens.dart';
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
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final pages = [
      _OnboardingPageData(
        illustration: AppAssets.onboarding1,
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
      ),
      _OnboardingPageData(
        illustration: AppAssets.onboarding2,
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
      ),
      _OnboardingPageData(
        illustration: AppAssets.onboarding3,
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
              // Pages — illustration at top, text below
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (page) =>
                      setState(() => _currentPage = page),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    final page = pages[index];
                    return Column(
                      children: [
                        const SizedBox(height: SpacingTokens.xl),

                        // Large illustration at top
                        Image.asset(
                          page.illustration,
                          width: 330,
                          height: 206,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox(
                            width: 330,
                            height: 206,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xl),

                        // Title: parchment, 26px, extrabold
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.lg,
                          ),
                          child: Text(
                            page.title,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: ColorTokens.parchment,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.md),

                        // Description: muted text
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.lg,
                          ),
                          child: Text(
                            page.body,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: ColorTokens.mutedText,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Page dots centered
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
                          : ColorTokens.mutedText.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Bottom row: gradient button left + Skip text right
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg,
                ),
                child: Row(
                  children: [
                    // Gradient "Next" / "Get Started" button
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            ColorTokens.burgundy,
                            ColorTokens.goldAccent,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLastPage
                              ? _finishOnboarding
                              : () => _controller.nextPage(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                  ),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SpacingTokens.xl,
                            ),
                            child: Center(
                              child: Text(
                                isLastPage
                                    ? l10n.letsPlay
                                    : l10n.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // "Skip" text button
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        l10n.skip,
                        style: const TextStyle(
                          color: ColorTokens.mutedText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String illustration;
  final String title;
  final String body;

  const _OnboardingPageData({
    required this.illustration,
    required this.title,
    required this.body,
  });
}
