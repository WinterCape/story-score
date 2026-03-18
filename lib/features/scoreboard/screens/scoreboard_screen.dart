import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/export/export_helper.dart';
import 'package:story_score/data/export/session_exporter.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/scoreboard/providers/scoreboard_providers.dart';
import 'package:story_score/features/scoreboard/widgets/player_score_card.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

class ScoreboardScreen extends ConsumerStatefulWidget {
  const ScoreboardScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends ConsumerState<ScoreboardScreen> {
  /// Tracks player IDs that have already triggered the target-reached modal,
  /// so we only show it once per threshold crossing.
  final Set<String> _targetReachedShownFor = {};

  String get sessionId => widget.sessionId;

  void _checkTargetScore(
    GameSession session,
    List<Player> players,
    BuildContext context,
  ) {
    final target = session.targetScore;
    if (target == null || target <= 0) return;

    for (final player in players) {
      if (player.currentScore >= target &&
          !_targetReachedShownFor.contains(player.id)) {
        _targetReachedShownFor.add(player.id);
        // Schedule the dialog after the current frame to avoid build conflicts.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showTargetReachedDialog(context, ref, session, player);
        });
        // Only show one modal at a time.
        break;
      }
    }
  }

  void _showTargetReachedDialog(
    BuildContext context,
    WidgetRef ref,
    GameSession session,
    Player player,
  ) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.emoji_events,
          size: 48,
          color: context.storyTheme.goldAccent,
        ),
        title: Text(l10n.reachedTarget(player.name, session.targetScore!)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.continuePlaying),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref
                  .read(sessionDaoProvider)
                  .updateSession(
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
            child: Text(l10n.endGameNow),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final sessionAsync = ref.watch(sessionProvider(sessionId));
    final sortByScore = ref.watch(sortByScoreProvider);
    final playersAsync = sortByScore
        ? ref.watch(playersByScoreProvider(sessionId))
        : ref.watch(playersProvider(sessionId));
    final storytellerAsync = ref.watch(currentStorytellerProvider(sessionId));
    final l10n = context.l10n;

    return sessionAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: context.colorScheme.error,
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  l10n.failedToLoadSession,
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
                l10n.sessionNotFound,
                style: context.textTheme.titleMedium,
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.go('/'),
            ),
            title: Text(
              session.title.isNotEmpty ? session.title : l10n.scoreboard,
            ),
            actions: [
              // Sort toggle
              IconButton(
                icon: Icon(
                  sortByScore ? Icons.sort_by_alpha : Icons.leaderboard,
                ),
                tooltip: sortByScore ? l10n.sortBySeat : l10n.sortByScore,
                onPressed: () {
                  ref.read(sortByScoreProvider.notifier).toggle();
                },
              ),
              // Overflow menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'export_game':
                      _showExportSheet(context, ref);
                    case 'end_game':
                      _showEndGameDialog(context, ref, session);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'export_game',
                    child: Row(
                      children: [
                        const Icon(Icons.share_outlined, size: 20),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(l10n.exportGame),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'end_game',
                    child: Row(
                      children: [
                        const Icon(Icons.flag_outlined, size: 20),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(l10n.endGame),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: playersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) =>
                Center(child: Text(l10n.errorLoadingPlayers('$e'))),
            data: (players) {
              if (players.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noPlayersInSession,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              // Check if any player reached the target score.
              _checkTargetScore(session, players, context);

              final storytellerId = storytellerAsync.value?.id;

              // Round info header
              return Column(
                children: [
                  // Round counter + storyteller info
                  _RoundInfoHeader(
                    session: session,
                    storyteller: storytellerAsync.value,
                    players: players,
                    sessionId: sessionId,
                  ),
                  // Player grid
                  Expanded(
                    child: _PlayerGrid(
                      players: players,
                      storytellerId: storytellerId,
                      sessionId: sessionId,
                      targetScore: session.targetScore,
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: Semantics(
            label: l10n.startNewRound,
            button: true,
            excludeSemantics: true,
            child: FloatingActionButton.extended(
              onPressed: () {
                context.go('/game/$sessionId/round');
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.newRound),
              backgroundColor: context.storyTheme.goldAccent,
              foregroundColor: Colors.black,
            ),
          ),
        );
      },
    );
  }

  void _showExportSheet(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.sm,
              ),
              child: Text(
                l10n.exportGame,
                style: context.textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.data_object),
              title: Text(l10n.exportAsJson),
              subtitle: Text(l10n.exportAsJsonDescription),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportAs(context, ref, format: 'json');
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: Text(l10n.exportAsCsv),
              subtitle: Text(l10n.exportAsCsvDescription),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _exportAs(context, ref, format: 'csv');
              },
            ),
            const SizedBox(height: SpacingTokens.md),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAs(
    BuildContext context,
    WidgetRef ref, {
    required String format,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final info = await PackageInfo.fromPlatform();
      final exported = await buildExportedSession(
        sessionId: sessionId,
        sessionDao: ref.read(sessionDaoProvider),
        roundDao: ref.read(roundDaoProvider),
        appVersion: info.version,
      );

      const exporter = SessionExporter();
      final String content;
      final String fileName;
      if (format == 'csv') {
        content = exporter.toCsv(exported);
        fileName = 'storyscore_${sessionId.substring(0, 8)}.csv';
      } else {
        content = exporter.toJson(exported);
        fileName = 'storyscore_${sessionId.substring(0, 8)}.json';
      }

      await SharePlus.instance.share(
        ShareParams(text: content, title: fileName),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportFailed('$e'))));
    }
  }

  void _showEndGameDialog(
    BuildContext context,
    WidgetRef ref,
    GameSession session,
  ) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.endGameQuestion),
        content: Text(l10n.endGameConfirmation(session.roundCount)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref
                  .read(sessionDaoProvider)
                  .updateSession(
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
            child: Text(l10n.endGame),
          ),
        ],
      ),
    );
  }
}

/// Header showing the current round number and storyteller.
class _RoundInfoHeader extends ConsumerWidget {
  const _RoundInfoHeader({
    required this.session,
    required this.storyteller,
    required this.players,
    required this.sessionId,
  });

  final GameSession session;
  final Player? storyteller;
  final List<Player> players;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

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
              l10n.round(session.roundCount + 1),
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          // Storyteller indicator — tap to change
          if (storyteller != null) ...[
            Expanded(
              child: Semantics(
                label: l10n.playerIsStoryteller(storyteller!.name),
                button: true,
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
                  onTap: () => _showStorytellerPicker(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.xs,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 16,
                          color: context.storyTheme.goldAccent,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: Text(
                            l10n.playerIsStorytelling(storyteller!.name),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.swap_horiz,
                          size: 16,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showStorytellerPicker(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.sm,
              ),
              child: Text(
                l10n.chooseStoryteller,
                style: context.textTheme.titleMedium,
              ),
            ),
            ...players.map((player) {
              final isCurrentStoryteller = player.id == storyteller?.id;
              return ListTile(
                leading: Icon(
                  Icons.auto_stories,
                  color: isCurrentStoryteller
                      ? context.storyTheme.goldAccent
                      : context.colorScheme.onSurfaceVariant,
                ),
                title: Text(player.name),
                trailing: isCurrentStoryteller
                    ? Icon(Icons.check, color: context.storyTheme.goldAccent)
                    : null,
                onTap: isCurrentStoryteller
                    ? null
                    : () async {
                        Navigator.of(sheetContext).pop();
                        await ref
                            .read(sessionDaoProvider)
                            .updateSession(
                              sessionId,
                              GameSessionsCompanion(
                                currentStorytellerSeat: Value(player.seatOrder),
                                updatedAt: Value(DateTime.now()),
                              ),
                            );
                      },
              );
            }),
            const SizedBox(height: SpacingTokens.md),
          ],
        ),
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
    this.targetScore,
  });

  final List<Player> players;
  final String? storytellerId;
  final String sessionId;
  final int? targetScore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final int crossAxisCount;
    if (isTablet) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = players.length <= 4 ? 1 : 2;
    }

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
        final isSupporter = ref.watch(isSupporterProvider);
        final hasReachedTarget =
            targetScore != null &&
            targetScore! > 0 &&
            player.currentScore >= targetScore!;

        Widget card = PlayerScoreCard(
          player: player,
          isStoryteller: isStoryteller,
          rank: index + 1,
          onLongPress: () => _showScoreAdjustDialog(context, ref, player),
        );

        // Animated gold border glow for players who reached the target
        // score — premium-gated.
        if (hasReachedTarget && isSupporter) {
          card = _WinnerGlow(child: card);
        }

        return card;
      },
    );
  }

  void _showScoreAdjustDialog(
    BuildContext context,
    WidgetRef ref,
    Player player,
  ) {
    final l10n = context.l10n;
    var adjustment = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.adjustScore(player.name)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.currentScore(player.currentScore),
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
                      horizontal: SpacingTokens.lg,
                    ),
                    child: Text(
                      '${adjustment >= 0 ? '+' : ''}$adjustment',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: adjustment > 0
                            ? ColorTokens.teal
                            : adjustment < 0
                            ? ColorTokens.coral
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
                l10n.newScore(player.currentScore + adjustment),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: adjustment == 0
                  ? null
                  : () async {
                      Navigator.of(dialogContext).pop();
                      await ref
                          .read(sessionDaoProvider)
                          .updatePlayerScore(
                            player.id,
                            player.currentScore + adjustment,
                          );
                    },
              child: Text(l10n.apply),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a child widget in an animated gold border glow effect.
/// Pulses 2 times then holds steady.
class _WinnerGlow extends StatefulWidget {
  const _WinnerGlow({required this.child});

  final Widget child;

  @override
  State<_WinnerGlow> createState() => _WinnerGlowState();
}

class _WinnerGlowState extends State<_WinnerGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Pulse 2 times then stop
    var count = 0;
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        count++;
        if (count < 2) {
          _controller.reverse();
        }
      } else if (status == AnimationStatus.dismissed && count < 2) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            boxShadow: [
              BoxShadow(
                color: ColorTokens.goldAccent.withValues(
                  alpha: 0.4 * _glowAnimation.value,
                ),
                blurRadius: 16 * _glowAnimation.value,
                spreadRadius: 2 * _glowAnimation.value,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
