import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/features/history/providers/history_providers.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A list tile displaying a single round's summary in the history list.
class RoundHistoryTile extends ConsumerWidget {
  const RoundHistoryTile({
    super.key,
    required this.round,
    required this.sessionId,
    required this.onTap,
  });

  final Round round;
  final String sessionId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colorScheme;
    final text = context.textTheme;

    // Watch players for the session so we can resolve the storyteller name
    final playersAsync = ref
        .watch(sessionDaoProvider)
        .watchPlayersForSession(sessionId);

    // Watch round details for score totals
    final detailsAsync = ref.watch(roundWithDetailsProvider(round.id));

    return Container(
      clipBehavior: Clip.antiAlias,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm + 4,
          ),
          child: Row(
            children: [
              // Round number circle in gold
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      ColorTokens.goldAccent.withValues(alpha: 0.2),
                      ColorTokens.goldAccent.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: ColorTokens.goldAccent.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${round.roundNumber}',
                  style: text.titleSmall?.copyWith(
                    color: ColorTokens.goldAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),

              // Round info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Storyteller name in parchment
                    StreamBuilder<List<Player>>(
                      stream: playersAsync,
                      builder: (context, snapshot) {
                        final players = snapshot.data ?? [];
                        final storyteller = players
                            .where((p) => p.id == round.storytellerPlayerId)
                            .firstOrNull;
                        return Text(
                          storyteller?.name ?? 'Unknown',
                          style: text.titleSmall?.copyWith(
                            color: ColorTokens.parchment,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    const SizedBox(height: 2),

                    // Score info and outcome: gold for good clue, rose for bad
                    detailsAsync.when(
                      data: (details) {
                        if (details == null) {
                          return const SizedBox.shrink();
                        }
                        final totalPoints = details.scoreChanges.fold<int>(
                          0,
                          (sum, sc) => sum + sc.delta,
                        );

                        final hasGoodClue = details.scoreChanges.any(
                          (sc) => sc.reasonCode == 'storytellerGoodClue',
                        );

                        return Row(
                          children: [
                            Icon(
                              hasGoodClue
                                  ? Icons.lightbulb_rounded
                                  : Icons.lightbulb_outline_rounded,
                              size: 14,
                              color: hasGoodClue
                                  ? ColorTokens.goldAccent
                                  : ColorTokens.dustyRose,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasGoodClue ? 'Good clue' : 'Bad clue',
                              style: text.bodySmall?.copyWith(
                                color: hasGoodClue
                                    ? ColorTokens.goldAccent
                                    : ColorTokens.dustyRose,
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.md),
                            Text(
                              '+$totalPoints pts',
                              style: text.bodySmall?.copyWith(
                                color: ColorTokens.mutedText,
                              ),
                            ),
                            if (round.editedAt != null) ...[
                              const SizedBox(width: SpacingTokens.sm),
                              Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: colors.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      loading: () => const SizedBox(height: 16, width: 80),
                      error: (_, _) => Text(
                        'Error loading details',
                        style: text.bodySmall?.copyWith(color: colors.error),
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: ColorTokens.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
