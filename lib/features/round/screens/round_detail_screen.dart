import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/app_assets.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/core/utils/haptics.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/daos/round_dao.dart';
import 'package:story_score/domain/scoring/round_processor.dart';
import 'package:story_score/domain/scoring/scoring_engine.dart';
import 'package:story_score/features/history/providers/history_providers.dart';
import 'package:story_score/features/round/widgets/round_recap_sheet.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';
import 'package:story_score/shared/widgets/custom_icon.dart';

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
  late Map<String, String> _editVotes;
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
        child: SafeArea(
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

              return Column(
                children: [
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back button + Round title
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.pop(),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: ColorTokens.goldAccent,
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.md),
                              // Round icon circle
                              Container(
                                width: 36,
                                height: 36,
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
                                    width: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: SpacingTokens.sm),
                              Text(
                                '${l10n.round(details.round.roundNumber)} Detail',
                                style: text.headlineMedium?.copyWith(
                                  color: ColorTokens.parchment,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SpacingTokens.md),

                          // Round info card (ROUND number + Storyteller)
                          _RoundInfoCard(
                            roundNumber: details.round.roundNumber,
                            storytellerName:
                                storyteller?.name ?? l10n.unknown,
                          ),
                          const SizedBox(height: SpacingTokens.lg),

                          // VOTES section
                          _SectionTitle(title: l10n.votes),
                          const SizedBox(height: SpacingTokens.sm),
                          _VotesCard(
                            votes: details.votes,
                            playerMap: playerMap,
                          ),
                          const SizedBox(height: SpacingTokens.lg),

                          // SCORE CHANGES section
                          _SectionTitle(title: l10n.scoreChanges),
                          const SizedBox(height: SpacingTokens.sm),
                          _ScoreChangesCard(
                            scoreChanges: details.scoreChanges,
                            playerMap: playerMap,
                          ),
                          const SizedBox(height: SpacingTokens.lg),

                          // Edit mode
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
                                        : () => setState(
                                            () => _isEditing = false),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          ColorTokens.parchment,
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
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.check_rounded,
                                            size: 18,
                                          ),
                                    label: Text(l10n.saveChanges),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Bottom action buttons (when not editing)
                  if (!_isEditing)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(SpacingTokens.md),
                        child: Row(
                          children: [
                            // Edit button
                            Expanded(
                              child: _ActionButton(
                                icon: 'edit',
                                label: l10n.editRound,
                                onTap: () => _startEditing(details),
                                color: ColorTokens.goldAccent,
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.md),
                            // Delete button
                            Expanded(
                              child: _ActionButton(
                                icon: 'delete',
                                label: l10n.deleteRound,
                                onTap: _isDeleting
                                    ? null
                                    : () => _confirmDelete(context),
                                color: ColorTokens.coral,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
    final text = context.textTheme;
    final storyTheme = context.storyTheme;
    final storytellerId =
        _editStorytellerId ?? details.round.storytellerPlayerId;
    final voters = players.where((p) => p.id != storytellerId).toList();

    return voters.map((voter) {
      final currentVote = _editVotes[voter.id];
      final targets = players.where((p) => p.id != voter.id).toList();
      final voterColor = PlayerColors.colorFor(voter.colorKey);

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
                  _PlayerAvatar(
                    name: voter.name,
                    avatarStyle: voter.avatarStyle,
                    color: voterColor,
                    size: 24,
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

                    return Padding(
                      padding:
                          const EdgeInsets.only(right: SpacingTokens.xs),
                      child: ActionChip(
                        label: Text(
                          target.name,
                          style: TextStyle(
                            color: isSelected
                                ? storyTheme.goldAccent
                                : context.colorScheme.onSurfaceVariant,
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
      await deleteRound(
          roundId: widget.roundId, sessionId: widget.sessionId);
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
                  colors: [
                    ColorTokens.darkCard,
                    ColorTokens.darkCardVariant,
                  ],
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

/// Round info card matching the scoreboard style.
class _RoundInfoCard extends StatelessWidget {
  const _RoundInfoCard({
    required this.roundNumber,
    required this.storytellerName,
  });

  final int roundNumber;
  final String storytellerName;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;

    return Container(
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
        child: Row(
          children: [
            // Round number
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROUND',
                  style: text.labelSmall?.copyWith(
                    color: ColorTokens.goldAccent,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  roundNumber.toString().padLeft(2, '0'),
                  style: text.headlineLarge?.copyWith(
                    color: ColorTokens.goldAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: SpacingTokens.lg),
            // Storyteller
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storyteller',
                    style: text.labelSmall?.copyWith(
                      color: ColorTokens.mutedText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    storytellerName,
                    style: text.titleMedium?.copyWith(
                      color: ColorTokens.parchment,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(AppAssets.crownBadge, width: 32),
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
    return Text(
      title.toUpperCase(),
      style: context.textTheme.labelSmall?.copyWith(
        color: ColorTokens.goldAccent,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
        fontSize: 10,
      ),
    );
  }
}

/// Votes card showing "Player -> VotedFor" rows.
class _VotesCard extends StatelessWidget {
  const _VotesCard({
    required this.votes,
    required this.playerMap,
  });

  final List<Vote> votes;
  final Map<String, Player> playerMap;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;

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
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: votes.map((vote) {
            final voter = playerMap[vote.voterPlayerId];
            final votedFor = playerMap[vote.votedForPlayerId];
            final voterColor = voter != null
                ? PlayerColors.colorFor(voter.colorKey)
                : ColorTokens.mutedText;

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: SpacingTokens.xs,
              ),
              child: Row(
                children: [
                  _PlayerAvatar(
                    name: voter?.name ?? '?',
                    avatarStyle: voter?.avatarStyle ?? 'initials',
                    color: voterColor,
                    size: 28,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      '${voter?.name ?? 'Unknown'} \u2192 ${votedFor?.name ?? 'Unknown'}',
                      style: text.bodyMedium?.copyWith(
                        color: ColorTokens.parchment,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Score changes card showing player rows with deltas.
class _ScoreChangesCard extends StatelessWidget {
  const _ScoreChangesCard({
    required this.scoreChanges,
    required this.playerMap,
  });

  final List<ScoreChange> scoreChanges;
  final Map<String, Player> playerMap;

  @override
  Widget build(BuildContext context) {
    final text = context.textTheme;

    // Group by player
    final grouped = <String, List<ScoreChange>>{};
    for (final change in scoreChanges) {
      grouped.putIfAbsent(change.playerId, () => []).add(change);
    }

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
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: grouped.entries.map((entry) {
            final player = playerMap[entry.key];
            final totalDelta =
                entry.value.fold<int>(0, (sum, c) => sum + c.delta);
            final playerColor = player != null
                ? PlayerColors.colorFor(player.colorKey)
                : ColorTokens.mutedText;

            // Build reason label
            final reasonText = totalDelta > 0
                ? entry.value
                    .where((c) => c.delta > 0)
                    .map((c) => c.reasonLabel)
                    .join(', ')
                : 'No points';

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: SpacingTokens.xs + 2,
              ),
              child: Row(
                children: [
                  _PlayerAvatar(
                    name: player?.name ?? '?',
                    avatarStyle: player?.avatarStyle ?? 'initials',
                    color: playerColor,
                    size: 32,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player?.name ?? 'Unknown',
                          style: text.titleSmall?.copyWith(
                            color: ColorTokens.parchment,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          reasonText,
                          style: text.labelSmall?.copyWith(
                            color: ColorTokens.mutedText,
                          ),
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
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Reusable player avatar circle.
class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({
    required this.name,
    required this.avatarStyle,
    required this.color,
    this.size = 28,
  });

  final String name;
  final String avatarStyle;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: avatarStyle != 'initials' && avatarStyle.isNotEmpty
          ? Text(
              avatarStyle,
              style: TextStyle(fontSize: size * 0.45),
            )
          : Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4,
              ),
            ),
    );
  }
}

/// Action button with icon and label for Edit/Delete at bottom.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.md,
          horizontal: SpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIcon(icon, size: 18, color: color),
            const SizedBox(width: SpacingTokens.sm),
            Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
