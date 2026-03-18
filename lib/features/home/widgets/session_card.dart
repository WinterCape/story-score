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
    final colors = context.colorScheme;
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

    final title = session.title.isNotEmpty ? session.title : 'Untitled Game';

    final accentColor = isActive
        ? storyTheme.goldAccent
        : isPaused
        ? ColorTokens.auroraTeal
        : colors.onSurfaceVariant;

    final statusLabel = switch (session.status) {
      GameStatus.active => 'active',
      GameStatus.paused => 'paused',
      GameStatus.completed => 'completed',
    };

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
            color: colors.error,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          ),
          child: Icon(Icons.delete_outline_rounded, color: colors.onError),
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            child: Container(
              decoration: BoxDecoration(
                border: isActive
                    ? Border(
                        left: BorderSide(
                          color: storyTheme.goldAccent,
                          width: 3,
                        ),
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Row(
                children: [
                  // Left: session info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: text.titleMedium?.copyWith(
                                  color: colors.onSurface,
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
                            color: colors.onSurfaceVariant,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_outline_rounded,
                                size: 14,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text('$playerCount'),
                              const SizedBox(width: SpacingTokens.md),
                              Icon(
                                Icons.loop_rounded,
                                size: 14,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text('Round ${session.roundCount}'),
                              const SizedBox(width: SpacingTokens.md),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: colors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(_formatDate(session.updatedAt)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right chevron
                  if (!isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(left: SpacingTokens.sm),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
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
