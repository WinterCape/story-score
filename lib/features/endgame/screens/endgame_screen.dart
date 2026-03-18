import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/export/export_helper.dart';
import 'package:story_score/data/export/session_exporter.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

class EndgameScreen extends ConsumerWidget {
  final String sessionId;

  const EndgameScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionDao = ref.watch(sessionDaoProvider);
    final theme = Theme.of(context);
    final skipAnimations = context.reduceMotion;

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
          final winnerLabel = winners.map((w) => w.name).join(' & ');

          // Fire haptic on winner reveal
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Haptics.heavy();
          });

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: SpacingTokens.xxl),
                        // Trophy icon with bounce animation
                        Semantics(
                          label: 'Trophy',
                          excludeSemantics: true,
                          child: _maybeAnimate(
                            skipAnimations: skipAnimations,
                            child: Container(
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
                            animate: (child) => child
                                .animate()
                                .scale(
                                  duration: 600.ms,
                                  curve: Curves.elasticOut,
                                  begin: const Offset(0.5, 0.5),
                                  end: const Offset(1.0, 1.0),
                                )
                                .then()
                                .scale(
                                  duration: 1500.ms,
                                  begin: const Offset(1.0, 1.0),
                                  end: const Offset(1.06, 1.06),
                                  curve: Curves.easeInOut,
                                )
                                .then()
                                .scale(
                                  duration: 1500.ms,
                                  begin: const Offset(1.06, 1.06),
                                  end: const Offset(1.0, 1.0),
                                  curve: Curves.easeInOut,
                                ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.lg),
                        // Winner headline with fade + slide
                        _maybeAnimate(
                          skipAnimations: skipAnimations,
                          child: Text(
                            hasTie ? "It's a Tie!" : 'Winner!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          animate: (child) => child
                              .animate()
                              .fadeIn(
                                delay: 300.ms,
                                duration: 500.ms,
                              )
                              .slideY(begin: 0.3, end: 0),
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        // Winner name with fade + slide
                        Semantics(
                          label: 'Winner: $winnerLabel with $topScore points',
                          child: _maybeAnimate(
                            skipAnimations: skipAnimations,
                            child: Text(
                              winnerLabel,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: ColorTokens.goldAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            animate: (child) => child
                                .animate()
                                .fadeIn(
                                  delay: 500.ms,
                                  duration: 500.ms,
                                )
                                .slideY(begin: 0.3, end: 0),
                          ),
                        ),
                        // Score with counter animation
                        _maybeAnimate(
                          skipAnimations: skipAnimations,
                          child: Text(
                            '$topScore points',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          animate: (child) => _AnimatedScoreCounter(
                            targetScore: topScore,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xxl),
                        _maybeAnimate(
                          skipAnimations: skipAnimations,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Final Standings',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          animate: (child) => child
                              .animate()
                              .fadeIn(
                                delay: 700.ms,
                                duration: 400.ms,
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

                    final card = Semantics(
                      label:
                          '${_ordinal(index + 1)} place, ${player.name}, ${player.currentScore} points',
                      excludeSemantics: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.lg,
                          vertical: SpacingTokens.xs,
                        ),
                        child: Card(
                          color: isWinner
                              ? ColorTokens.goldAccent
                                  .withValues(alpha: 0.1)
                              : null,
                          child: ListTile(
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text(
                                    '#${index + 1}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isWinner
                                          ? ColorTokens.goldAccent
                                          : theme
                                              .colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: SpacingTokens.sm),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: PlayerColors.colorFor(
                                      player.colorKey),
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
                                color:
                                    isWinner ? ColorTokens.goldAccent : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    if (skipAnimations) return card;

                    return card
                        .animate()
                        .fadeIn(
                          delay: (800 + index * 100).ms,
                          duration: 400.ms,
                        )
                        .slideX(begin: 0.1, end: 0);
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
                            onPressed: () => _shareResults(context, ref),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Share Results'),
                            style: OutlinedButton.styleFrom(
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

  Future<void> _shareResults(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      Haptics.medium();
      final info = await PackageInfo.fromPlatform();
      final exported = await buildExportedSession(
        sessionId: sessionId,
        sessionDao: ref.read(sessionDaoProvider),
        roundDao: ref.read(roundDaoProvider),
        appVersion: info.version,
      );

      const exporter = SessionExporter();
      final content = exporter.toJson(exported);
      final fileName = 'storyscore_${sessionId.substring(0, 8)}.json';

      await SharePlus.instance.share(
        ShareParams(
          text: content,
          title: fileName,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Share failed: $e')),
      );
    }
  }

  /// Returns the animated version if animations are enabled, otherwise
  /// returns the static child directly.
  static Widget _maybeAnimate({
    required bool skipAnimations,
    required Widget child,
    required Widget Function(Widget child) animate,
  }) {
    return skipAnimations ? child : animate(child);
  }

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    return switch (n % 10) {
      1 => '${n}st',
      2 => '${n}nd',
      3 => '${n}rd',
      _ => '${n}th',
    };
  }
}

/// Animates a score counter from 0 to [targetScore].
class _AnimatedScoreCounter extends StatefulWidget {
  const _AnimatedScoreCounter({
    required this.targetScore,
    this.style,
  });

  final int targetScore;
  final TextStyle? style;

  @override
  State<_AnimatedScoreCounter> createState() => _AnimatedScoreCounterState();
}

class _AnimatedScoreCounterState extends State<_AnimatedScoreCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = IntTween(begin: 0, end: widget.targetScore).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    // Start after a short delay to sync with other entrance animations
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Text(
        '${_animation.value} points',
        style: widget.style,
      ),
    );
  }
}
