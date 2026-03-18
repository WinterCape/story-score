import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';
import 'package:story_score/shared/widgets/custom_icon.dart';

/// Shell widget providing bottom navigation for in-game screens
/// (Scoreboard, Round, History).
class GameShell extends StatelessWidget {
  const GameShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: ColorTokens.darkSurface,
        indicatorColor: ColorTokens.goldAccent.withValues(alpha: 0.15),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: CustomIcon('scoreboard',
                size: 24, color: ColorTokens.mutedText),
            selectedIcon: const CustomIcon('scoreboard',
                size: 24, color: ColorTokens.goldAccent),
            label: l10n.scoreboard,
          ),
          NavigationDestination(
            icon: CustomIcon('play_round',
                size: 24, color: ColorTokens.mutedText),
            selectedIcon: const CustomIcon('play_round',
                size: 24, color: ColorTokens.goldAccent),
            label: l10n.roundTab,
          ),
          NavigationDestination(
            icon: CustomIcon('history',
                size: 24, color: ColorTokens.mutedText),
            selectedIcon: const CustomIcon('history',
                size: 24, color: ColorTokens.goldAccent),
            label: l10n.history,
          ),
        ],
      ),
    );
  }
}
