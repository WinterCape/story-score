import 'package:flutter/material.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/features/scoreboard/widgets/player_score_card.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A row showing a voter's name and a horizontal list of tappable
/// player cards representing vote targets.
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voter label
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: voterColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                voter.name,
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.colorScheme.onSurface,
                ),
              ),
              if (selectedTargetId != null) ...[
                const SizedBox(width: SpacingTokens.sm),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: voterColor,
                ),
              ],
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          // Horizontal scrolling target cards
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
