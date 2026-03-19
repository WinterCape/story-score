import 'package:flutter/material.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';
import 'package:story_score/shared/widgets/custom_icon.dart';

/// Empty state for the home screen — matches the design mockup:
/// Centered illustration, gold uppercase header, muted subtitle,
/// full-width gradient CTA button pinned at the bottom.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Push content to center area
        const Spacer(flex: 2),

        // Centered illustration (212x212)
        Image.asset(
          AppAssets.emptyNoGames,
          width: 212,
          height: 212,
          errorBuilder: (_, _, _) => const SizedBox(width: 212, height: 212),
        ),
        const SizedBox(height: SpacingTokens.lg),

        // Gold uppercase section header
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: ColorTokens.goldAccent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: SpacingTokens.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
            child: Text(
              subtitle!,
              style: const TextStyle(
                color: ColorTokens.mutedText,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        const Spacer(flex: 3),

        // Full-width gradient CTA button at bottom
        if (actionLabel != null && onAction != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [ColorTokens.burgundy, ColorTokens.goldAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorTokens.burgundy.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAction,
                    borderRadius: BorderRadius.circular(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomIcon(
                          'new_game',
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(
                          actionLabel!,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: SpacingTokens.lg),
      ],
    );
  }
}
