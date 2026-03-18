import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/domain/stats/stats_models.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/stats/providers/stats_providers.dart';
import 'package:story_score/features/stats/widgets/player_detail_sheet.dart';
import 'package:story_score/features/stats/widgets/win_rate_bar_chart.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Premium-gated stats screen with Leaderboard and Players tabs.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSupporter = ref.watch(isSupporterProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Stats',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          bottom: TabBar(
            indicatorColor: context.storyTheme.goldAccent,
            labelColor: context.storyTheme.goldAccent,
            unselectedLabelColor: context.colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(text: 'Leaderboard'),
              Tab(text: 'Players'),
            ],
          ),
        ),
        body: isSupporter
            ? const TabBarView(
                children: [
                  _LeaderboardTab(),
                  _PlayersTab(),
                ],
              )
            : _PremiumGateOverlay(
                child: const TabBarView(
                  children: [
                    _LeaderboardTab(),
                    _PlayersTab(),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Overlay that blurs the content and shows a CTA for free users.
class _PremiumGateOverlay extends StatelessWidget {
  const _PremiumGateOverlay({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final storyTheme = context.storyTheme;
    final textTheme = context.textTheme;

    return Stack(
      children: [
        // Blurred content behind
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: IgnorePointer(child: child),
        ),
        // CTA overlay
        Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 48,
                      color: storyTheme.goldAccent,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      'Advanced Stats',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      'Unlock leaderboards, player stats, win streaks, '
                      'and head-to-head records with the Supporter Pack.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton(
                      onPressed: () => context.push('/settings/premium'),
                      style: FilledButton.styleFrom(
                        backgroundColor: storyTheme.goldAccent,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Unlock with Supporter Pack'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Leaderboard tab: win rate chart + ranked list.
class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final textTheme = context.textTheme;
    final colors = context.colorScheme;
    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Failed to load leaderboard: $error'),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.leaderboard_rounded,
                    size: 64,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'No leaderboard yet',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Play at least 3 games with the same players '
                    'to see stats here.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            Text(
              'Win Rate',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: SpacingTokens.sm),
            WinRateBarChart(entries: entries),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              'Rankings',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: SpacingTokens.sm),
            ...entries.asMap().entries.map((e) {
              final index = e.key;
              final entry = e.value;
              return _LeaderboardTile(
                rank: index + 1,
                entry: entry,
                color: _colorForIndex(index),
              );
            }),
          ],
        );
      },
    );
  }

  Color _colorForIndex(int index) {
    final keys = PlayerColors.orderedKeys;
    if (index < keys.length) {
      return PlayerColors.colorFor(keys[index]);
    }
    return PlayerColors.all.values.elementAt(index % PlayerColors.all.length);
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.color,
  });

  final int rank;
  final LeaderboardEntry entry;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colorScheme;
    final storyTheme = context.storyTheme;

    return Card(
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '#$rank',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3
                      ? storyTheme.goldAccent
                      : colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            CircleAvatar(
              radius: 16,
              backgroundColor: color,
              child: Text(
                entry.displayName.isNotEmpty
                    ? entry.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          entry.displayName,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${entry.wins}W / ${entry.gamesPlayed}G',
          style: textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          '${(entry.winRate * 100).toStringAsFixed(0)}%',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: storyTheme.goldAccent,
          ),
        ),
        onTap: () => PlayerDetailSheet.show(
          context,
          displayName: entry.displayName,
          normalizedName: entry.normalizedName,
        ),
      ),
    );
  }
}

/// Players tab: list of all known players.
class _PlayersTab extends ConsumerWidget {
  const _PlayersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final textTheme = context.textTheme;
    final colors = context.colorScheme;

    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Failed to load players: $error'),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_rounded,
                    size: 64,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'No players yet',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    'Complete some games to see player stats.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Show all players, not just those meeting min games threshold
        // by using a separate provider or just displaying leaderboard entries
        return ListView.builder(
          padding: const EdgeInsets.all(SpacingTokens.md),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final color = _colorForIndex(index);
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: color,
                  child: Text(
                    entry.displayName.isNotEmpty
                        ? entry.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                title: Text(
                  entry.displayName,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${entry.gamesPlayed} games  |  '
                  '${entry.wins} wins  |  '
                  '${entry.totalPoints} pts',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => PlayerDetailSheet.show(
                  context,
                  displayName: entry.displayName,
                  normalizedName: entry.normalizedName,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _colorForIndex(int index) {
    final keys = PlayerColors.orderedKeys;
    if (index < keys.length) {
      return PlayerColors.colorFor(keys[index]);
    }
    return PlayerColors.all.values.elementAt(index % PlayerColors.all.length);
  }
}
