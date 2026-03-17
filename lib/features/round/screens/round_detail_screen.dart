import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/features/history/providers/history_providers.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Provides the players list for a given session.
final _playersForSessionProvider =
    StreamProvider.family<List<Player>, String>((ref, sessionId) {
  return ref.watch(sessionDaoProvider).watchPlayersForSession(sessionId);
});

class RoundDetailScreen extends ConsumerStatefulWidget {
  const RoundDetailScreen({
    super.key,
    required this.sessionId,
    required this.roundId,
  });

  final String sessionId;
  final String roundId;

  @override
  ConsumerState<RoundDetailScreen> createState() => _RoundDetailScreenState();
}

class _RoundDetailScreenState extends ConsumerState<RoundDetailScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(roundWithDetailsProvider(widget.roundId));
    final playersAsync =
        ref.watch(_playersForSessionProvider(widget.sessionId));

    final colors = context.colorScheme;
    final text = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Round Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: detailsAsync.when(
        data: (details) {
          if (details == null) {
            return const Center(child: Text('Round not found'));
          }

          final players = switch (playersAsync) {
            AsyncData(:final value) => value,
            _ => <Player>[],
          };
          final playerMap = {for (final p in players) p.id: p};
          final storyteller = playerMap[details.round.storytellerPlayerId];
          final hasGoodClue = details.scoreChanges
              .any((sc) => sc.reasonCode == 'storytellerGoodClue');

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              // Round header
              _RoundHeader(
                roundNumber: details.round.roundNumber,
                storytellerName: storyteller?.name ?? 'Unknown',
                storytellerColor: storyteller != null
                    ? PlayerColors.colorFor(storyteller.colorKey)
                    : colors.primary,
                hasGoodClue: hasGoodClue,
                note: details.round.note,
                editedAt: details.round.editedAt,
              ),
              const SizedBox(height: SpacingTokens.lg),

              // Votes section
              _SectionTitle(title: 'Votes'),
              const SizedBox(height: SpacingTokens.sm),
              ...details.votes.map((vote) {
                final voter = playerMap[vote.voterPlayerId];
                final votedFor = playerMap[vote.votedForPlayerId];
                final votedForStoryteller =
                    vote.votedForPlayerId == details.round.storytellerPlayerId;
                return _VoteTile(
                  voterName: voter?.name ?? 'Unknown',
                  voterColor: voter != null
                      ? PlayerColors.colorFor(voter.colorKey)
                      : colors.primary,
                  votedForName: votedFor?.name ?? 'Unknown',
                  isCorrect: votedForStoryteller,
                );
              }),
              const SizedBox(height: SpacingTokens.lg),

              // Score changes section
              _SectionTitle(title: 'Score Changes'),
              const SizedBox(height: SpacingTokens.sm),
              ..._groupScoreChangesByPlayer(details.scoreChanges, playerMap)
                  .entries
                  .map((entry) {
                final player = playerMap[entry.key];
                return _ScoreChangeTile(
                  playerName: player?.name ?? 'Unknown',
                  playerColor: player != null
                      ? PlayerColors.colorFor(player.colorKey)
                      : colors.primary,
                  changes: entry.value,
                );
              }),
              const SizedBox(height: SpacingTokens.xl),

              // Action buttons
              Row(
                children: [
                  // Delete button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isDeleting ? null : () => _confirmDelete(context),
                      icon: _isDeleting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.error,
                              ),
                            )
                          : const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete Round'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.error,
                        side: BorderSide(
                          color: colors.error.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xl),
            ],
          );
        },
        loading: () => _buildLoadingSkeleton(context),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: colors.error,
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'Failed to load round',
                  style: text.titleMedium,
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  error.toString(),
                  style: text.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<ScoreChange>> _groupScoreChangesByPlayer(
    List<ScoreChange> changes,
    Map<String, Player> playerMap,
  ) {
    final grouped = <String, List<ScoreChange>>{};
    for (final change in changes) {
      grouped.putIfAbsent(change.playerId, () => []).add(change);
    }
    return grouped;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Round'),
        content: const Text(
          'This will permanently delete this round and revert all '
          'score changes. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final deleteRound = ref.read(deleteRoundProvider);
      await deleteRound(
        roundId: widget.roundId,
        sessionId: widget.sessionId,
      );
      if (!mounted) return;
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to delete round: $e')),
      );
    }
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final colors = context.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: List.generate(
        4,
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
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({
    required this.roundNumber,
    required this.storytellerName,
    required this.storytellerColor,
    required this.hasGoodClue,
    required this.note,
    this.editedAt,
  });

  final int roundNumber;
  final String storytellerName;
  final Color storytellerColor;
  final bool hasGoodClue;
  final String note;
  final DateTime? editedAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final text = context.textTheme;
    final storyTheme = context.storyTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Round number and outcome
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primaryContainer,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$roundNumber',
                    style: text.titleLarge?.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Round $roundNumber',
                        style: text.titleMedium
                            ?.copyWith(color: colors.onSurface),
                      ),
                      Row(
                        children: [
                          Icon(
                            hasGoodClue
                                ? Icons.lightbulb_rounded
                                : Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: hasGoodClue
                                ? storyTheme.goldAccent
                                : colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasGoodClue ? 'Good clue' : 'Bad clue',
                            style: text.bodySmall?.copyWith(
                              color: hasGoodClue
                                  ? storyTheme.goldAccent
                                  : colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (editedAt != null)
                  Tooltip(
                    message: 'Edited',
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),

            // Storyteller info
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: storytellerColor.withValues(alpha: 0.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    storytellerName.isNotEmpty
                        ? storytellerName[0].toUpperCase()
                        : '?',
                    style: text.labelSmall?.copyWith(
                      color: storytellerColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  'Storyteller: $storytellerName',
                  style: text.bodyMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),

            // Note
            if (note.isNotEmpty) ...[
              const SizedBox(height: SpacingTokens.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusSm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(
                        note,
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: SpacingTokens.xs),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _VoteTile extends StatelessWidget {
  const _VoteTile({
    required this.voterName,
    required this.voterColor,
    required this.votedForName,
    required this.isCorrect,
  });

  final String voterName;
  final Color voterColor;
  final String votedForName;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final text = context.textTheme;
    final storyTheme = context.storyTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        child: Row(
          children: [
            // Voter avatar
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: voterColor.withValues(alpha: 0.2),
              ),
              alignment: Alignment.center,
              child: Text(
                voterName.isNotEmpty ? voterName[0].toUpperCase() : '?',
                style: text.labelSmall?.copyWith(
                  color: voterColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),

            // Voter name
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: text.bodyMedium?.copyWith(color: colors.onSurface),
                  children: [
                    TextSpan(text: voterName),
                    TextSpan(
                      text: ' voted for ',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    TextSpan(
                      text: votedForName,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            // Correct indicator
            if (isCorrect)
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: storyTheme.auroraTeal,
              )
            else
              Icon(
                Icons.cancel_outlined,
                size: 18,
                color: colors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScoreChangeTile extends StatelessWidget {
  const _ScoreChangeTile({
    required this.playerName,
    required this.playerColor,
    required this.changes,
  });

  final String playerName;
  final Color playerColor;
  final List<ScoreChange> changes;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final text = context.textTheme;
    final storyTheme = context.storyTheme;

    final totalDelta = changes.fold<int>(0, (sum, c) => sum + c.delta);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            // Player avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: playerColor.withValues(alpha: 0.2),
              ),
              alignment: Alignment.center,
              child: Text(
                playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
                style: text.labelMedium?.copyWith(
                  color: playerColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),

            // Player name and reasons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: text.titleSmall?.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: SpacingTokens.sm,
                    children: changes.map((c) {
                      return Text(
                        '+${c.delta} ${c.reasonLabel}',
                        style: text.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
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
              style: text.titleMedium?.copyWith(
                color: storyTheme.goldAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
