import 'package:flutter/material.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/domain/stats/stats_models.dart';
import 'package:story_score/features/stats/widgets/stat_card.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Column of [StatCard] widgets showing session-level stats.
///
/// Free for all users (not premium-gated).
class SessionStatsSection extends StatelessWidget {
  const SessionStatsSection({super.key, required this.stats});

  final SessionStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.xs,
            bottom: SpacingTokens.sm,
          ),
          child: Text('Game Stats', style: context.textTheme.titleMedium),
        ),
        StatCard(
          icon: Icons.emoji_events_rounded,
          label: 'MVP',
          value: stats.mvpName.isNotEmpty ? stats.mvpName : '--',
          subtitle: stats.mvpScore > 0 ? '${stats.mvpScore} points' : null,
          iconColor: ColorTokens.goldAccent,
        ),
        const SizedBox(height: SpacingTokens.xs),
        StatCard(
          icon: Icons.trending_up_rounded,
          label: 'Best Round',
          value: stats.bestRound > 0 ? 'Round ${stats.bestRound}' : '--',
          iconColor: ColorTokens.teal,
        ),
        const SizedBox(height: SpacingTokens.xs),
        StatCard(
          icon: Icons.trending_down_rounded,
          label: 'Worst Round',
          value: stats.worstRound > 0 ? 'Round ${stats.worstRound}' : '--',
          iconColor: ColorTokens.coral,
        ),
        const SizedBox(height: SpacingTokens.xs),
        StatCard(
          icon: Icons.gps_fixed_rounded,
          label: 'Guess Accuracy',
          value: '${(stats.guessAccuracy * 100).round()}%',
          subtitle: '${stats.totalBonusPoints} bonus points earned',
          iconColor: ColorTokens.teal,
        ),
        const SizedBox(height: SpacingTokens.xs),
        StatCard(
          icon: Icons.auto_stories_outlined,
          label: 'Storyteller Success',
          value: '${(stats.storytellerSuccessRate * 100).round()}%',
          subtitle: 'good clue rate',
          iconColor: ColorTokens.violet,
        ),
      ],
    );
  }
}
