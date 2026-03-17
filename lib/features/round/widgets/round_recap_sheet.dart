import 'package:flutter/material.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/domain/scoring/score_reason.dart';
import 'package:story_score/domain/scoring/scoring_engine.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Bottom sheet displaying round results after scoring.
class RoundRecapSheet extends StatelessWidget {
  const RoundRecapSheet({
    super.key,
    required this.result,
    required this.players,
    required this.onContinue,
  });

  final RoundResult result;

  /// All players in the session (used to look up names/colors).
  final List<Player> players;

  /// Called when the user dismisses the recap.
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    // Group score entries by player
    final playerDeltas = <String, List<ScoreEntry>>{};
    for (final entry in result.scoreEntries) {
      playerDeltas.putIfAbsent(entry.playerId, () => []).add(entry);
    }

    final isGoodClue = result.clueOutcome == ClueOutcome.goodClue;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg,
          SpacingTokens.md,
          SpacingTokens.lg,
          SpacingTokens.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Outcome header
            Icon(
              isGoodClue ? Icons.star : Icons.sentiment_dissatisfied,
              size: 40,
              color: isGoodClue
                  ? context.storyTheme.goldAccent
                  : ColorTokens.coralAccent,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              isGoodClue ? 'Good Clue!' : 'Bad Clue!',
              style: context.textTheme.headlineSmall?.copyWith(
                color: isGoodClue
                    ? context.storyTheme.goldAccent
                    : ColorTokens.coralAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isGoodClue
                  ? 'Some players guessed correctly'
                  : 'Everyone or nobody guessed correctly',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Per-player score changes
            ...playerDeltas.entries.map((entry) {
              final player = players
                  .where((p) => p.id == entry.key)
                  .firstOrNull;
              if (player == null) return const SizedBox.shrink();

              final totalDelta = entry.value.fold<int>(
                0,
                (sum, e) => sum + e.delta,
              );

              return _PlayerRecapRow(
                player: player,
                entries: entry.value,
                totalDelta: totalDelta,
              );
            }),

            const SizedBox(height: SpacingTokens.lg),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: context.storyTheme.goldAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: SpacingTokens.md,
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerRecapRow extends StatelessWidget {
  const _PlayerRecapRow({
    required this.player,
    required this.entries,
    required this.totalDelta,
  });

  final Player player;
  final List<ScoreEntry> entries;
  final int totalDelta;

  @override
  Widget build(BuildContext context) {
    final playerColor = PlayerColors.colorFor(player.colorKey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        ),
        child: Row(
          children: [
            // Color dot + name
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: playerColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: context.textTheme.titleSmall,
                  ),
                  // Reason labels
                  Wrap(
                    spacing: SpacingTokens.sm,
                    children: entries.map((e) {
                      return Text(
                        '+${e.delta} ${e.reason.label}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Total delta
            Text(
              '+$totalDelta',
              style: context.textTheme.titleLarge?.copyWith(
                color: totalDelta > 0
                    ? ColorTokens.auroraGreen
                    : context.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the round recap as a modal bottom sheet. Returns when dismissed.
Future<void> showRoundRecapSheet({
  required BuildContext context,
  required RoundResult result,
  required List<Player> players,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (sheetContext) => RoundRecapSheet(
      result: result,
      players: players,
      onContinue: () => Navigator.of(sheetContext).pop(),
    ),
  );
}
