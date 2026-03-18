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
                color: ColorTokens.mutedText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Outcome header — gold for good, rose for bad
            Icon(
              isGoodClue ? Icons.star : Icons.sentiment_dissatisfied,
              size: 40,
              color: isGoodClue
                  ? ColorTokens.goldAccent
                  : ColorTokens.dustyRose,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              isGoodClue ? 'Good Clue!' : 'Bad Clue!',
              style: context.textTheme.headlineSmall?.copyWith(
                color: isGoodClue
                    ? ColorTokens.goldAccent
                    : ColorTokens.dustyRose,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isGoodClue
                  ? 'Some players guessed correctly'
                  : 'Everyone or nobody guessed correctly',
              style: context.textTheme.bodySmall?.copyWith(
                color: ColorTokens.mutedText,
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Ornate gold divider
            Container(
              width: 120,
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    ColorTokens.goldAccent,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Per-player score changes in warm styled rows
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

            // Continue button with gradient
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ColorTokens.burgundy, ColorTokens.goldAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                ),
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.md,
                    ),
                  ),
                  child: const Text('Continue'),
                ),
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            // Gradient avatar circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    playerColor,
                    playerColor.withValues(alpha: 0.7),
                  ],
                ),
                border: Border.all(
                  color: playerColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: player.avatarStyle != 'initials' &&
                      player.avatarStyle.isNotEmpty
                  ? Text(
                      player.avatarStyle,
                      style: const TextStyle(fontSize: 14),
                    )
                  : Text(
                      player.name.isNotEmpty
                          ? player.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: ColorTokens.parchment,
                    ),
                  ),
                  // Reason labels
                  Wrap(
                    spacing: SpacingTokens.sm,
                    children: entries.map((e) {
                      return Text(
                        '+${e.delta} ${e.reason.label}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: ColorTokens.mutedText,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            // Total delta — gold for positive
            Text(
              '+$totalDelta',
              style: context.textTheme.titleLarge?.copyWith(
                color: totalDelta > 0
                    ? ColorTokens.goldAccent
                    : ColorTokens.parchment,
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
