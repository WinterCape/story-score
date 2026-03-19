import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/features/home/providers/home_providers.dart';
import 'package:story_score/features/home/widgets/empty_state.dart';
import 'package:story_score/features/home/widgets/session_card.dart';
import 'package:story_score/features/premium/providers/premium_providers.dart';
import 'package:story_score/features/presets/providers/preset_providers.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';
import 'package:story_score/shared/widgets/custom_icon.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeSessionsProvider);
    final completedAsync = ref.watch(completedSessionsProvider);
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
          child: Stack(
            children: [
              // Sparkle decorations
              const _SparkleDecorations(),
              // Main content
              Column(
                children: [
                  // Top bar: title left, icon buttons right
                  _HomeTopBar(l10n: l10n),

                  // Body
                  Expanded(
                    child: _buildBody(
                      context,
                      ref,
                      activeAsync,
                      completedAsync,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<GameSession>> activeAsync,
    AsyncValue<List<GameSession>> completedAsync,
  ) {
    final l10n = context.l10n;

    final isLoading =
        activeAsync.isLoading && !activeAsync.hasValue ||
        completedAsync.isLoading && !completedAsync.hasValue;

    if (isLoading) {
      return _buildLoadingSkeleton(context);
    }

    final activeError = activeAsync.error;
    final completedError = completedAsync.error;
    if (activeError != null && completedError != null) {
      return _buildError(context, activeError);
    }

    final activeSessions = switch (activeAsync) {
      AsyncData(:final value) => value,
      _ => <GameSession>[],
    };
    final completedSessions = switch (completedAsync) {
      AsyncData(:final value) => value,
      _ => <GameSession>[],
    };

    // Empty state when no sessions exist
    if (activeSessions.isEmpty && completedSessions.isEmpty) {
      return EmptyState(
        icon: Icons.auto_stories_outlined,
        title: l10n.noGamesYet,
        subtitle: l10n.startYourFirstGameDescription,
        actionLabel: l10n.startYourFirstGame,
        onAction: () => context.push('/game/new'),
      );
    }

    // Has games — show Quick Start, Active, Completed sections
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(
            left: SpacingTokens.md,
            right: SpacingTokens.md,
            top: SpacingTokens.sm,
            bottom: 88, // space for New Game button
          ),
          children: [
            // Quick Start banner (premium-gated)
            if (ref.watch(isSupporterProvider))
              const _QuickStartBanner(),

            // Active Games section
            if (activeSessions.isNotEmpty) ...[
              _SectionHeader(
                title: l10n.activeGames,
                action: 'See all',
                onAction: () {},
              ),
              const SizedBox(height: SpacingTokens.sm),
              ...activeSessions.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                  child: SessionCard(
                    session: session,
                    onTap: () =>
                        context.go('/game/${session.id}/scoreboard'),
                    onDismissed: () => _deleteSession(ref, session.id),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
            ],

            // Completed section
            if (completedSessions.isNotEmpty) ...[
              _SectionHeader(
                title: l10n.completedGames,
                action: 'Archive',
                onAction: () {},
              ),
              const SizedBox(height: SpacingTokens.sm),
              ...completedSessions.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                  child: SessionCard(
                    session: session,
                    onTap: () => context.go('/archive/${session.id}'),
                    onDismissed: () => _deleteSession(ref, session.id),
                  ),
                ),
              ),
            ],
          ],
        ),

        // Small gradient "New Game" button bottom-right
        Positioned(
          bottom: SpacingTokens.md,
          right: SpacingTokens.md,
          child: _SmallGradientButton(
            label: l10n.newGame,
            onPressed: () => context.push('/game/new'),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteSession(WidgetRef ref, String sessionId) async {
    final delete = ref.read(deleteSessionProvider);
    await delete(sessionId);
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ColorTokens.darkCard, ColorTokens.darkCardVariant],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: context.colorScheme.error,
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(l10n.somethingWentWrong, style: context.textTheme.titleMedium),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              error.toString(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

/// Gold title left-aligned, two icon buttons (stats, settings) top-right
/// in 40x40 rounded squares.
class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({required this.l10n});

  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + subtitle, left-aligned
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: ColorTokens.goldAccent,
                    fontFamily: 'Serif',
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Score your table like an enchanted ledger',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorTokens.mutedText.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Icon buttons in rounded squares
          const SizedBox(width: SpacingTokens.sm),
          _IconSquareButton(
            iconName: 'stats',
            onTap: () => context.push('/stats'),
          ),
          const SizedBox(width: SpacingTokens.sm),
          _IconSquareButton(
            iconName: 'settings',
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

/// 40x40 rounded square icon button with subtle surface color.
class _IconSquareButton extends StatelessWidget {
  const _IconSquareButton({required this.iconName, required this.onTap});

  final String iconName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ColorTokens.goldAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CustomIcon(
            iconName,
            size: 20,
            color: ColorTokens.goldAccent,
          ),
        ),
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────

/// Gold uppercase section header with optional right-aligned action text.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: ColorTokens.goldAccent,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            fontSize: 10,
          ),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: TextStyle(
                color: ColorTokens.mutedText.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Quick Start banner ───────────────────────────────────────────────────────

/// Gradient purple card with "QUICK START" header, description, and icon.
class _QuickStartBanner extends ConsumerWidget {
  const _QuickStartBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(presetsProvider);

    return presetsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (presets) {
        if (presets.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.md),
          child: GestureDetector(
            onTap: () => _showPresetPicker(context, ref, presets),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorTokens.darkCardVariant,
                    ColorTokens.darkCard,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ColorTokens.goldAccent.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QUICK START',
                          style: TextStyle(
                            color: ColorTokens.goldAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Begin a new tale with your favorite group',
                          style: TextStyle(
                            color: ColorTokens.parchment,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Resume last setup in seconds',
                          style: TextStyle(
                            color: ColorTokens.mutedText.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  const CustomIcon('new_game', size: 28, color: ColorTokens.parchment),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPresetPicker(
    BuildContext context,
    WidgetRef ref,
    List<PlayerPreset> presets,
  ) async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<PlayerPreset>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(l10n.quickStart, style: context.textTheme.titleLarge),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              l10n.quickStartDescription,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: presets.length,
                itemBuilder: (context, index) {
                  final preset = presets[index];
                  return ListTile(
                    leading: const Icon(Icons.group_outlined),
                    title: Text(preset.name),
                    onTap: () => Navigator.of(sheetContext).pop(preset),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected == null || !context.mounted) return;

    try {
      final sessionId = await quickStart(
        presetDao: ref.read(presetDaoProvider),
        sessionDao: ref.read(sessionDaoProvider),
        presetId: selected.id,
      );
      if (context.mounted) {
        context.go('/game/$sessionId/scoreboard');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.quickStartFailed('$e'))));
      }
    }
  }
}

// ── Small gradient button ────────────────────────────────────────────────────

/// Small gradient "New Game" button for bottom-right positioning.
class _SmallGradientButton extends StatelessWidget {
  const _SmallGradientButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [ColorTokens.burgundy, ColorTokens.goldAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorTokens.burgundy.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomIcon('new_game', size: 18, color: Colors.white),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  label,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sparkle decorations ──────────────────────────────────────────────────────

class _SparkleDecorations extends StatelessWidget {
  const _SparkleDecorations();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned(
            top: 40,
            right: 30,
            child: _Sparkle(
              char: '\u2605',
              color: ColorTokens.goldAccent,
              opacity: 0.12,
              size: 18,
            ),
          ),
          Positioned(
            top: 120,
            left: 20,
            child: _Sparkle(
              char: '\u2726',
              color: ColorTokens.dustyRose,
              opacity: 0.15,
              size: 14,
            ),
          ),
          Positioned(
            top: 280,
            right: 50,
            child: _Sparkle(
              char: '\u2726',
              color: ColorTokens.goldAccent,
              opacity: 0.10,
              size: 12,
            ),
          ),
          Positioned(
            bottom: 200,
            left: 40,
            child: _Sparkle(
              char: '\u2605',
              color: ColorTokens.goldAccent,
              opacity: 0.12,
              size: 16,
            ),
          ),
          Positioned(
            bottom: 80,
            right: 60,
            child: _Sparkle(
              char: '\u2726',
              color: ColorTokens.dustyRose,
              opacity: 0.10,
              size: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({
    required this.char,
    required this.color,
    required this.opacity,
    required this.size,
  });

  final String char;
  final Color color;
  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Text(
        char,
        style: TextStyle(fontSize: size, color: color),
      ),
    );
  }
}
