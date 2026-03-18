import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/daos/round_dao.dart';
import 'package:story_score/domain/scoring/round_processor.dart';
import 'package:story_score/domain/scoring/scoring_engine.dart';
import 'package:story_score/features/history/providers/history_providers.dart';
import 'package:story_score/features/round/widgets/round_recap_sheet.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// Provides the players list for a given session.
final _playersForSessionProvider = StreamProvider.family<List<Player>, String>((
  ref,
  sessionId,
) {
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
  bool _isEditing = false;
  bool _isSavingEdit = false;
  late Map<String, String> _editVotes; // voterPlayerId -> votedForPlayerId
  String? _editStorytellerId;

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(roundWithDetailsProvider(widget.roundId));
    final playersAsync = ref.watch(
      _playersForSessionProvider(widget.sessionId),
    );

    final colors = context.colorScheme;
    final text = context.textTheme;
    final l10n = context.l10n;

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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              title: Text(
                l10n.roundDetail,
                style: const TextStyle(color: ColorTokens.parchment),
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: ColorTokens.goldAccent,
                ),
                onPressed: () => context.pop(),
              ),
            ),
            SliverToBoxAdapter(
              child: detailsAsync.when(
                data: (details) {
                  if (details == null) {
                    return Center(child: Text(l10n.roundNotFound));
                  }

                  final players = switch (playersAsync) {
                    AsyncData(:final value) => value,
                    _ => <Player>[],
                  };
                  final playerMap = {for (final p in players) p.id: p};
                  final storyteller =
                      playerMap[details.round.storytellerPlayerId];
                  final hasGoodClue = details.scoreChanges.any(
                    (sc) => sc.reasonCode == 'storytellerGoodClue',
                  );

                  return Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Round header with cardGradient
                        _RoundHeader(
                          roundNumber: details.round.roundNumber,
                          storytellerName:
                              storyteller?.name ?? l10n.unknown,
                          storytellerColor: storyteller != null
                              ? PlayerColors.colorFor(storyteller.colorKey)
                              : colors.primary,
                          hasGoodClue: hasGoodClue,
                          note: details.round.note,
                          editedAt: details.round.editedAt,
                        ),
                        const SizedBox(height: SpacingTokens.lg),

                        // Votes section
                        _SectionTitle(title: l10n.votes),
                        const SizedBox(height: SpacingTokens.sm),
                        ...details.votes.map((vote) {
                          final voter = playerMap[vote.voterPlayerId];
                          final votedFor = playerMap[vote.votedForPlayerId];
                          final votedForStoryteller = vote.votedForPlayerId ==
                              details.round.storytellerPlayerId;
                          return _VoteTile(
                            voterName: voter?.name ?? l10n.unknown,
                            voterColor: voter != null
                                ? PlayerColors.colorFor(voter.colorKey)
                                : colors.primary,
                            votedForName: votedFor?.name ?? l10n.unknown,
                            isCorrect: votedForStoryteller,
                          );
                        }),
                        const SizedBox(height: SpacingTokens.lg),

                        // Score changes section
                        _SectionTitle(title: l10n.scoreChanges),
                        const SizedBox(height: SpacingTokens.sm),
                        ..._groupScoreChangesByPlayer(
                          details.scoreChanges,
                          playerMap,
                        ).entries.map((entry) {
                          final player = playerMap[entry.key];
                          return _ScoreChangeTile(
                            playerName: player?.name ?? l10n.unknown,
                            playerColor: player != null
                                ? PlayerColors.colorFor(player.colorKey)
                                : colors.primary,
                            changes: entry.value,
                          );
                        }),
                        const SizedBox(height: SpacingTokens.xl),

                        // Edit mode: vote editing UI
                        if (_isEditing) ...[
                          _SectionTitle(title: l10n.editVotes),
                          const SizedBox(height: SpacingTokens.sm),
                          ..._buildEditVoteRows(players, details),
                          const SizedBox(height: SpacingTokens.md),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSavingEdit
                                      ? null
                                      : () =>
                                          setState(() => _isEditing = false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ColorTokens.parchment,
                                    side: BorderSide(
                                      color: ColorTokens.parchment
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(l10n.cancel),
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.md),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _isSavingEdit
                                      ? null
                                      : () => _saveEdit(
                                          context, players, details),
                                  icon: _isSavingEdit
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.check_rounded,
                                          size: 18),
                                  label: Text(l10n.saveChanges),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpacingTokens.xl),
                        ] else ...[
                          // Action buttons (view mode)
                          Row(
                            children: [
                              // Edit button
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _startEditing(details),
                                  icon: const Icon(Icons.edit_rounded,
                                      size: 18),
                                  label: Text(l10n.editRound),
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.md),
                              // Delete button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isDeleting
                                      ? null
                                      : () => _confirmDelete(context),
                                  icon: _isDeleting
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colors.error,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                        ),
                                  label: Text(l10n.deleteRound),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colors.error,
                                    side: BorderSide(
                                      color:
                                          colors.error.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpacingTokens.xl),
                        ],
                      ],
                    ),
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
                        Text(l10n.failedToLoadRound, style: text.titleMedium),
                        const SizedBox(height: SpacingTokens.sm),
                        Text(
                          error.toString(),
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startEditing(RoundWithDetails details) {
    setState(() {
      _isEditing = true;
      _editStorytellerId = details.round.storytellerPlayerId;
      _editVotes = {
        for (final vote in details.votes)
          vote.voterPlayerId: vote.votedForPlayerId,
      };
    });
  }

  List<Widget> _buildEditVoteRows(
    List<Player> players,
    RoundWithDetails details,
  ) {
    final colors = context.colorScheme;
    final text = context.textTheme;
    final storyTheme = context.storyTheme;
    final storytellerId =
        _editStorytellerId ?? details.round.storytellerPlayerId;
    final voters = players.where((p) => p.id != storytellerId).toList();

    return voters.map((voter) {
      final currentVote = _editVotes[voter.id];
      final targets = players.where((p) => p.id != voter.id).toList();

      return Container(
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PlayerColors.colorFor(
                        voter.colorKey,
                      ).withValues(alpha: 0.2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      voter.name.isNotEmpty
                          ? voter.name[0].toUpperCase()
                          : '?',
                      style: text.labelSmall?.copyWith(
                        color: PlayerColors.colorFor(voter.colorKey),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    voter.name,
                    style: text.titleSmall?.copyWith(
                      color: ColorTokens.parchment,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: targets.map((target) {
                    final isSelected = currentVote == target.id;
                    final targetColor =
                        PlayerColors.colorFor(target.colorKey);

                    return Padding(
                      padding:
                          const EdgeInsets.only(right: SpacingTokens.xs),
                      child: ActionChip(
                        avatar: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: targetColor.withValues(alpha: 0.3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            target.name.isNotEmpty
                                ? target.name[0].toUpperCase()
                                : '?',
                            style: text.labelSmall?.copyWith(
                              color: targetColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        label: Text(
                          target.name,
                          style: TextStyle(
                            color: isSelected
                                ? storyTheme.goldAccent
                                : colors.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? storyTheme.goldAccent
                                .withValues(alpha: 0.15)
                            : null,
                        side: isSelected
                            ? BorderSide(color: storyTheme.goldAccent)
                            : null,
                        onPressed: () {
                          Haptics.selection();
                          setState(() {
                            if (isSelected) {
                              _editVotes.remove(voter.id);
                            } else {
                              _editVotes[voter.id] = target.id;
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Future<void> _saveEdit(
    BuildContext context,
    List<Player> players,
    RoundWithDetails details,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final storytellerId =
        _editStorytellerId ?? details.round.storytellerPlayerId;
    final voters = players.where((p) => p.id != storytellerId).toList();

    // Validate all voters have voted
    for (final voter in voters) {
      if (!_editVotes.containsKey(voter.id)) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.playerNotVotedYet(voter.name))),
        );
        return;
      }
    }

    setState(() => _isSavingEdit = true);
    try {
      final roundDao = ref.read(roundDaoProvider);
      final sessionDao = ref.read(sessionDaoProvider);

      final processor = RoundProcessor(
        engine: const ScoringEngine(),
        roundDao: roundDao,
        sessionDao: sessionDao,
      );

      final result = await processor.editRound(
        roundId: widget.roundId,
        sessionId: widget.sessionId,
        storytellerPlayerId: storytellerId,
        allPlayerIds: players.map((p) => p.id).toList(),
        votes: _editVotes,
        note: details.round.note,
      );

      Haptics.medium();

      if (!mounted) return;

      setState(() {
        _isEditing = false;
        _isSavingEdit = false;
      });

      // Show recap
      if (!mounted) return;
      if (!context.mounted) return;
      await showRoundRecapSheet(
        context: context,
        result: result,
        players: players,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSavingEdit = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.failedToSaveChanges('$e'))),
      );
    }
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
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteRound),
        content: Text(l10n.deleteRoundConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final deleteRound = ref.read(deleteRoundProvider);
      await deleteRound(roundId: widget.roundId, sessionId: widget.sessionId);
      if (!mounted) return;
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.failedToDeleteRound('$e'))),
      );
    }
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
                ),
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusLg),
              ),
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
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorTokens.goldAccent.withValues(alpha: 0.15),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
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
                    gradient: LinearGradient(
                      colors: [
                        ColorTokens.goldAccent.withValues(alpha: 0.2),
                        ColorTokens.goldAccent.withValues(alpha: 0.1),
                      ],
                    ),
                    border: Border.all(
                      color: ColorTokens.goldAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$roundNumber',
                    style: text.titleLarge?.copyWith(
                      color: ColorTokens.goldAccent,
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
                        l10n.round(roundNumber),
                        style: text.titleMedium?.copyWith(
                          color: ColorTokens.parchment,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            hasGoodClue
                                ? Icons.lightbulb_rounded
                                : Icons.lightbulb_outline_rounded,
                            size: 16,
                            color: hasGoodClue
                                ? ColorTokens.goldAccent
                                : ColorTokens.dustyRose,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hasGoodClue ? l10n.goodClue : l10n.badClue,
                            style: text.bodySmall?.copyWith(
                              color: hasGoodClue
                                  ? ColorTokens.goldAccent
                                  : ColorTokens.dustyRose,
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
                    message: l10n.edited,
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
                    gradient: LinearGradient(
                      colors: [
                        storytellerColor,
                        storytellerColor.withValues(alpha: 0.7),
                      ],
                    ),
                    border: Border.all(
                      color: storytellerColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    storytellerName.isNotEmpty
                        ? storytellerName[0].toUpperCase()
                        : '?',
                    style: text.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  l10n.storytellerLabel(storytellerName),
                  style: text.bodyMedium?.copyWith(
                    color: ColorTokens.parchment,
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
                  color: ColorTokens.darkBackground.withValues(alpha: 0.5),
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusSm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: ColorTokens.mutedText,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(
                        note,
                        style: text.bodySmall?.copyWith(
                          color: ColorTokens.mutedText,
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
        title.toUpperCase(),
        style: context.textTheme.labelLarge?.copyWith(
          color: ColorTokens.goldAccent,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
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
    final text = context.textTheme;
    final storyTheme = context.storyTheme;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    voterColor,
                    voterColor.withValues(alpha: 0.7),
                  ],
                ),
                border: Border.all(
                  color: voterColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                voterName.isNotEmpty ? voterName[0].toUpperCase() : '?',
                style: text.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: text.bodyMedium?.copyWith(
                    color: ColorTokens.parchment,
                  ),
                  children: [
                    TextSpan(text: voterName),
                    TextSpan(
                      text: ' ${l10n.votedFor} ',
                      style: const TextStyle(color: ColorTokens.mutedText),
                    ),
                    TextSpan(
                      text: votedForName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            if (isCorrect)
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: storyTheme.teal,
              )
            else
              Icon(
                Icons.cancel_outlined,
                size: 18,
                color: ColorTokens.mutedText.withValues(alpha: 0.4),
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
    final text = context.textTheme;

    final totalDelta = changes.fold<int>(0, (sum, c) => sum + c.delta);

    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
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
              child: Text(
                playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
                style: text.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName,
                    style: text.titleSmall?.copyWith(
                      color: ColorTokens.parchment,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: SpacingTokens.sm,
                    children: changes.map((c) {
                      return Text(
                        '+${c.delta} ${c.reasonLabel}',
                        style: text.bodySmall?.copyWith(
                          color: ColorTokens.mutedText,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Text(
              '+$totalDelta',
              style: text.titleMedium?.copyWith(
                color: totalDelta > 0
                    ? ColorTokens.goldAccent
                    : ColorTokens.parchment,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
