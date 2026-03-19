import 'package:flutter/material.dart';
import 'package:story_score/app/theme/motion_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A card displaying a player's name, color indicator, score, and
/// an optional storyteller badge. Uses warm storybook styling.
class PlayerScoreCard extends StatelessWidget {
  const PlayerScoreCard({
    super.key,
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
    final storyTheme = context.storyTheme;

    final rankLabel = rank != null ? ', ${_ordinal(rank!)} place' : '';
    final storytellerLabel = isStoryteller ? ', current storyteller' : '';

    return Semantics(
      label:
          'Player ${player.name}, score ${player.currentScore}$rankLabel$storytellerLabel',
      button: onLongPress != null,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: MotionTokens.durationMedium,
          curve: MotionTokens.curveStandard,
          decoration: BoxDecoration(
            gradient: storyTheme.cardGradient,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isStoryteller
                  ? storyTheme.goldAccent.withValues(alpha: 0.4)
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
                  color: storyTheme.goldAccent.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top row: avatar + name + storyteller badge
                Row(
                  children: [
                    // Avatar circle with gradient
                    _PlayerAvatar(
                      player: player,
                      playerColor: playerColor,
                      size: 28,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    // Player name
                    Expanded(
                      child: Text(
                        player.name,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: storyTheme.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Storyteller badge
                    if (isStoryteller) ...[
                      const SizedBox(width: SpacingTokens.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: storyTheme.goldAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            SpacingTokens.radiusSm,
                          ),
                          border: Border.all(
                            color: storyTheme.goldAccent.withValues(
                              alpha: 0.5,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '\u{1F451}',
                              style: TextStyle(fontSize: 10),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Storyteller',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: storyTheme.goldAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: SpacingTokens.xs),
                // Score — animated counter
                Flexible(
                  child: _AnimatedScore(
                    score: player.currentScore,
                    isFirstPlace: isFirstPlace,
                  ),
                ),
                // Rank indicator
                if (rank != null)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.xs),
                    child: Text(
                      _ordinal(rank!),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: storyTheme.secondaryText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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

/// Player avatar circle with gradient background and emoji.
class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({
    required this.player,
    required this.playerColor,
    this.size = 28,
  });

  final Player player;
  final Color playerColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [playerColor, playerColor.withValues(alpha: 0.7)],
        ),
        border: Border.all(
          color: playerColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: player.avatarStyle != 'initials' &&
                player.avatarStyle.isNotEmpty
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  player.avatarStyle,
                  style: TextStyle(fontSize: size * 0.55),
                  textAlign: TextAlign.center,
                ),
              )
            : Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: size * 0.4,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

/// Implicitly animated score text that tweens between old and new values.
class _AnimatedScore extends ImplicitlyAnimatedWidget {
  const _AnimatedScore({
    required this.score,
    required this.isFirstPlace,
  }) : super(
          duration: MotionTokens.durationSlow,
          curve: MotionTokens.curveDecelerate,
        );

  final int score;
  final bool isFirstPlace;

  @override
  ImplicitlyAnimatedWidgetState<_AnimatedScore> createState() =>
      _AnimatedScoreState();
}

class _AnimatedScoreState extends AnimatedWidgetBaseState<_AnimatedScore> {
  IntTween? _scoreTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _scoreTween =
        visitor(
              _scoreTween,
              widget.score,
              (dynamic value) => IntTween(begin: value as int),
            )
            as IntTween?;
  }

  @override
  Widget build(BuildContext context) {
    final value = _scoreTween?.evaluate(animation) ?? widget.score;
    final storyTheme = context.storyTheme;
    return Text(
      '$value',
      style: context.textTheme.displaySmall?.copyWith(
        color: widget.isFirstPlace
            ? storyTheme.primaryAccent
            : storyTheme.primaryText,
        fontWeight: FontWeight.w800,
        shadows: widget.isFirstPlace
            ? [
                Shadow(
                  color: storyTheme.primaryAccent.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
    );
  }
}

/// A compact version of the player card used in selection contexts
/// (e.g. vote targets in the round screen).
class PlayerChip extends StatelessWidget {
  const PlayerChip({
    super.key,
    required this.player,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
  });

  final Player player;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final playerColor = PlayerColors.colorFor(player.colorKey);

    final selectedLabel = isSelected ? ', selected' : '';
    final disabledLabel = isDisabled ? ', unavailable' : '';

    return Semantics(
      label: 'Vote for ${player.name}$selectedLabel$disabledLabel',
      button: true,
      enabled: !isDisabled,
      selected: isSelected,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: AnimatedContainer(
          duration: MotionTokens.durationFast,
          curve: MotionTokens.curveStandard,
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md,
            vertical: SpacingTokens.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? context.storyTheme.primaryAccent.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border: Border.all(
              color: isSelected
                  ? context.storyTheme.primaryAccent
                  : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar circle with gradient
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDisabled
                          ? playerColor.withValues(alpha: 0.3)
                          : playerColor,
                      isDisabled
                          ? playerColor.withValues(alpha: 0.15)
                          : playerColor.withValues(alpha: 0.7),
                    ],
                  ),
                  border: Border.all(
                    color: playerColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: _buildChipAvatar(context, player, isDisabled),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                player.name,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isDisabled
                      ? context.storyTheme.secondaryText.withValues(alpha: 0.5)
                      : isSelected
                      ? context.storyTheme.primaryAccent
                      : context.storyTheme.primaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle,
                    size: 14,
                    color: context.storyTheme.primaryAccent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipAvatar(
    BuildContext context,
    Player player,
    bool isDisabled,
  ) {
    if (player.avatarStyle != 'initials' && player.avatarStyle.isNotEmpty) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          player.avatarStyle,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Text(
      player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
      style: context.textTheme.labelSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
