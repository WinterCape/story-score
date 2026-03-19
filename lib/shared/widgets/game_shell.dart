import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';
import 'package:story_score/shared/widgets/custom_icon.dart';

/// Shell widget providing bottom navigation for in-game screens
/// (Scores, Round, History). Matches mockup with 68px height and
/// parchment selected state.
class GameShell extends StatelessWidget {
  const GameShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 68 + MediaQuery.of(context).viewPadding.bottom,
        decoration: BoxDecoration(
          color: ColorTokens.darkSurface,
          border: const Border(
            top: BorderSide(
              color: ColorTokens.goldAccent,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: 'scoreboard',
                label: l10n.scoreboard.substring(0, 6),
                isSelected: currentIndex == 0,
                onTap: () => navigationShell.goBranch(
                  0,
                  initialLocation: currentIndex == 0,
                ),
              ),
              _NavItem(
                icon: 'play_round',
                label: l10n.roundTab,
                isSelected: currentIndex == 1,
                onTap: () => navigationShell.goBranch(
                  1,
                  initialLocation: currentIndex == 1,
                ),
              ),
              _NavItem(
                icon: 'history',
                label: l10n.history,
                isSelected: currentIndex == 2,
                onTap: () => navigationShell.goBranch(
                  2,
                  initialLocation: currentIndex == 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.sm,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: ColorTokens.parchment.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ColorTokens.parchment.withValues(alpha: 0.2),
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIcon(
              icon,
              size: 22,
              color: isSelected
                  ? ColorTokens.goldAccent
                  : ColorTokens.mutedText,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? ColorTokens.goldAccent
                    : ColorTokens.mutedText,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
