import 'dart:ui';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/export/export_helper.dart';
import 'package:story_score/data/export/session_exporter.dart';
import 'package:story_score/domain/celebrations/celebration_engine.dart';
import 'package:story_score/features/celebrations/celebration_controller.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/settings/providers/settings_providers.dart';
import 'package:story_score/features/stats/providers/stats_providers.dart';
import 'package:story_score/features/stats/widgets/score_progression_chart.dart';
import 'package:story_score/core/l10n/generated/app_localizations.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

class EndgameScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const EndgameScreen({super.key, required this.sessionId});

  @override
  ConsumerState<EndgameScreen> createState() => _EndgameScreenState();
}

class _EndgameScreenState extends ConsumerState<EndgameScreen> {
  bool _celebrationFired = false;

  String get sessionId => widget.sessionId;

  @override
  Widget build(BuildContext context) {
    final sessionDao = ref.read(sessionDaoProvider);
    final theme = Theme.of(context);
    final skipAnimations = context.reduceMotion;
    final storyTheme = context.storyTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorTokens.darkBackground,
              ColorTokens.darkSurface,
              ColorTokens.burgundy,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: StreamBuilder<List<Player>>(
          stream: sessionDao.watchPlayersForSession(sessionId),
          builder: (context, playersSnap) {
            if (!playersSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final l10n = AppLocalizations.of(context)!;
            final players = [...playersSnap.data!]
              ..sort((a, b) => b.currentScore.compareTo(a.currentScore));

            if (players.isEmpty) {
              return Center(child: Text(l10n.noPlayersFound));
            }

            final topScore = players.first.currentScore;
            final winners = players
                .where((p) => p.currentScore == topScore)
                .toList();
            final hasTie = winners.length > 1;
            final winnerLabel = winners.map((w) => w.name).join(' & ');

            // Fire haptic + confetti only once on winner reveal
            if (!_celebrationFired) {
              _celebrationFired = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                Haptics.heavy();
                _triggerWinnerConfetti(context, ref);
              });
            }

            return SafeArea(
              child: Stack(
                children: [
                  // Sparkle particles scattered around
                  Positioned(
                    top: 60,
                    left: 30,
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.asset(AppAssets.sparkle(1), width: 18),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: 50,
                    child: Opacity(
                      opacity: 0.3,
                      child: Image.asset(AppAssets.sparkle(2), width: 16),
                    ),
                  ),
                  Positioned(
                    top: 160,
                    left: 60,
                    child: Opacity(
                      opacity: 0.2,
                      child: Image.asset(AppAssets.sparkle(3), width: 14),
                    ),
                  ),
                  Positioned(
                    top: 140,
                    right: 30,
                    child: Opacity(
                      opacity: 0.25,
                      child: Image.asset(AppAssets.sparkle(1), width: 16),
                    ),
                  ),
                  Positioned(
                    bottom: 300,
                    left: 40,
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(AppAssets.sparkle(2), width: 20),
                    ),
                  ),

                  // Main content
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.lg,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: SpacingTokens.xxl),

                              // Trophy badge centered
                              Semantics(
                                label: 'Trophy',
                                excludeSemantics: true,
                                child: _maybeAnimate(
                                  skipAnimations: skipAnimations,
                                  child: Image.asset(
                                    AppAssets.trophyBadge,
                                    width: 80,
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
                              const SizedBox(height: SpacingTokens.md),

                              // "WINNER" gold uppercase label
                              _maybeAnimate(
                                skipAnimations: skipAnimations,
                                child: Text(
                                  hasTie
                                      ? l10n.itsATie.toUpperCase()
                                      : l10n.winner.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 3,
                                    color: ColorTokens.goldAccent,
                                  ),
                                ),
                                animate: (child) => child
                                    .animate()
                                    .fadeIn(delay: 300.ms, duration: 500.ms)
                                    .slideY(begin: 0.3, end: 0),
                              ),
                              const SizedBox(height: SpacingTokens.xs),

                              // Winner name large parchment text
                              Semantics(
                                label:
                                    'Winner: $winnerLabel with $topScore points',
                                child: _maybeAnimate(
                                  skipAnimations: skipAnimations,
                                  child: Text(
                                    winnerLabel,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: ColorTokens.parchment,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  animate: (child) => child
                                      .animate()
                                      .fadeIn(delay: 500.ms, duration: 500.ms)
                                      .slideY(begin: 0.3, end: 0),
                                ),
                              ),

                              // Score: very large gold number
                              _maybeAnimate(
                                skipAnimations: skipAnimations,
                                child: Text(
                                  '$topScore',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 58,
                                    fontWeight: FontWeight.w800,
                                    color: ColorTokens.goldAccent,
                                    height: 1.1,
                                  ),
                                ),
                                animate: (child) =>
                                    _AnimatedScoreCounter(
                                  targetScore: topScore,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 58,
                                    fontWeight: FontWeight.w800,
                                    color: ColorTokens.goldAccent,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: SpacingTokens.md),

                              // Ornate gold divider
                              Image.asset(
                                AppAssets.dividerOrnate,
                                width: 200,
                              ),

                              const SizedBox(height: SpacingTokens.lg),

                              // "FINAL STANDINGS" section header
                              _maybeAnimate(
                                skipAnimations: skipAnimations,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    l10n.finalStandings.toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      color: ColorTokens.goldAccent,
                                    ),
                                  ),
                                ),
                                animate: (child) => child.animate().fadeIn(
                                      delay: 700.ms,
                                      duration: 400.ms,
                                    ),
                              ),
                              const SizedBox(height: SpacingTokens.sm),
                            ],
                          ),
                        ),
                      ),

                      // Standings list
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.lg,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorTokens.darkCard.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: ColorTokens.goldAccent.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Column(
                              children: [
                                for (int index = 0;
                                    index < players.length;
                                    index++)
                                  _buildStandingRow(
                                    context,
                                    theme,
                                    players[index],
                                    index,
                                    topScore,
                                    skipAnimations,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Session Stats + Score Progression
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.lg,
                          ),
                          child:
                              _SessionStatsBlock(sessionId: sessionId),
                        ),
                      ),

                      // Bottom action buttons: 3 in a row
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            SpacingTokens.lg,
                            SpacingTokens.lg,
                            SpacingTokens.lg,
                            SpacingTokens.xxl,
                          ),
                          child: Row(
                            children: [
                              // New Game - gradient
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: storyTheme.accentGradient,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: FilledButton(
                                      onPressed: () => context.go('/game/new'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Text(l10n.newGame),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                              // Share - outlined
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        _shareResults(context, ref),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: ColorTokens.parchment,
                                      side: BorderSide(
                                        color: ColorTokens.parchment
                                            .withValues(alpha: 0.4),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(l10n.shareResults),
                                  ),
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                              // Save - outlined
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      sessionDao.updateSession(
                                        sessionId,
                                        GameSessionsCompanion(
                                          status: Value(GameStatus.completed),
                                          updatedAt: Value(DateTime.now()),
                                        ),
                                      );
                                      context.go('/');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: ColorTokens.parchment,
                                      side: BorderSide(
                                        color: ColorTokens.parchment
                                            .withValues(alpha: 0.4),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(l10n.save),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStandingRow(
    BuildContext context,
    ThemeData theme,
    Player player,
    int index,
    int topScore,
    bool skipAnimations,
  ) {
    final isWinner = player.currentScore == topScore;
    final playerColor = PlayerColors.colorFor(player.colorKey);

    final row = Semantics(
      label:
          '${_ordinal(index + 1)} place, ${player.name}, ${player.currentScore} points',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          gradient: isWinner
              ? LinearGradient(
                  colors: [
                    ColorTokens.goldAccent.withValues(alpha: 0.2),
                    ColorTokens.goldAccent.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: index == 0
              ? const BorderRadius.vertical(top: Radius.circular(14))
              : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm + 2,
        ),
        child: Row(
          children: [
            // Colored avatar circle
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
                      style: const TextStyle(fontSize: 16),
                    )
                  : Text(
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
            const SizedBox(width: SpacingTokens.md),
            // "#1 Name"
            Expanded(
              child: Text(
                '#${index + 1} ${player.name}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight:
                      isWinner ? FontWeight.w700 : FontWeight.w500,
                  color: isWinner
                      ? ColorTokens.parchment
                      : ColorTokens.parchment,
                ),
              ),
            ),
            // Score right
            Text(
              '${player.currentScore}',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isWinner
                    ? ColorTokens.goldAccent
                    : ColorTokens.parchment,
              ),
            ),
          ],
        ),
      ),
    );

    if (skipAnimations) return row;
    return row
        .animate()
        .fadeIn(delay: (800 + index * 100).ms, duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Future<void> _shareResults(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
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
        ShareParams(text: content, title: fileName),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.shareFailed('$e'))));
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

  /// Triggers confetti overlay for supporters on winner reveal.
  void _triggerWinnerConfetti(BuildContext context, WidgetRef ref) {
    final isSupporter = ref.read(isSupporterProvider);
    if (!isSupporter) return;

    final isReducedMotion = context.reduceMotion;
    if (isReducedMotion) return;

    final settings = ref.read(appSettingsProvider).value;
    final selectedTheme = settings?.selectedTheme ?? 'celestial';
    final soundEnabled =
        isSupporter && (settings?.soundEffectsEnabled ?? false);

    final result = CelebrationEngine.computeWinnerEffects(
      isSupporter: true,
      selectedTheme: selectedTheme,
      isReducedMotion: false,
    );

    if (!result.hasEffects) return;

    final overlay = Overlay.of(context);
    final controller = CelebrationController(
      overlayState: overlay,
      isReducedMotion: false,
      isSoundEnabled: soundEnabled,
    );

    controller.play(result);
  }
}

/// Displays session stats as a 3-column grid (MVP / ACCURACY / BEST ROUND)
/// and score progression chart (premium-gated).
class _SessionStatsBlock extends ConsumerWidget {
  const _SessionStatsBlock({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(sessionStatsProvider(sessionId));
    final progressionAsync = ref.watch(scoreProgressionProvider(sessionId));
    final isSupporter = ref.watch(isSupporterProvider);
    final storyTheme = context.storyTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SpacingTokens.lg),

        // "SESSION STATS" section header
        const Text(
          'SESSION STATS',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: ColorTokens.goldAccent,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),

        // 3-column stats grid
        statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox.shrink(),
          data: (stats) => Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: ColorTokens.darkCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ColorTokens.goldAccent.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: 'MVP',
                    value: stats.mvpName.isNotEmpty ? stats.mvpName : '--',
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'ACCURACY',
                    value: '${(stats.guessAccuracy * 100).round()}%',
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: 'BEST ROUND',
                    value: stats.bestRound > 0 ? '+${stats.bestRound}' : '--',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),

        // Score progression chart -- premium-gated
        if (isSupporter)
          progressionAsync.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (progression) =>
                ScoreProgressionChart(progression: progression),
          )
        else
          Stack(
            children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: IgnorePointer(
                  child: progressionAsync.when(
                    loading: () => const SizedBox(height: 220),
                    error: (_, _) => const SizedBox(height: 220),
                    data: (progression) =>
                        ScoreProgressionChart(progression: progression),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: storyTheme.goldAccent,
                        size: 32,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      Text(
                        AppLocalizations.of(context)?.supporterPack ??
                            'Supporter Pack',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: storyTheme.goldAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// A single stat column for the 3-column grid.
class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: ColorTokens.goldAccent,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorTokens.parchment,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Animates a score counter from 0 to [targetScore].
class _AnimatedScoreCounter extends StatefulWidget {
  const _AnimatedScoreCounter({required this.targetScore, this.style});

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
    _animation = IntTween(
      begin: 0,
      end: widget.targetScore,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
      builder: (context, _) {
        return Text('${_animation.value}', style: widget.style);
      },
    );
  }
}
