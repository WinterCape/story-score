import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/domain/stats/stats_calculator.dart';
import 'package:story_score/domain/stats/stats_models.dart';
import 'package:story_score/features/stats/providers/stats_providers.dart';
import 'package:story_score/features/stats/widgets/head_to_head_card.dart';
import 'package:story_score/features/stats/widgets/stat_card.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Bottom sheet showing all-time stats for a single player.
class PlayerDetailSheet extends ConsumerWidget {
  const PlayerDetailSheet({
    super.key,
    required this.displayName,
    required this.normalizedName,
  });

  final String displayName;
  final String normalizedName;

  /// Shows this sheet as a modal bottom sheet.
  static void show(
    BuildContext context, {
    required String displayName,
    required String normalizedName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => PlayerDetailSheet(
          displayName: displayName,
          normalizedName: normalizedName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(allTimeStatsProvider(normalizedName));
    final textTheme = context.textTheme;
    final colors = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpacingTokens.radiusXl),
        ),
      ),
      child: statsAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(SpacingTokens.xxl),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xxl),
            child: Text('Failed to load stats: $error'),
          ),
        ),
        data: (stats) => _buildContent(context, ref, stats, textTheme, colors),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    PlayerAllTimeStats stats,
    TextTheme textTheme,
    ColorScheme colors,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      children: [
        // Drag handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: SpacingTokens.sm),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Player name
        Text(
          displayName,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          '${stats.gamesPlayed} games played',
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Core stats
        StatCard(
          icon: Icons.emoji_events_rounded,
          label: 'Wins',
          value: '${stats.wins}',
          subtitle: 'Win rate: ${(stats.winRate * 100).toStringAsFixed(0)}%',
          iconColor: ColorTokens.goldAccent,
        ),
        const SizedBox(height: SpacingTokens.xs),
        StatCard(
          icon: Icons.score_rounded,
          label: 'Average Score',
          value: stats.avgScore.toStringAsFixed(1),
          subtitle: 'Best: ${stats.bestGameScore}',
          iconColor: ColorTokens.teal,
        ),
        const SizedBox(height: SpacingTokens.xs),
        StatCard(
          icon: Icons.bolt_rounded,
          label: 'Total Points',
          value: '${stats.totalPoints}',
          iconColor: ColorTokens.violet,
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Streaks
        Text('Streaks', style: textTheme.titleMedium),
        const SizedBox(height: SpacingTokens.sm),
        StatCard(
          icon: Icons.local_fire_department_rounded,
          label: 'Current Win Streak',
          value: '${stats.currentWinStreak}',
          iconColor: ColorTokens.coral,
        ),
        const SizedBox(height: SpacingTokens.xs),
        StatCard(
          icon: Icons.stars_rounded,
          label: 'Longest Win Streak',
          value: '${stats.longestWinStreak}',
          iconColor: ColorTokens.goldAccent,
        ),
        const SizedBox(height: SpacingTokens.xs),
        StatCard(
          icon: Icons.hourglass_bottom_rounded,
          label: 'Games Since Last Win',
          value: '${stats.gamesSinceLastWin}',
          iconColor: colors.onSurfaceVariant,
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Head-to-head records
        _HeadToHeadSection(normalizedName: normalizedName),
        const SizedBox(height: SpacingTokens.xxl),
      ],
    );
  }
}

/// Fetches and displays head-to-head records for a player.
class _HeadToHeadSection extends ConsumerWidget {
  const _HeadToHeadSection({required this.normalizedName});
  final String normalizedName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return leaderboardAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (entries) {
        // Get all other players from the leaderboard
        final opponents = entries
            .where((e) => e.normalizedName != normalizedName)
            .toList();
        if (opponents.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Head-to-Head', style: context.textTheme.titleMedium),
            const SizedBox(height: SpacingTokens.sm),
            _HeadToHeadList(
              normalizedName: normalizedName,
              opponents: opponents,
            ),
          ],
        );
      },
    );
  }
}

class _HeadToHeadList extends ConsumerWidget {
  const _HeadToHeadList({
    required this.normalizedName,
    required this.opponents,
  });

  final String normalizedName;
  final List<LeaderboardEntry> opponents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<HeadToHeadRecord>>(
      future: _computeRecords(ref),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final records = snapshot.data!.where((r) => r.sharedGames > 0).toList();
        if (records.isEmpty) {
          return Text(
            'No head-to-head records yet',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          );
        }
        return Column(
          children: records
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                  child: HeadToHeadCard(record: r),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<List<HeadToHeadRecord>> _computeRecords(WidgetRef ref) async {
    final service = ref.read(statsServiceProvider);
    final allGames = await service.fetchAllCompletedGames();

    return opponents.map((opponent) {
      final sharedGames = allGames
          .where(
            (g) =>
                g.players.any((p) => p.normalizedName == normalizedName) &&
                g.players.any(
                  (p) => p.normalizedName == opponent.normalizedName,
                ),
          )
          .toList();
      return StatsCalculator.computeHeadToHead(
        playerA: normalizedName,
        playerB: opponent.displayName,
        sharedGames: sharedGames,
      );
    }).toList();
  }
}
