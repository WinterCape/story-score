import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/color_tokens.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/export/session_importer.dart';
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
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              l10n.appTitle,
              style: context.textTheme.titleLarge?.copyWith(
                color: ColorTokens.goldAccent,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Your storytelling companion',
              style: context.textTheme.labelSmall?.copyWith(
                color: ColorTokens.dustyRose,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const CustomIcon('stats', size: 20),
            tooltip: l10n.stats,
            onPressed: () => context.push('/stats'),
          ),
          IconButton(
            icon: const CustomIcon('import', size: 20),
            tooltip: l10n.importGame,
            onPressed: () => _importGame(context, ref),
          ),
          IconButton(
            icon: const CustomIcon('settings', size: 20),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
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
        child: Stack(
          children: [
            // Sparkle decorations
            const _SparkleDecorations(),
            // Main content
            _buildBody(context, ref, activeAsync, completedAsync),
          ],
        ),
      ),
      floatingActionButton: _GradientFAB(
        onPressed: () => context.push('/game/new'),
        label: l10n.newGame,
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

    // Show loading skeleton while either list is loading for the first time
    final isLoading =
        activeAsync.isLoading && !activeAsync.hasValue ||
        completedAsync.isLoading && !completedAsync.hasValue;

    if (isLoading) {
      return _buildLoadingSkeleton(context);
    }

    // Show error if both failed
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

    // Empty state when no sessions exist at all
    if (activeSessions.isEmpty && completedSessions.isEmpty) {
      return EmptyState(
        icon: Icons.auto_stories_outlined,
        title: l10n.noGamesYet,
        subtitle: l10n.startYourFirstGameDescription,
        actionLabel: l10n.startYourFirstGame,
        onAction: () => context.push('/game/new'),
      );
    }

    final isTablet = context.isTablet;

    return ListView(
      padding: const EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        top: SpacingTokens.sm,
        bottom: 88, // space for FAB
      ),
      children: [
        // Quick Start chip (premium-gated, shown when presets exist)
        if (ref.watch(isSupporterProvider)) const _QuickStartSection(),

        // Active Games section
        if (activeSessions.isNotEmpty) ...[
          _SectionHeader(title: l10n.activeGames),
          const SizedBox(height: SpacingTokens.sm),
          if (isTablet)
            _SessionGrid(
              sessions: activeSessions,
              onTap: (session) => context.go('/game/${session.id}/scoreboard'),
              onDismissed: (session) => _deleteSession(ref, session.id),
            )
          else
            ...activeSessions.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                child: SessionCard(
                  session: session,
                  onTap: () => context.go('/game/${session.id}/scoreboard'),
                  onDismissed: () => _deleteSession(ref, session.id),
                ),
              ),
            ),
          const SizedBox(height: SpacingTokens.lg),
        ],

        // Completed Games section
        if (completedSessions.isNotEmpty) ...[
          _SectionHeader(title: l10n.completedGames),
          const SizedBox(height: SpacingTokens.sm),
          if (isTablet)
            _SessionGrid(
              sessions: completedSessions,
              onTap: (session) => context.go('/archive/${session.id}'),
              onDismissed: (session) => _deleteSession(ref, session.id),
            )
          else
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
    );
  }

  Future<void> _importGame(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      final jsonString = await File(filePath).readAsString();

      const importer = SessionImporter();
      final importResult = importer.fromJson(jsonString);

      if (!importResult.isValid) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.importFailed(importResult.errors.join(', '))),
          ),
        );
        return;
      }

      final exported = importResult.session!;

      // Parse target type
      final targetType = switch (exported.session.targetType) {
        'score' => TargetType.score,
        'rounds' => TargetType.rounds,
        _ => TargetType.freeplay,
      };

      // Parse game status
      final status = switch (exported.session.status) {
        'active' => GameStatus.active,
        'paused' => GameStatus.paused,
        _ => GameStatus.completed,
      };

      final sessionCompanion = GameSessionsCompanion.insert(
        id: exported.session.id,
        title: Value(exported.session.title),
        status: status,
        targetType: targetType,
        targetScore: Value(exported.session.targetScore),
      );

      final playerCompanions = exported.players.map((p) {
        return PlayersCompanion.insert(
          id: p.id,
          sessionId: exported.session.id,
          name: p.name,
          seatOrder: p.seatOrder,
          colorKey: p.colorKey,
          currentScore: Value(p.currentScore),
        );
      }).toList();

      final dao = ref.read(sessionDaoProvider);
      await dao.createSession(sessionCompanion, playerCompanions);

      // Show warnings if any
      if (importResult.warnings.isNotEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.importWithWarnings(importResult.warnings.join(', ')),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        messenger.showSnackBar(SnackBar(content: Text(l10n.importSuccess)));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed('$e'))));
    }
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

/// Subtle sparkle characters positioned absolutely on the background.
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
            child: _Sparkle(char: '\u2605', color: ColorTokens.goldAccent, opacity: 0.12, size: 18),
          ),
          Positioned(
            top: 120,
            left: 20,
            child: _Sparkle(char: '\u2726', color: ColorTokens.dustyRose, opacity: 0.15, size: 14),
          ),
          Positioned(
            top: 280,
            right: 50,
            child: _Sparkle(char: '\u2726', color: ColorTokens.goldAccent, opacity: 0.10, size: 12),
          ),
          Positioned(
            bottom: 200,
            left: 40,
            child: _Sparkle(char: '\u2605', color: ColorTokens.goldAccent, opacity: 0.12, size: 16),
          ),
          Positioned(
            bottom: 80,
            right: 60,
            child: _Sparkle(char: '\u2726', color: ColorTokens.dustyRose, opacity: 0.10, size: 10),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: SpacingTokens.xs),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: ColorTokens.goldAccent,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Gradient FAB with burgundy-to-gold gradient.
class _GradientFAB extends StatelessWidget {
  const _GradientFAB({required this.onPressed, required this.label});

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
              vertical: SpacingTokens.md,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomIcon('new_game', size: 20, color: Colors.white),
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

/// Quick Start section — shows an ActionChip when presets exist.
class _QuickStartSection extends ConsumerWidget {
  const _QuickStartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsAsync = ref.watch(presetsProvider);
    final l10n = context.l10n;

    return presetsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (presets) {
        if (presets.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ActionChip(
              avatar: const Icon(Icons.bolt_rounded, size: 18),
              label: Text(l10n.quickStart),
              onPressed: () => _showPresetPicker(context, ref, presets),
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

/// A 2-column grid of session cards for tablet layouts.
class _SessionGrid extends StatelessWidget {
  const _SessionGrid({
    required this.sessions,
    required this.onTap,
    required this.onDismissed,
  });

  final List<GameSession> sessions;
  final void Function(GameSession session) onTap;
  final void Function(GameSession session) onDismissed;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: SpacingTokens.sm,
        mainAxisSpacing: SpacingTokens.sm,
        childAspectRatio: 2.5,
      ),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionCard(
          session: session,
          onTap: () => onTap(session),
          onDismissed: () => onDismissed(session),
        );
      },
    );
  }
}
