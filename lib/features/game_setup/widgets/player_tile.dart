import 'package:flutter/material.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/core/constants/player_colors.dart';
import 'package:story_score/shared/widgets/custom_icon.dart';

/// A single player row in the reorderable list matching the design mockup.
///
/// Shows drag handle, colored avatar circle, player name (bold), "Seat N"
/// subtitle, and a delete icon on the right.
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.name,
    required this.colorKey,
    required this.seatNumber,
    required this.onRemove,
    this.avatarStyle = 'initials',
  });

  final String name;
  final String colorKey;
  final int seatNumber;
  final VoidCallback onRemove;
  final String avatarStyle;

  @override
  Widget build(BuildContext context) {
    final color = PlayerColors.colorFor(colorKey);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm + 2,
      ),
      decoration: BoxDecoration(
        color: ColorTokens.darkCard.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ColorTokens.goldAccent.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Drag handle
          const Icon(
            Icons.drag_indicator_rounded,
            color: ColorTokens.mutedText,
            size: 20,
          ),
          const SizedBox(width: SpacingTokens.sm),

          // Colored avatar circle
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: avatarStyle != 'initials' && avatarStyle.isNotEmpty
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      avatarStyle,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: SpacingTokens.md),

          // Name + Seat subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorTokens.parchment,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Seat ${seatNumber + 1}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorTokens.mutedText,
                  ),
                ),
              ],
            ),
          ),

          // Delete icon
          IconButton(
            onPressed: onRemove,
            icon: const CustomIcon('delete', size: 20),
            visualDensity: VisualDensity.compact,
            tooltip: 'Remove player',
          ),
        ],
      ),
    );
  }
}
