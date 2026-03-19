import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/export/export_helper.dart';
import 'package:story_score/data/export/session_exporter.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/scoreboard/providers/scoreboard_providers.dart';
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showTargetReachedDialog(context, ref, session, player);
        });
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
              child: playersAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, st) =>
                    Center(child: Text(l10n.errorLoadingPlayers('$e'))),
                data: (players) {
                  if (players.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.noPlayersInSession,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: ColorTokens.mutedText,
                        ),
                      ),
                    );
                  }

                  _checkTargetScore(session, players, context);
                  final storytellerId = storytellerAsync.value?.id;

                  return Column(
                    children: [
                      // Top bar: "Scoreboard" title + settings icon
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SpacingTokens.lg,
                          SpacingTokens.md,
                          SpacingTokens.md,
                          0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.scoreboard,
                                style:
                                    context.textTheme.headlineLarge?.copyWith(
                                  color: ColorTokens.parchment,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _SettingsButton(
                              onTap: () => _showSettingsMenu(
                                context,
                                ref,
                                session,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Round info card
                      _RoundInfoCard(
                        session: session,
                        storyteller: storytellerAsync.value,
                        players: players,
                        sessionId: sessionId,
                      ),

                      // PLAYERS section header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SpacingTokens.lg,
                          SpacingTokens.md,
                          SpacingTokens.lg,
                          SpacingTokens.sm,
                        ),
                        child: Row(
                          children: [
                            Text(
                              l10n.players.toUpperCase(),
                              style:
                                  context.textTheme.labelSmall?.copyWith(
                                color: ColorTokens.goldAccent,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                ref
                                    .read(sortByScoreProvider.notifier)
                                    .toggle();
                              },
                              child: Text(
                                sortByScore
                                    ? l10n.sortByScore
                                    : l10n.sortBySeat,
                                style: context.textTheme.labelSmall
                                    ?.copyWith(
                                  color: ColorTokens.mutedText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2-column player grid
                      Expanded(
                        child: _PlayerGrid(
                          players: players,
                          storytellerId: storytellerId,
                          sessionId: sessionId,
                          targetScore: session.targetScore,
                        ),
                      ),

                      // Hint text + New Round button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          SpacingTokens.lg,
                          SpacingTokens.sm,
                          SpacingTokens.md,
                          SpacingTokens.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tap the crown to change storyteller before a new round.',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: ColorTokens.mutedText,
                                ),
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.md),
                            _GradientButton(
                              onPressed: () =>
                                  context.go('/game/$sessionId/round'),
                              icon: Icons.play_arrow,
                              label: l10n.newRound,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettingsMenu(
    BuildContext context,
    WidgetRef ref,
    GameSession session,
  ) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: Text(l10n.backToHome),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.ios_share_rounded),
              title: Text(l10n.exportGame),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showExportSheet(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_rounded),
              title: Text(l10n.endGame),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _showEndGameDialog(context, ref, session);
              },
            ),
            const SizedBox(height: SpacingTokens.md),
          ],
        ),
      ),
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

/// Settings icon button — 40x40 rounded square with gold tint.
class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ColorTokens.goldAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ColorTokens.goldAccent.withValues(alpha: 0.3),
          ),
        ),
        child: const Icon(
          Icons.settings_rounded,
          color: ColorTokens.goldAccent,
          size: 20,
        ),
      ),
    );
  }
}

/// Round info card: round number left, storyteller name right, crown badge.
class _RoundInfoCard extends ConsumerWidget {
  const _RoundInfoCard({
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
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
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
          width: 1,
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
          // Round number left
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ROUND',
                style: context.textTheme.labelSmall?.copyWith(
                  color: ColorTokens.goldAccent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                (session.roundCount + 1).toString().padLeft(2, '0'),
                style: context.textTheme.headlineLarge?.copyWith(
                  color: ColorTokens.goldAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(width: SpacingTokens.lg),
          // Storyteller info right
          if (storyteller != null)
            Expanded(
              child: Semantics(
                label: l10n.playerIsStoryteller(storyteller!.name),
                button: true,
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
                  onTap: () => _showStorytellerPicker(context, ref),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Storyteller',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: ColorTokens.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        storyteller!.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: ColorTokens.parchment,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Crown badge icon
          Image.asset(AppAssets.crownBadge, width: 32),
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
                                currentStorytellerSeat:
                                    Value(player.seatOrder),
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

/// 2-column player grid matching the mockup.
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
    final crossAxisCount = isTablet ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: SpacingTokens.sm,
        mainAxisSpacing: SpacingTokens.sm,
        childAspectRatio: 0.85,
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

        Widget card = _PlayerCard(
          player: player,
          isStoryteller: isStoryteller,
          rank: index + 1,
          onLongPress: () => _showScoreAdjustDialog(context, ref, player),
        );

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

/// Individual player card for the scoreboard grid (mockup style).
class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.isStoryteller,
    this.rank,
    this.onLongPress,
  });

  final Player player;
  final bool isStoryteller;
  final int? rank;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final playerColor = PlayerColors.colorFor(player.colorKey);
    final isFirstPlace = rank == 1;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isStoryteller
                ? ColorTokens.goldAccent.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.04),
            width: isStoryteller ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
            if (isStoryteller)
              BoxShadow(
                color: ColorTokens.goldAccent.withValues(alpha: 0.1),
                blurRadius: 20,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: avatar + name + rank/crown
            Row(
              children: [
                // Colored avatar circle with initial
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            player.avatarStyle,
                            style: const TextStyle(fontSize: 18),
                          ),
                        )
                      : Text(
                          player.name.isNotEmpty
                              ? player.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    player.name,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: ColorTokens.parchment,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isStoryteller)
                  Image.asset(AppAssets.crownBadge, width: 20)
                else if (rank != null)
                  Text(
                    '#$rank',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: ColorTokens.mutedText,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            // Large score number
            Text(
              '${player.currentScore}',
              style: TextStyle(
                fontSize: isFirstPlace ? 48 : 40,
                fontWeight: FontWeight.w800,
                color: isFirstPlace
                    ? ColorTokens.goldAccent
                    : ColorTokens.parchment,
                shadows: isFirstPlace
                    ? [
                        Shadow(
                          color: ColorTokens.goldAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
            // Subtitle: "Tap crown to change" for storyteller, "In the tale" for others
            Text(
              isStoryteller ? 'Tap crown to change' : 'In the tale',
              style: context.textTheme.labelSmall?.copyWith(
                color: isStoryteller
                    ? ColorTokens.goldAccent.withValues(alpha: 0.7)
                    : ColorTokens.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient button used for "New Round".
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorTokens.burgundy, ColorTokens.goldAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.burgundy.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
              vertical: SpacingTokens.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  label,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated gold border glow for target-reached players.
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
            borderRadius: BorderRadius.circular(18),
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
