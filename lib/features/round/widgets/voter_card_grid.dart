import 'package:flutter/material.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/features/scoreboard/widgets/player_score_card.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A section showing a voter's name/avatar and a horizontal list of tappable
/// player chips representing vote targets. Uses warm storybook styling.
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
    final hasVoted = selectedTargetId != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
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
              // Voter avatar
              Container(
                width: 24,
                height: 24,
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
                child: Text(
                  voter.name,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: ColorTokens.parchment,
                  ),
                ),
              ),
              Text(
                'voted for:',
                style: context.textTheme.labelSmall?.copyWith(
                  color: ColorTokens.mutedText,
                ),
              ),
              if (hasVoted) ...[
                const SizedBox(width: SpacingTokens.xs),
                Icon(Icons.check_circle, size: 16, color: ColorTokens.goldAccent),
              ],
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Horizontal scrolling target chips
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: targets.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: SpacingTokens.sm),
              itemBuilder: (context, index) {
                final target = targets[index];
                final isSelected = target.id == selectedTargetId;

                return SizedBox(
                  width: 80,
                  child: PlayerChip(
                    player: target,
                    isSelected: isSelected,
                    onTap: () => onTargetSelected(target.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
