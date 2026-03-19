import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';
import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/domain/celebrations/celebration_engine.dart';
import 'package:story_score/domain/scoring/score_reason.dart';
import 'package:story_score/domain/scoring/scoring_engine.dart';
import 'package:story_score/domain/stats/milestone_detector.dart';
import 'package:story_score/domain/stats/stats_models.dart';
import 'package:story_score/features/celebrations/celebration_controller.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/round/providers/round_providers.dart';
import 'package:story_score/features/round/widgets/round_recap_sheet.dart';
import 'package:story_score/features/round/widgets/voter_card_grid.dart';
import 'package:story_score/features/scoreboard/providers/scoreboard_providers.dart';
import 'package:story_score/features/settings/providers/settings_providers.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

class RoundScreen extends ConsumerStatefulWidget {
  const RoundScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends ConsumerState<RoundScreen> {
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  bool _initialized = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(sessionProvider(widget.sessionId));
    final playersAsync = ref.watch(playersProvider(widget.sessionId));
    final storytellerAsync = ref.watch(
      currentStorytellerProvider(widget.sessionId),
    );
    final voteState = ref.watch(voteEntryProvider);
    final l10n = context.l10n;

    return sessionAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) =>
          Scaffold(body: Center(child: Text('${l10n.error}: $e'))),
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

        return playersAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, st) =>
              Scaffold(body: Center(child: Text('${l10n.error}: $e'))),
          data: (players) {
            final storyteller = storytellerAsync.value;

            if (storyteller == null) {
              return Scaffold(
                body: Center(
                  child: Text(
                    l10n.noStorytellerAssigned,
                    style: context.textTheme.titleMedium,
                  ),
                ),
              );
            }

            // Initialize vote entry state with non-storyteller player IDs
            final nonStorytellerIds = players
                .where((p) => p.id != storyteller.id)
                .map((p) => p.id)
                .toList();

            if (!_initialized ||
                voteState.voterIds.length != nonStorytellerIds.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(voteEntryProvider.notifier).init(nonStorytellerIds);
              });
              _initialized = true;
            }

            final nonStorytellerPlayers = players
                .where((p) => p.id != storyteller.id)
                .toList();

            final roundNumber = session.roundCount + 1;

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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.isTablet ? 600 : double.infinity,
                      ),
                      child: CustomScrollView(
                        slivers: [
                          // Round title header with icon circle
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                SpacingTokens.lg,
                                SpacingTokens.md,
                                SpacingTokens.lg,
                                SpacingTokens.sm,
                              ),
                              child: Row(
                                children: [
                                  // Round icon circle
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ColorTokens.goldAccent
                                          .withValues(alpha: 0.15),
                                      border: Border.all(
                                        color: ColorTokens.goldAccent
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        AppAssets.clueGood,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: SpacingTokens.md),
                                  Text(
                                    l10n.round(roundNumber),
                                    style: context.textTheme.headlineMedium
                                        ?.copyWith(
                                      color: ColorTokens.parchment,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Storyteller announcement card
                          SliverToBoxAdapter(
                            child: _StorytellerCard(
                              storyteller: storyteller,
                            ),
                          ),

                          // "WHO DID EACH PLAYER VOTE FOR?" header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                SpacingTokens.lg,
                                SpacingTokens.lg,
                                SpacingTokens.lg,
                                SpacingTokens.sm,
                              ),
                              child: Text(
                                l10n.whoDidEachPlayerVoteFor.toUpperCase(),
                                style:
                                    context.textTheme.labelSmall?.copyWith(
                                  color: ColorTokens.goldAccent,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),

                          // Voter rows
                          SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              final voter = nonStorytellerPlayers[index];
                              final targets = players
                                  .where((p) => p.id != voter.id)
                                  .toList();

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SpacingTokens.md,
                                ),
                                child: VoterCardGrid(
                                  voter: voter,
                                  targets: targets,
                                  selectedTargetId:
                                      voteState.votes[voter.id],
                                  onTargetSelected: (targetId) {
                                    Haptics.selection();
                                    if (voteState.votes[voter.id] ==
                                        targetId) {
                                      ref
                                          .read(voteEntryProvider.notifier)
                                          .clearVote(voter.id);
                                    } else {
                                      ref
                                          .read(voteEntryProvider.notifier)
                                          .setVote(voter.id, targetId);
                                    }
                                  },
                                ),
                              );
                            }, childCount: nonStorytellerPlayers.length),
                          ),

                          // Round note section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                SpacingTokens.lg,
                                SpacingTokens.lg,
                                SpacingTokens.lg,
                                SpacingTokens.sm,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ROUND NOTE',
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                      color: ColorTokens.goldAccent,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(height: SpacingTokens.sm),
                                  TextField(
                                    controller: _noteController,
                                    decoration: InputDecoration(
                                      hintText:
                                          'Optional note about the clue',
                                      hintStyle: TextStyle(
                                        color: ColorTokens.mutedText
                                            .withValues(alpha: 0.6),
                                      ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: SpacingTokens.md,
                                        vertical: SpacingTokens.md,
                                      ),
                                    ),
                                    textInputAction: TextInputAction.done,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Bottom padding
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // "All votes entered" status + Score Round button
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (voteState.allVotesCast)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpacingTokens.sm,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'All votes entered',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: ColorTokens.goldAccent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '*',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: ColorTokens.goldAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Semantics(
                        label: voteState.allVotesCast
                            ? l10n.scoreRound
                            : l10n.scoreRoundDisabledHint,
                        button: true,
                        enabled:
                            voteState.allVotesCast && !_isSubmitting,
                        excludeSemantics: true,
                        child: _ScoreRoundButton(
                          isEnabled:
                              voteState.allVotesCast && !_isSubmitting,
                          isSubmitting: _isSubmitting,
                          label: l10n.scoreRound,
                          onPressed:
                              voteState.allVotesCast && !_isSubmitting
                                  ? () => _submitRound(
                                        session: session,
                                        storyteller: storyteller,
                                        players: players,
                                        votes: voteState.completedVotes,
                                      )
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitRound({
    required GameSession session,
    required Player storyteller,
    required List<Player> players,
    required Map<String, String> votes,
  }) async {
    setState(() => _isSubmitting = true);

    final navigator = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ctx = context;
    final l10n = context.l10n;

    try {
      final result = await ref
          .read(roundProcessorProvider)
          .submitRound(
            sessionId: widget.sessionId,
            storytellerPlayerId: storyteller.id,
            allPlayerIds: players.map((p) => p.id).toList(),
            votes: votes,
            note: _noteController.text.trim(),
          );

      if (!mounted) return;

      Haptics.medium();

      _triggerMilestoneCelebrations(
        result: result,
        storyteller: storyteller,
        players: players,
        votes: votes,
      );

      await showRoundRecapSheet(
        context: ctx, // ignore: use_build_context_synchronously
        result: result,
        players: players,
      );

      if (!mounted) return;

      ref.read(voteEntryProvider.notifier).clearAll();
      _noteController.clear();
      _initialized = false;

      navigator.go('/game/${widget.sessionId}/scoreboard');
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.errorScoringRound('$e'))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _triggerMilestoneCelebrations({
    required RoundResult result,
    required Player storyteller,
    required List<Player> players,
    required Map<String, String> votes,
  }) {
    final isSupporter = ref.read(isSupporterProvider);
    final settings = ref.read(appSettingsProvider).value;
    final selectedTheme = settings?.selectedTheme ?? 'celestial';
    final soundEnabled =
        isSupporter && (settings?.soundEffectsEnabled ?? false);
    final isReducedMotion = context.reduceMotion;

    final hasGoodClue = result.clueOutcome == ClueOutcome.goodClue;

    final scoreDeltas = <String, int>{};
    for (final player in players) {
      scoreDeltas[player.id] = result.totalDeltaFor(player.id);
    }

    final latestRound = RoundData(
      roundNumber: 1,
      storytellerId: storyteller.id,
      votes: votes,
      scoreDeltas: scoreDeltas,
      hasGoodClue: hasGoodClue,
    );

    final playerNames = {for (final p in players) p.id: p.name};

    final milestones = MilestoneDetector.detectMilestones(
      sessionRounds: [latestRound],
      latestRound: latestRound,
      playerNames: playerNames,
    );

    if (milestones.isEmpty) return;

    final celebrationResult = CelebrationEngine.computeMilestoneEffects(
      isSupporter: isSupporter,
      selectedTheme: selectedTheme,
      isReducedMotion: isReducedMotion,
      milestones: milestones,
    );

    if (!celebrationResult.hasEffects) return;

    final overlay = Overlay.of(context);
    final controller = CelebrationController(
      overlayState: overlay,
      isReducedMotion: isReducedMotion,
      isSoundEnabled: soundEnabled,
    );

    controller.play(celebrationResult);
  }
}

/// Storyteller announcement card — crown icon + "[Name] is the storyteller".
class _StorytellerCard extends StatelessWidget {
  const _StorytellerCard({required this.storyteller});

  final Player storyteller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorTokens.goldAccent.withValues(alpha: 0.2),
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
          Image.asset(AppAssets.crownBadge, width: 28),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${storyteller.name} is the storyteller',
                  style: context.textTheme.titleSmall?.copyWith(
                    color: ColorTokens.parchment,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose where each vote landed',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: ColorTokens.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width gradient Score Round button.
class _ScoreRoundButton extends StatelessWidget {
  const _ScoreRoundButton({
    required this.isEnabled,
    required this.isSubmitting,
    required this.label,
    this.onPressed,
  });

  final bool isEnabled;
  final bool isSubmitting;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [ColorTokens.goldAccent, ColorTokens.burgundy],
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: ColorTokens.burgundy.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: SpacingTokens.md,
              ),
              child: Center(
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
