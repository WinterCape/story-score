import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/domain/stats/milestone_detector.dart';

/// Animated banner that slides down from the top showing a milestone
/// achievement for a player. Auto-dismisses after 2.5 seconds.
///
/// Respects reduced motion: when [reducedMotion] is true, transitions
/// are instant (zero duration).
class MilestoneToast extends StatefulWidget {
  const MilestoneToast({
    super.key,
    required this.milestone,
    required this.onDismissed,
    this.reducedMotion = false,
  });

  /// The milestone to display.
  final MilestoneResult milestone;

  /// Called when the toast finishes its dismiss animation.
  final VoidCallback onDismissed;

  /// If true, animations are skipped (instant show/hide).
  final bool reducedMotion;

  @override
  State<MilestoneToast> createState() => _MilestoneToastState();
}

class _MilestoneToastState extends State<MilestoneToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  static const _animationDuration = Duration(milliseconds: 300);
  static const _displayDuration = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();

    final duration = widget.reducedMotion ? Duration.zero : _animationDuration;

    _controller = AnimationController(
      vsync: this,
      duration: duration,
      reverseDuration: duration,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward().then((_) {
      _autoDismissTimer = Timer(_displayDuration, _dismiss);
    });
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _milestoneConfig(widget.milestone.milestone);
    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
              vertical: SpacingTokens.sm,
            ),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg,
                  vertical: SpacingTokens.md,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SpacingTokens.radiusLg),
                  border: Border.all(
                    color: config.color.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: config.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        config.icon,
                        color: config.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            config.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: config.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.milestone.playerName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
}

/// Visual configuration for each milestone type.
class _MilestoneConfig {
  final IconData icon;
  final Color color;
  final String title;

  const _MilestoneConfig({
    required this.icon,
    required this.color,
    required this.title,
  });
}

_MilestoneConfig _milestoneConfig(Milestone milestone) {
  return switch (milestone) {
    Milestone.firstCorrectGuess => const _MilestoneConfig(
        icon: Icons.star_rounded,
        color: Color(0xFFD4A742), // gold
        title: 'First Correct Guess!',
      ),
    Milestone.onFire => const _MilestoneConfig(
        icon: Icons.local_fire_department_rounded,
        color: Color(0xFFFB923C), // orange
        title: 'On Fire!',
      ),
    Milestone.masterStoryteller => const _MilestoneConfig(
        icon: Icons.auto_stories_rounded,
        color: Color(0xFF7B68EE), // violet
        title: 'Master Storyteller!',
      ),
    Milestone.trickster => const _MilestoneConfig(
        icon: Icons.psychology_rounded,
        color: Color(0xFF2EC4B6), // teal
        title: 'Trickster!',
      ),
  };
}

/// Manages a queue of milestone toasts, showing one at a time as overlays.
///
/// Call [showMilestones] to enqueue one or more milestones. They will
/// display sequentially, each auto-dismissing before the next appears.
class MilestoneToastQueue {
  MilestoneToastQueue({
    required this.overlayState,
    this.reducedMotion = false,
  });

  final OverlayState overlayState;
  final bool reducedMotion;

  final Queue<MilestoneResult> _queue = Queue();
  OverlayEntry? _currentEntry;
  bool _isShowing = false;

  /// Enqueues milestones and starts showing them if not already active.
  void showMilestones(List<MilestoneResult> milestones) {
    _queue.addAll(milestones);
    if (!_isShowing) {
      _showNext();
    }
  }

  void _showNext() {
    if (_queue.isEmpty) {
      _isShowing = false;
      return;
    }

    _isShowing = true;
    final milestone = _queue.removeFirst();

    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: MilestoneToast(
          milestone: milestone,
          reducedMotion: reducedMotion,
          onDismissed: () {
            _currentEntry?.remove();
            _currentEntry = null;
            _showNext();
          },
        ),
      ),
    );

    overlayState.insert(_currentEntry!);
  }

  /// Disposes any active toast and clears the queue.
  void dispose() {
    _queue.clear();
    _currentEntry?.remove();
    _currentEntry = null;
    _isShowing = false;
  }
}
