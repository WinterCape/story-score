import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
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
    final storytellerAsync =
        ref.watch(currentStorytellerProvider(widget.sessionId));
    final voteState = ref.watch(voteEntryProvider);

    return sessionAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Error: $e')),
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

        return playersAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) => Scaffold(
            body: Center(child: Text('Error: $e')),
          ),
          data: (players) {
            final storyteller = storytellerAsync.value;

            if (storyteller == null) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'No storyteller assigned',
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
              // Schedule the init for after build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(voteEntryProvider.notifier).init(nonStorytellerIds);
              });
              _initialized = true;
            }

            final nonStorytellerPlayers =
                players.where((p) => p.id != storyteller.id).toList();

            return Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.isTablet ? 600 : double.infinity,
                  ),
                  child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: _RoundHeader(
                      session: session,
                      storyteller: storyteller,
                    ),
                  ),

                  // Optional note field
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md,
                        vertical: SpacingTokens.sm,
                      ),
                      child: TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: 'Round note (optional)',
                          prefixIcon: const Icon(Icons.note_alt_outlined,
                              size: 20),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.md,
                            vertical: SpacingTokens.sm,
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        maxLines: 1,
                      ),
                    ),
                  ),

                  // Instruction
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md,
                        vertical: SpacingTokens.sm,
                      ),
                      child: Text(
                        'Who did each player vote for?',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                  // Voter rows
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final voter = nonStorytellerPlayers[index];
                        // Targets: all players except storyteller and
                        // the voter themselves.
                        final targets = players
                            .where((p) =>
                                p.id != storyteller.id && p.id != voter.id)
                            .toList();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpacingTokens.md,
                          ),
                          child: VoterCardGrid(
                            voter: voter,
                            targets: targets,
                            selectedTargetId: voteState.votes[voter.id],
                            onTargetSelected: (targetId) {
                              Haptics.selection();
                              // Toggle: tap again to deselect
                              if (voteState.votes[voter.id] == targetId) {
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
                      },
                      childCount: nonStorytellerPlayers.length,
                    ),
                  ),

                  // Bottom padding for the button
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
                ),
              ),

              // Score Round button
              bottomNavigationBar: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Semantics(
                    label: voteState.allVotesCast
                        ? 'Score round'
                        : 'Score round, disabled, all players must vote first',
                    button: true,
                    enabled: voteState.allVotesCast && !_isSubmitting,
                    excludeSemantics: true,
                    child: FilledButton(
                      onPressed: voteState.allVotesCast && !_isSubmitting
                          ? () => _submitRound(
                                session: session,
                                storyteller: storyteller,
                                players: players,
                                votes: voteState.completedVotes,
                              )
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: context.storyTheme.goldAccent,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor:
                            context.colorScheme.surfaceContainerHighest,
                        padding: const EdgeInsets.symmetric(
                          vertical: SpacingTokens.md,
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              voteState.allVotesCast
                                  ? 'Score Round'
                                  : 'All players must vote',
                            ),
                    ),
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

    try {
      final result = await ref.read(roundProcessorProvider).submitRound(
            sessionId: widget.sessionId,
            storytellerPlayerId: storyteller.id,
            allPlayerIds: players.map((p) => p.id).toList(),
            votes: votes,
            note: _noteController.text.trim(),
          );

      if (!mounted) return;

      Haptics.medium();

      // Detect milestones for this round
      _triggerMilestoneCelebrations(
        result: result,
        storyteller: storyteller,
        players: players,
        votes: votes,
      );

      // Show recap bottom sheet — context is guarded by mounted check above
      await showRoundRecapSheet(
        context: ctx, // ignore: use_build_context_synchronously
        result: result,
        players: players,
      );

      if (!mounted) return;

      // Reset state for next round
      ref.read(voteEntryProvider.notifier).clearAll();
      _noteController.clear();
      _initialized = false;

      // Navigate back to scoreboard
      navigator.go('/game/${widget.sessionId}/scoreboard');
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error scoring round: $e')),
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

    // Build the RoundData for milestone detection
    final hasGoodClue = result.clueOutcome == ClueOutcome.goodClue;

    // Build score deltas map from the result
    final scoreDeltas = <String, int>{};
    for (final player in players) {
      scoreDeltas[player.id] = result.totalDeltaFor(player.id);
    }

    final latestRound = RoundData(
      roundNumber: 1, // Only the latest round matters for detection
      storytellerId: storyteller.id,
      votes: votes,
      scoreDeltas: scoreDeltas,
      hasGoodClue: hasGoodClue,
    );

    // Build player names map
    final playerNames = {
      for (final p in players) p.id: p.name,
    };

    final milestones = MilestoneDetector.detectMilestones(
      sessionRounds: [latestRound], // simplified: only latest round
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

/// Round header showing storyteller name and round number.
class _RoundHeader extends StatelessWidget {
  const _RoundHeader({
    required this.session,
    required this.storyteller,
  });

  final GameSession session;
  final Player storyteller;

  @override
  Widget build(BuildContext context) {
    final storytellerColor = PlayerColors.colorFor(storyteller.colorKey);
    final goldAccent = context.storyTheme.goldAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.lg,
        SpacingTokens.lg,
        SpacingTokens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round number
          Text(
            'Round ${session.roundCount + 1}',
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Storyteller row
          Semantics(
            label: '${storyteller.name} is the current storyteller',
            excludeSemantics: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: goldAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
                border: Border.all(
                  color: goldAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_stories,
                    size: 18,
                    color: goldAccent,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: storytellerColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    '${storyteller.name} is the Storyteller',
                    style: context.textTheme.titleSmall?.copyWith(
                      color: goldAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
