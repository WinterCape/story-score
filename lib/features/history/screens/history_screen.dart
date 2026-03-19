import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorTokens.darkBackground,
              ColorTokens.darkSurface,
              ColorTokens.darkCard,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Large title header (no AppBar)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.lg,
                    SpacingTokens.md,
                    SpacingTokens.lg,
                    SpacingTokens.md,
                  ),
                  child: Text(
                    l10n.roundHistory,
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: ColorTokens.goldAccent,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: roundsAsync.when(
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
                        // Undo Last Round card
                        if (rounds.isNotEmpty)
                          _UndoLastRoundCard(
                            onTap: () =>
                                _confirmUndoLastRound(context, ref),
                          ),

                        // Round list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.all(SpacingTokens.md),
                          itemCount: rounds.length,
                          itemBuilder: (context, index) {
                            final round =
                                rounds[rounds.length - 1 - index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: SpacingTokens.sm,
                              ),
                              child: RoundHistoryTile(
                                round: round,
                                sessionId: sessionId,
                                onTap: () => context.push(
                                  '/game/$sessionId/round/${round.id}',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                  loading: () => _buildLoadingSkeleton(context),
                  error: (error, _) => _buildError(context, error),
                ),
              ),
            ],
          ),
        ),
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
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ColorTokens.darkCard,
                    ColorTokens.darkCardVariant,
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusLg),
              ),
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
              style: context.textTheme.titleMedium?.copyWith(
                color: ColorTokens.parchment,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                color: ColorTokens.mutedText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card for "Undo Last Round" with card-frame-style icon.
class _UndoLastRoundCard extends StatelessWidget {
  const _UndoLastRoundCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      child: GestureDetector(
        onTap: onTap,
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
              color: ColorTokens.goldAccent.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Card frame icon
              Image.asset(AppAssets.cardFrameSmall, width: 40),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.undoLastRound,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: ColorTokens.parchment,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Restore round before editing',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: ColorTokens.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
