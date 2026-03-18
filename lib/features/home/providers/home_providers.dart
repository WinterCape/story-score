import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';

/// Watches all sessions with [GameStatus.active] or [GameStatus.paused],
/// ordered by most recently updated.
final activeSessionsProvider = StreamProvider<List<GameSession>>((ref) {
  return ref.watch(sessionDaoProvider).watchActiveSessions();
});

/// Watches all completed sessions ordered by most recently updated.
final completedSessionsProvider = StreamProvider<List<GameSession>>((ref) {
  return ref.watch(sessionDaoProvider).watchCompletedSessions();
});

/// Watches the player count for a given session.
final playerCountProvider = StreamProvider.family<int, String>((
  ref,
  sessionId,
) {
  return ref
      .watch(sessionDaoProvider)
      .watchPlayersForSession(sessionId)
      .map((players) => players.length);
});

/// Watches the players for a given session (for avatar display).
final sessionPlayersProvider = StreamProvider.family<List<Player>, String>((
  ref,
  sessionId,
) {
  return ref.watch(sessionDaoProvider).watchPlayersForSession(sessionId);
});

/// Deletes a session by its ID (cascades to players, rounds, etc.).
final deleteSessionProvider = Provider<Future<void> Function(String sessionId)>(
  (ref) {
    final sessionDao = ref.watch(sessionDaoProvider);
    return (String sessionId) => sessionDao.deleteSession(sessionId);
  },
);
