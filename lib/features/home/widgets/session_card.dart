import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/features/home/providers/home_providers.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

/// A card displaying a saved game session's summary information.
class SessionCard extends ConsumerWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onDismissed,
  });

  final GameSession session;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.textTheme;
    final storyTheme = context.storyTheme;

    final isActive = session.status == GameStatus.active;
    final isPaused = session.status == GameStatus.paused;
    final isCompleted = session.status == GameStatus.completed;

    final playerCountAsync = ref.watch(playerCountProvider(session.id));
    final playerCount = switch (playerCountAsync) {
      AsyncData(:final value) => value,
      _ => 0,
    };

    final playersAsync = ref.watch(sessionPlayersProvider(session.id));
    final players = switch (playersAsync) {
      AsyncData(:final value) => value,
      _ => <Player>[],
    };

    final title = session.title.isNotEmpty ? session.title : 'Untitled Game';

    final accentColor = isActive
        ? storyTheme.goldAccent
        : isPaused
        ? ColorTokens.teal
        : ColorTokens.mutedText;

    final statusLabel = switch (session.status) {
      GameStatus.active => 'active',
      GameStatus.paused => 'paused',
      GameStatus.completed => 'completed',
    };

    // Choose emoji for the mini card icon
    final cardEmoji = isCompleted ? '\u{1F3C6}' : '\u{1F0CF}';

    return Semantics(
      label:
          'Game $title, $playerCount players, round ${session.roundCount}, $statusLabel',
      button: true,
      excludeSemantics: true,
      child: Dismissible(
        key: ValueKey(session.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed(),
        confirmDismiss: (_) => _confirmDelete(context),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: SpacingTokens.lg),
          decoration: BoxDecoration(
            color: context.colorScheme.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: context.colorScheme.onError,
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
              ),
              borderRadius: BorderRadius.circular(14),
              border: isActive
                  ? Border.all(
                      color: ColorTokens.goldAccent.withValues(alpha: 0.4),
                      width: 1.5,
                    )
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
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
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              children: [
                // Mini card-shaped icon
                _MiniCardIcon(
                  emoji: cardEmoji,
                  isActive: isActive,
                ),
                const SizedBox(width: SpacingTokens.md),
                // Session info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: text.titleMedium?.copyWith(
                                color: ColorTokens.parchment,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          _StatusBadge(
                            status: session.status,
                            accentColor: accentColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.xs),

                      // Metadata row
                      DefaultTextStyle(
                        style: text.bodySmall!.copyWith(
                          color: ColorTokens.mutedText,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_outline_rounded,
                              size: 14,
                              color: ColorTokens.mutedText,
                            ),
                            const SizedBox(width: 4),
                            Text('$playerCount'),
                            const SizedBox(width: SpacingTokens.md),
                            const Icon(
                              Icons.loop_rounded,
                              size: 14,
                              color: ColorTokens.mutedText,
                            ),
                            const SizedBox(width: 4),
                            Text('Round ${session.roundCount}'),
                            const SizedBox(width: SpacingTokens.md),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: ColorTokens.mutedText,
                            ),
                            const SizedBox(width: 4),
                            Text(_formatDate(session.updatedAt)),
                          ],
                        ),
                      ),

                      // Player avatar bubbles
                      if (players.isNotEmpty) ...[
                        const SizedBox(height: SpacingTokens.sm),
                        _PlayerAvatarRow(players: players),
                      ],
                    ],
                  ),
                ),

                // Right chevron
                if (!isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(left: SpacingTokens.sm),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: ColorTokens.mutedText,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Game'),
        content: const Text(
          'This will permanently delete this game and all its rounds. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Mini card-shaped icon with parchment gradient and gold border.
class _MiniCardIcon extends StatelessWidget {
  const _MiniCardIcon({required this.emoji, required this.isActive});

  final String emoji;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorTokens.lightBackground,
            ColorTokens.lightSurface,
            Color(0xFFE8D0A0),
          ],
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isActive
              ? ColorTokens.goldAccent
              : ColorTokens.goldAccent.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: ColorTokens.goldAccent.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// Row of small player avatar circles.
class _PlayerAvatarRow extends StatelessWidget {
  const _PlayerAvatarRow({required this.players});

  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    // Show max 6 avatars, then a +N indicator
    final maxVisible = 6;
    final visible = players.take(maxVisible).toList();
    final remaining = players.length - maxVisible;

    return Row(
      children: [
        ...visible.map((player) {
          final color = _playerColor(player.colorKey);
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                border: Border.all(
                  color: color.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: player.avatarStyle != 'initials' &&
                        player.avatarStyle.isNotEmpty
                    ? Text(
                        player.avatarStyle,
                        style: const TextStyle(fontSize: 10),
                      )
                    : Text(
                        player.name.isNotEmpty
                            ? player.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          );
        }),
        if (remaining > 0)
          Text(
            '+$remaining',
            style: context.textTheme.labelSmall?.copyWith(
              color: ColorTokens.mutedText,
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  Color _playerColor(String colorKey) {
    const colors = <String, Color>{
      'aurora_teal': Color(0xFF2EC4B6),
      'soft_violet': Color(0xFF7B68EE),
      'gold': Color(0xFFD4A742),
      'coral': Color(0xFFFF6B6B),
      'emerald': Color(0xFF2ECC71),
      'ocean_blue': Color(0xFF3498DB),
      'sunset_orange': Color(0xFFE67E22),
      'rose_pink': Color(0xFFE91E8C),
      'lime_green': Color(0xFF8BC34A),
      'slate_blue': Color(0xFF5C6BC0),
      'amber': Color(0xFFFFC107),
      'plum': Color(0xFF9C27B0),
    };
    return colors[colorKey] ?? colors.values.first;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.accentColor});

  final GameStatus status;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      GameStatus.active => 'Active',
      GameStatus.paused => 'Paused',
      GameStatus.completed => 'Completed',
    };

    final icon = switch (status) {
      GameStatus.active => Icons.play_arrow_rounded,
      GameStatus.paused => Icons.pause_rounded,
      GameStatus.completed => Icons.check_circle_outline_rounded,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: accentColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
