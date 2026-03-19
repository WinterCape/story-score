import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final storyTheme = context.storyTheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: storyTheme.surfaceColor,
        indicatorColor: storyTheme.primaryAccent.withValues(alpha: 0.15),
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
                size: 24, color: storyTheme.secondaryText),
            selectedIcon: CustomIcon('scoreboard',
                size: 24, color: storyTheme.primaryAccent),
            label: l10n.scoreboard,
          ),
          NavigationDestination(
            icon: CustomIcon('play_round',
                size: 24, color: storyTheme.secondaryText),
            selectedIcon: CustomIcon('play_round',
                size: 24, color: storyTheme.primaryAccent),
            label: l10n.roundTab,
          ),
          NavigationDestination(
            icon: CustomIcon('history',
                size: 24, color: storyTheme.secondaryText),
            selectedIcon: CustomIcon('history',
                size: 24, color: storyTheme.primaryAccent),
            label: l10n.history,
          ),
        ],
      ),
    );
  }
}
