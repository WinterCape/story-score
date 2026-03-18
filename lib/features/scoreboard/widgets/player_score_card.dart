import 'package:flutter/material.dart';
import 'package:story_score/app/theme/motion_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A card displaying a player's name, color indicator, score, and
/// an optional storyteller badge. Features an animated score counter.
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
    final goldAccent = context.storyTheme.goldAccent;

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
            gradient: context.storyTheme.cardGradient,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            border: Border.all(
              color: isStoryteller
                  ? goldAccent
                  : playerColor.withValues(alpha: 0.3),
              width: isStoryteller ? 2.0 : 1.0,
            ),
            boxShadow: isStoryteller
                ? [
                    BoxShadow(
                      color: goldAccent.withValues(alpha: 0.25),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top row: color dot + name + storyteller badge
                Row(
                  children: [
                    // Color indicator / emoji avatar
                    if (player.avatarStyle != 'initials' &&
                        player.avatarStyle.isNotEmpty)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(
                          child: Text(
                            player.avatarStyle,
                            style: const TextStyle(fontSize: 16, height: 1),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: playerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(width: SpacingTokens.sm),
                    // Player name
                    Expanded(
                      child: Text(
                        player.name,
                        style: context.textTheme.titleSmall?.copyWith(
                          color: context.colorScheme.onSurface,
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
                          color: goldAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            SpacingTokens.radiusSm,
                          ),
                          border: Border.all(
                            color: goldAccent.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_stories,
                              size: 12,
                              color: goldAccent,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Storyteller',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: goldAccent,
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
                    color: playerColor,
                  ),
                ),
                // Rank indicator
                if (rank != null)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.xs),
                    child: Text(
                      _ordinal(rank!),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
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

/// Implicitly animated score text that tweens between old and new values.
class _AnimatedScore extends ImplicitlyAnimatedWidget {
  const _AnimatedScore({required this.score, required this.color})
    : super(
        duration: MotionTokens.durationSlow,
        curve: MotionTokens.curveDecelerate,
      );

  final int score;
  final Color color;

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
    return Text(
      '$value',
      style: context.textTheme.displaySmall?.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w800,
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
                ? playerColor.withValues(alpha: 0.2)
                : context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            border: Border.all(
              color: isSelected
                  ? playerColor
                  : isDisabled
                  ? context.colorScheme.outlineVariant.withValues(alpha: 0.3)
                  : context.colorScheme.outlineVariant,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color dot / emoji avatar
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDisabled
                      ? playerColor.withValues(alpha: 0.3)
                      : playerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      player.avatarStyle != 'initials' &&
                          player.avatarStyle.isNotEmpty
                      ? Text(
                          player.avatarStyle,
                          style: const TextStyle(fontSize: 14, height: 1),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          player.name.isNotEmpty
                              ? player.name[0].toUpperCase()
                              : '?',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Text(
                player.name,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isDisabled
                      ? context.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        )
                      : isSelected
                      ? playerColor
                      : context.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle, size: 14, color: playerColor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
