import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/game_sessions.dart';
import '../tables/players.dart';
import '../tables/rounds.dart';
import '../tables/score_changes.dart';
import '../tables/votes.dart';

part 'session_dao.g.dart';

@DriftAccessor(tables: [GameSessions, Players, Rounds, Votes, ScoreChanges])
class SessionDao extends DatabaseAccessor<AppDatabase> with _$SessionDaoMixin {
  SessionDao(super.db);

  /// Watches all sessions with [GameStatus.active] or [GameStatus.paused].
  Stream<List<GameSession>> watchActiveSessions() {
    return (select(gameSessions)
          ..where(
            (s) =>
                s.status.equalsValue(GameStatus.active) |
                s.status.equalsValue(GameStatus.paused),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.updatedAt)]))
        .watch();
  }

  /// Watches all completed sessions ordered by most recently updated.
  Stream<List<GameSession>> watchCompletedSessions() {
    return (select(gameSessions)
          ..where((s) => s.status.equalsValue(GameStatus.completed))
          ..orderBy([(s) => OrderingTerm.desc(s.updatedAt)]))
        .watch();
  }

  /// Watches a single session by [id].
  Stream<GameSession?> watchSession(String id) {
    return (select(
      gameSessions,
    )..where((s) => s.id.equals(id))).watchSingleOrNull();
  }

  /// Watches all players for [sessionId], ordered by seat order.
  Stream<List<Player>> watchPlayersForSession(String sessionId) {
    return (select(players)
          ..where((p) => p.sessionId.equals(sessionId))
          ..orderBy([(p) => OrderingTerm.asc(p.seatOrder)]))
        .watch();
  }

  /// Creates a new session together with its players in a single transaction.
  Future<void> createSession(
    GameSessionsCompanion session,
    List<PlayersCompanion> sessionPlayers,
  ) {
    return transaction(() async {
      await into(gameSessions).insert(session);
      for (final player in sessionPlayers) {
        await into(players).insert(player);
      }
    });
  }

  /// Updates fields on an existing session.
  Future<void> updateSession(String id, GameSessionsCompanion companion) async {
    await (update(
      gameSessions,
    )..where((s) => s.id.equals(id))).write(companion);
  }

  /// Overwrites a player's current score.
  Future<void> updatePlayerScore(String playerId, int newScore) async {
    await (update(players)..where((p) => p.id.equals(playerId))).write(
      PlayersCompanion(currentScore: Value(newScore)),
    );
  }

  /// Recomputes every player's score from the [ScoreChanges] table
  /// for the given [sessionId].
  Future<void> recomputePlayerScores(String sessionId) {
    return transaction(() async {
      final sessionPlayers = await (select(
        players,
      )..where((p) => p.sessionId.equals(sessionId))).get();

      for (final player in sessionPlayers) {
        final sumQuery = selectOnly(scoreChanges)
          ..addColumns([scoreChanges.delta.sum()])
          ..where(scoreChanges.playerId.equals(player.id));

        final result = await sumQuery.getSingle();
        final total = result.read(scoreChanges.delta.sum()) ?? 0;

        await (update(players)..where((p) => p.id.equals(player.id))).write(
          PlayersCompanion(currentScore: Value(total)),
        );
      }
    });
  }

  /// Deletes a session and cascades to players, rounds, votes, and
  /// score changes.
  Future<void> deleteSession(String id) {
    return transaction(() async {
      // Find all round IDs for this session.
      final sessionRounds = await (select(
        rounds,
      )..where((r) => r.sessionId.equals(id))).get();
      final roundIds = sessionRounds.map((r) => r.id).toList();

      if (roundIds.isNotEmpty) {
        // Delete votes and score changes for those rounds.
        await (delete(votes)..where((v) => v.roundId.isIn(roundIds))).go();
        await (delete(
          scoreChanges,
        )..where((sc) => sc.roundId.isIn(roundIds))).go();
      }

      // Delete rounds.
      await (delete(rounds)..where((r) => r.sessionId.equals(id))).go();

      // Delete players.
      await (delete(players)..where((p) => p.sessionId.equals(id))).go();

      // Delete the session itself.
      await (delete(gameSessions)..where((s) => s.id.equals(id))).go();
    });
  }

  /// Advances the storyteller to the next seat for [sessionId].
  Future<void> advanceStoryteller(String sessionId) {
    return transaction(() async {
      final session = await (select(
        gameSessions,
      )..where((s) => s.id.equals(sessionId))).getSingle();

      final playerCount =
          await (select(players)..where((p) => p.sessionId.equals(sessionId)))
              .get()
              .then((list) => list.length);

      if (playerCount == 0) return;

      final nextSeat = (session.currentStorytellerSeat + 1) % playerCount;

      await (update(gameSessions)..where((s) => s.id.equals(sessionId))).write(
        GameSessionsCompanion(
          currentStorytellerSeat: Value(nextSeat),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }
}
