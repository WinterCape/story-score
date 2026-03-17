import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';

class EndgameScreen extends ConsumerWidget {
  final String sessionId;

  const EndgameScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionDao = ref.watch(sessionDaoProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: StreamBuilder<List<Player>>(
        stream: sessionDao.watchPlayersForSession(sessionId),
        builder: (context, playersSnap) {
          if (!playersSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final players = [...playersSnap.data!]
            ..sort((a, b) => b.currentScore.compareTo(a.currentScore));

          if (players.isEmpty) {
            return const Center(child: Text('No players found'));
          }

          final topScore = players.first.currentScore;
          final winners =
              players.where((p) => p.currentScore == topScore).toList();
          final hasTie = winners.length > 1;

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: SpacingTokens.xxl),
                        // Trophy icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                ColorTokens.goldAccent,
                                ColorTokens.goldAccentLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.lg),
                        Text(
                          hasTie ? "It's a Tie!" : 'Winner!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        Text(
                          winners.map((w) => w.name).join(' & '),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: ColorTokens.goldAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$topScore points',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xxl),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Final Standings',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.md),
                      ],
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isWinner = player.currentScore == topScore;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.lg,
                        vertical: SpacingTokens.xs,
                      ),
                      child: Card(
                        color: isWinner
                            ? ColorTokens.goldAccent.withValues(alpha: 0.1)
                            : null,
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '#${index + 1}',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isWinner
                                        ? ColorTokens.goldAccent
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    PlayerColors.colorFor(player.colorKey),
                                child: Text(
                                  player.name.isNotEmpty
                                      ? player.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            player.name,
                            style: TextStyle(
                              fontWeight: isWinner
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Text(
                            '${player.currentScore}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isWinner ? ColorTokens.goldAccent : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: SpacingTokens.lg),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => context.go('/game/new'),
                            icon: const Icon(Icons.replay_rounded),
                            label: const Text('New Game'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: SpacingTokens.md,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              sessionDao.updateSession(
                                sessionId,
                                GameSessionsCompanion(
                                  status:
                                      Value(GameStatus.completed),
                                  updatedAt: Value(DateTime.now()),
                                ),
                              );
                              context.go('/');
                            },
                            icon: const Icon(Icons.home_rounded),
                            label: const Text('Back to Home'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: SpacingTokens.md,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xxl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
