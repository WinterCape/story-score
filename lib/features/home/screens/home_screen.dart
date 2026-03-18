import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/app/theme/spacing_tokens.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';
import 'package:story_score/data/export/session_importer.dart';
import 'package:story_score/features/home/providers/home_providers.dart';
import 'package:story_score/features/home/widgets/empty_state.dart';
import 'package:story_score/features/home/widgets/session_card.dart';
import 'package:story_score/shared/extensions/context_extensions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeSessionsProvider);
    final completedAsync = ref.watch(completedSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'StoryScore',
          style: context.textTheme.titleLarge?.copyWith(
            color: context.storyTheme.goldAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Import Game',
            onPressed: () => _importGame(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _buildBody(context, ref, activeAsync, completedAsync),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/game/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Game'),
        backgroundColor: context.storyTheme.goldAccent,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<GameSession>> activeAsync,
    AsyncValue<List<GameSession>> completedAsync,
  ) {
    // Show loading skeleton while either list is loading for the first time
    final isLoading = activeAsync.isLoading && !activeAsync.hasValue ||
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
        title: 'No games yet',
        subtitle: 'Start your first game and begin tracking scores '
            'for your storytelling card game.',
        actionLabel: 'Start your first game',
        onAction: () => context.push('/game/new'),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        top: SpacingTokens.sm,
        bottom: 88, // space for FAB
      ),
      children: [
        // Active Games section
        if (activeSessions.isNotEmpty) ...[
          _SectionHeader(title: 'Active Games'),
          const SizedBox(height: SpacingTokens.sm),
          ...activeSessions.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
              child: SessionCard(
                session: session,
                onTap: () => context.go(
                  '/game/${session.id}/scoreboard',
                ),
                onDismissed: () => _deleteSession(ref, session.id),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],

        // Completed Games section
        if (completedSessions.isNotEmpty) ...[
          _SectionHeader(title: 'Completed Games'),
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
    );
  }

  Future<void> _importGame(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

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
            content: Text('Import failed: ${importResult.errors.join(', ')}'),
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
              'Game imported with warnings: ${importResult.warnings.join(', ')}',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Game imported successfully!')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  Future<void> _deleteSession(WidgetRef ref, String sessionId) async {
    final delete = ref.read(deleteSessionProvider);
    await delete(sessionId);
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final colors = context.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.md),
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
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
            Text(
              'Something went wrong',
              style: context.textTheme.titleMedium,
            ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: SpacingTokens.xs),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
