import 'package:flutter/material.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A section showing a voter's name/avatar and a horizontal row of tappable
/// name chips representing vote targets. Matches the mockup design.
class VoterCardGrid extends StatelessWidget {
  const VoterCardGrid({
    super.key,
    required this.voter,
    required this.targets,
    required this.selectedTargetId,
    required this.onTargetSelected,
  });

  /// The player who is voting.
  final Player voter;

  /// Available vote targets (all players except the voter themselves).
  final List<Player> targets;

  /// The currently selected target's ID, or null if not yet voted.
  final String? selectedTargetId;

  /// Called when the voter taps a target.
  final void Function(String targetPlayerId) onTargetSelected;

  @override
  Widget build(BuildContext context) {
    final voterColor = PlayerColors.colorFor(voter.colorKey);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
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
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voter label with avatar
          Row(
            children: [
              // Voter avatar circle
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [voterColor, voterColor.withValues(alpha: 0.7)],
                  ),
                  border: Border.all(
                    color: voterColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: voter.avatarStyle != 'initials' &&
                          voter.avatarStyle.isNotEmpty
                      ? Text(
                          voter.avatarStyle,
                          style: const TextStyle(fontSize: 12),
                        )
                      : Text(
                          voter.name.isNotEmpty
                              ? voter.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voter.name,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: ColorTokens.parchment,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'voted for:',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: ColorTokens.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Horizontal row of name chips
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.xs,
            children: targets.map((target) {
              final isSelected = target.id == selectedTargetId;
              final isSelf = target.id == voter.id;

              return _VoteChip(
                name: target.name,
                isSelected: isSelected,
                isDisabled: isSelf,
                onTap: isSelf ? null : () => onTargetSelected(target.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Outlined name chip for vote selection.
class _VoteChip extends StatelessWidget {
  const _VoteChip({
    required this.name,
    required this.isSelected,
    required this.isDisabled,
    this.onTap,
  });

  final String name;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorTokens.goldAccent.withValues(alpha: 0.15)
              : isDisabled
                  ? Colors.white.withValues(alpha: 0.02)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ColorTokens.goldAccent
                : isDisabled
                    ? Colors.white.withValues(alpha: 0.06)
                    : ColorTokens.parchment.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          name,
          style: context.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? ColorTokens.goldAccent
                : isDisabled
                    ? ColorTokens.mutedText.withValues(alpha: 0.4)
                    : ColorTokens.parchment,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
