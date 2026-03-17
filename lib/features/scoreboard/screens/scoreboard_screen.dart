import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/features/scoreboard/providers/scoreboard_providers.dart';
import 'package:story_score/features/scoreboard/widgets/player_score_card.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

class ScoreboardScreen extends ConsumerWidget {
  const ScoreboardScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider(sessionId));
    final sortByScore = ref.watch(sortByScoreProvider);
    final playersAsync = sortByScore
        ? ref.watch(playersByScoreProvider(sessionId))
        : ref.watch(playersProvider(sessionId));
    final storytellerAsync =
        ref.watch(currentStorytellerProvider(sessionId));

    return sessionAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: context.colorScheme.error),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'Failed to load session',
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  '$e',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      data: (session) {
        if (session == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'Session not found',
                style: context.textTheme.titleMedium,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              session.title.isNotEmpty ? session.title : 'Scoreboard',
            ),
            actions: [
              // Sort toggle
              IconButton(
                icon: Icon(
                  sortByScore
                      ? Icons.sort_by_alpha
                      : Icons.leaderboard,
                ),
                tooltip: sortByScore ? 'Sort by seat' : 'Sort by score',
                onPressed: () {
                  ref.read(sortByScoreProvider.notifier).state = !sortByScore;
                },
              ),
              // Overflow menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'end_game':
                      _showEndGameDialog(context, ref, session);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'end_game',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 20),
                        SizedBox(width: SpacingTokens.sm),
                        Text('End Game'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: playersAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(
              child: Text('Error loading players: $e'),
            ),
            data: (players) {
              if (players.isEmpty) {
                return Center(
                  child: Text(
                    'No players in this session',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              final storytellerId = storytellerAsync.value?.id;

              // Round info header
              return Column(
                children: [
                  // Round counter + storyteller info
                  _RoundInfoHeader(
                    session: session,
                    storyteller: storytellerAsync.value,
                  ),
                  // Player grid
                  Expanded(
                    child: _PlayerGrid(
                      players: players,
                      storytellerId: storytellerId,
                      sessionId: sessionId,
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              context.go('/game/$sessionId/round');
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('New Round'),
            backgroundColor: context.storyTheme.goldAccent,
            foregroundColor: Colors.black,
          ),
        );
      },
    );
  }

  void _showEndGameDialog(
    BuildContext context,
    WidgetRef ref,
    GameSession session,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Game?'),
        content: Text(
          'This will mark the game as completed after '
          '${session.roundCount} round${session.roundCount == 1 ? '' : 's'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(sessionDaoProvider).updateSession(
                    sessionId,
                    GameSessionsCompanion(
                      status: const Value(GameStatus.completed),
                      updatedAt: Value(DateTime.now()),
                    ),
                  );
              if (context.mounted) {
                context.go('/game/$sessionId/endgame');
              }
            },
            child: const Text('End Game'),
          ),
        ],
      ),
    );
  }
}

/// Header showing the current round number and storyteller.
class _RoundInfoHeader extends StatelessWidget {
  const _RoundInfoHeader({
    required this.session,
    required this.storyteller,
  });

  final GameSession session;
  final Player? storyteller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      child: Row(
        children: [
          // Round count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.sm,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
            ),
            child: Text(
              'Round ${session.roundCount + 1}',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          // Storyteller indicator
          if (storyteller != null) ...[
            Icon(
              Icons.auto_stories,
              size: 16,
              color: context.storyTheme.goldAccent,
            ),
            const SizedBox(width: SpacingTokens.xs),
            Expanded(
              child: Text(
                '${storyteller!.name} is storytelling',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Responsive player grid — 2 columns for most counts.
class _PlayerGrid extends ConsumerWidget {
  const _PlayerGrid({
    required this.players,
    required this.storytellerId,
    required this.sessionId,
  });

  final List<Player> players;
  final String? storytellerId;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crossAxisCount = players.length <= 4 ? 1 : 2;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.sm,
        SpacingTokens.md,
        // Extra padding for FAB
        SpacingTokens.xxl + SpacingTokens.xxl,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: SpacingTokens.md,
        mainAxisSpacing: SpacingTokens.md,
        childAspectRatio: crossAxisCount == 1 ? 3.0 : 1.3,
      ),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isStoryteller = player.id == storytellerId;

        return PlayerScoreCard(
          player: player,
          isStoryteller: isStoryteller,
          rank: index + 1,
          onLongPress: () =>
              _showScoreAdjustDialog(context, ref, player),
        );
      },
    );
  }

  void _showScoreAdjustDialog(
    BuildContext context,
    WidgetRef ref,
    Player player,
  ) {
    var adjustment = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Adjust ${player.name}\'s Score'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current: ${player.currentScore}',
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filled(
                    onPressed: () => setState(() => adjustment--),
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.lg),
                    child: Text(
                      '${adjustment >= 0 ? '+' : ''}$adjustment',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: adjustment > 0
                            ? ColorTokens.auroraGreen
                            : adjustment < 0
                                ? ColorTokens.coralAccent
                                : context.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => setState(() => adjustment++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'New score: ${player.currentScore + adjustment}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: adjustment == 0
                  ? null
                  : () async {
                      Navigator.of(dialogContext).pop();
                      await ref.read(sessionDaoProvider).updatePlayerScore(
                            player.id,
                            player.currentScore + adjustment,
                          );
                    },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
