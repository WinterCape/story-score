import 'package:flutter/material.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';
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

    final totalPoints = result.scoreEntries.fold<int>(
      0,
      (sum, e) => sum + e.delta,
    );

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

            // Outcome icon + header
            Row(
              children: [
                Image.asset(
                  isGoodClue ? AppAssets.clueGood : AppAssets.clueBad,
                  width: 32,
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            ? 'The table found the sweet spot this round.'
                            : 'Everyone or nobody guessed correctly.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: ColorTokens.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.lg),

            // Per-player score changes — simple rows
            ...playerDeltas.entries.map((entry) {
              final player = players
                  .where((p) => p.id == entry.key)
                  .firstOrNull;
              if (player == null) return const SizedBox.shrink();

              final totalDelta = entry.value.fold<int>(
                0,
                (sum, e) => sum + e.delta,
              );

              // Build reason summary text
              final reasonText = totalDelta > 0
                  ? entry.value
                      .where((e) => e.delta > 0)
                      .map((e) => '+${e.delta} ${e.reason.label}')
                      .join(', ')
                  : 'No points';

              return _PlayerRecapRow(
                player: player,
                reasonText: reasonText,
                totalDelta: totalDelta,
              );
            }),

            const SizedBox(height: SpacingTokens.lg),

            // Ornate divider
            Image.asset(AppAssets.dividerOrnate, width: 200),
            const SizedBox(height: SpacingTokens.sm),

            // Total points summary
            Text(
              '$totalPoints total points awarded',
              style: context.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.goldAccent,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: SpacingTokens.lg),

            // Continue button with gradient
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [ColorTokens.goldAccent, ColorTokens.burgundy],
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
    required this.reasonText,
    required this.totalDelta,
  });

  final Player player;
  final String reasonText;
  final int totalDelta;

  @override
  Widget build(BuildContext context) {
    final playerColor = PlayerColors.colorFor(player.colorKey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs + 2),
      child: Row(
        children: [
          // Player avatar circle
          Container(
            width: 32,
            height: 32,
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
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: ColorTokens.parchment,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  reasonText,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: ColorTokens.mutedText,
                  ),
                ),
              ],
            ),
          ),
          // Delta
          Text(
            '+$totalDelta',
            style: context.textTheme.titleMedium?.copyWith(
              color: totalDelta > 0
                  ? ColorTokens.goldAccent
                  : ColorTokens.parchment,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
