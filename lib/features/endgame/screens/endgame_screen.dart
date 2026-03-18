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
import 'package:story_score/features/presets/providers/preset_providers.dart';
import 'package:story_score/features/settings/providers/settings_providers.dart';
import 'package:story_score/features/stats/providers/stats_providers.dart';
import 'package:story_score/features/stats/widgets/score_progression_chart.dart';
import 'package:story_score/features/stats/widgets/session_stats_section.dart';
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

    return Scaffold(
      body: StreamBuilder<List<Player>>(
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
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(l10n.gameOver),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.go('/'),
                  ),
                ),
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
                            hasTie ? l10n.itsATie : l10n.winner,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          animate: (child) => child
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 500.ms)
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
                                .fadeIn(delay: 500.ms, duration: 500.ms)
                                .slideY(begin: 0.3, end: 0),
                          ),
                        ),
                        // Score with counter animation
                        _maybeAnimate(
                          skipAnimations: skipAnimations,
                          child: Text(
                            l10n.points(topScore),
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
                              l10n.finalStandings,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          animate: (child) => child.animate().fadeIn(
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
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isWinner
                                              ? ColorTokens.goldAccent
                                              : theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: SpacingTokens.sm),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: PlayerColors.colorFor(
                                    player.colorKey,
                                  ),
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
                      ),
                    );

                    if (skipAnimations) return card;

                    return card
                        .animate()
                        .fadeIn(delay: (800 + index * 100).ms, duration: 400.ms)
                        .slideX(begin: 0.1, end: 0);
                  },
                ),
                // ── Session Stats (free) + Score Progression (premium) ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.lg,
                    ),
                    child: _SessionStatsBlock(sessionId: sessionId),
                  ),
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
                            label: Text(l10n.newGame),
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
                            label: Text(l10n.shareResults),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: SpacingTokens.md,
                              ),
                            ),
                          ),
                        ),
                        // Save as Preset (premium-gated)
                        if (ref.watch(isSupporterProvider) &&
                            players.length >= 3) ...[
                          const SizedBox(height: SpacingTokens.sm),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _saveAsPreset(context, ref, players),
                              icon: const Icon(Icons.bookmark_add_outlined),
                              label: Text(l10n.saveAsPreset),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: SpacingTokens.md,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: SpacingTokens.sm),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
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
                            icon: const Icon(Icons.home_rounded),
                            label: Text(l10n.backToHome),
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

  Future<void> _saveAsPreset(
    BuildContext context,
    WidgetRef ref,
    List<Player> players,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.saveAsPreset),
        content: TextField(
          controller: nameController,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.presetName,
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(nameController.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    nameController.dispose();

    if (name == null || name.isEmpty || !mounted) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final dao = ref.read(presetDaoProvider);
      await savePreset(
        dao: dao,
        name: name,
        players: players
            .map(
              (p) => (
                name: p.name,
                colorKey: p.colorKey,
                avatarStyle: p.avatarStyle,
                seatOrder: p.seatOrder,
              ),
            )
            .toList(),
      );
      Haptics.selection();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.savedPreset(name))));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.failedToSavePreset('$e'))),
      );
    }
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

/// Displays session stats (free) and score progression chart (premium-gated).
class _SessionStatsBlock extends ConsumerWidget {
  const _SessionStatsBlock({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(sessionStatsProvider(sessionId));
    final progressionAsync = ref.watch(scoreProgressionProvider(sessionId));
    final isSupporter = ref.watch(isSupporterProvider);
    final storyTheme = context.storyTheme;
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SpacingTokens.lg),
        // Session stats -- free for all users
        statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const SizedBox.shrink(),
          data: (stats) => SessionStatsSection(stats: stats),
        ),
        const SizedBox(height: SpacingTokens.lg),
        // Score progression chart -- premium-gated
        Text(
          AppLocalizations.of(context)?.scoreProgression ?? 'Score Progression',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: SpacingTokens.sm),
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
                        style: textTheme.bodySmall?.copyWith(
                          color: storyTheme.goldAccent,
                          fontWeight: FontWeight.w600,
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
        final l10n = AppLocalizations.of(context);
        final label =
            l10n?.points(_animation.value) ?? '${_animation.value} points';
        return Text(label, style: widget.style);
      },
    );
  }
}
