import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/features/history/providers/history_providers.dart';
import 'package:story_score/features/history/widgets/round_history_tile.dart';
import 'package:story_score/features/home/widgets/empty_state.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundsAsync = ref.watch(roundHistoryProvider(sessionId));
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/game/$sessionId/scoreboard'),
        ),
        title: Text(l10n.roundHistory),
      ),
      body: roundsAsync.when(
        data: (rounds) {
          if (rounds.isEmpty) {
            return EmptyState(
              icon: Icons.history_rounded,
              title: l10n.noRoundsYet,
              subtitle: l10n.noRoundsYetDescription,
            );
          }

          return Column(
            children: [
              // Undo Last Round button
              if (rounds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md,
                    SpacingTokens.sm,
                    SpacingTokens.md,
                    0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmUndoLastRound(context, ref),
                      icon: const Icon(Icons.undo_rounded, size: 18),
                      label: Text(l10n.undoLastRound),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colorScheme.error,
                        side: BorderSide(
                          color: context.colorScheme.error.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Round list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  itemCount: rounds.length,
                  itemBuilder: (context, index) {
                    // Show in reverse chronological order (newest first)
                    final round = rounds[rounds.length - 1 - index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                      child: RoundHistoryTile(
                        round: round,
                        sessionId: sessionId,
                        onTap: () =>
                            context.push('/game/$sessionId/round/${round.id}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => _buildLoadingSkeleton(context),
        error: (error, _) => _buildError(context, error),
      ),
    );
  }

  Future<void> _confirmUndoLastRound(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.undoLastRound),
        content: Text(l10n.undoLastRoundConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.undo),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Haptics.light();
      final undo = ref.read(undoLastRoundProvider);
      await undo(sessionId);
    }
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final colors = context.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: List.generate(
        5,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              l10n.failedToLoadHistory,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
