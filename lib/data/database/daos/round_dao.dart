import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/players.dart';
import '../tables/rounds.dart';
import '../tables/score_changes.dart';
import '../tables/votes.dart';

part 'round_dao.g.dart';

/// A combined view of a round with its votes and score changes.
class RoundWithDetails {
  RoundWithDetails({
    required this.round,
    required this.votes,
    required this.scoreChanges,
  });

  final Round round;
  final List<Vote> votes;
  final List<ScoreChange> scoreChanges;
}

@DriftAccessor(tables: [Rounds, Votes, ScoreChanges, Players])
class RoundDao extends DatabaseAccessor<AppDatabase> with _$RoundDaoMixin {
  RoundDao(super.db);

  /// Watches all rounds for [sessionId], ordered by round number.
  Stream<List<Round>> watchRoundsForSession(String sessionId) {
    return (select(rounds)
          ..where((r) => r.sessionId.equals(sessionId))
          ..orderBy([(r) => OrderingTerm.asc(r.roundNumber)]))
        .watch();
  }

  /// Watches a single round together with its votes and score changes.
  Stream<RoundWithDetails?> watchRoundWithDetails(String roundId) {
    final roundStream = (select(
      rounds,
    )..where((r) => r.id.equals(roundId))).watchSingleOrNull();

    final votesStream = (select(
      votes,
    )..where((v) => v.roundId.equals(roundId))).watch();

    final changesStream = (select(
      scoreChanges,
    )..where((sc) => sc.roundId.equals(roundId))).watch();

    return roundStream.asyncExpand((round) {
      if (round == null) return Stream.value(null);

      // Combine votes and score changes streams.
      return votesStream.asyncExpand((voteList) {
        return changesStream.map((changeList) {
          return RoundWithDetails(
            round: round,
            votes: voteList,
            scoreChanges: changeList,
          );
        });
      });
    });
  }

  /// Inserts a round along with its votes and score changes in a single
  /// transaction.
  Future<void> insertRound(
    RoundsCompanion round,
    List<VotesCompanion> roundVotes,
    List<ScoreChangesCompanion> changes,
  ) {
    return transaction(() async {
      await into(rounds).insert(round);
      for (final vote in roundVotes) {
        await into(votes).insert(vote);
      }
      for (final change in changes) {
        await into(scoreChanges).insert(change);
      }
    });
  }

  /// Replaces the votes and score changes for a given round.
  ///
  /// Deletes the existing votes and score changes, then inserts the new ones.
  Future<void> updateRoundVotes(
    String roundId,
    List<VotesCompanion> newVotes,
    List<ScoreChangesCompanion> newChanges,
  ) {
    return transaction(() async {
      // Delete old data.
      await (delete(votes)..where((v) => v.roundId.equals(roundId))).go();
      await (delete(
        scoreChanges,
      )..where((sc) => sc.roundId.equals(roundId))).go();

      // Insert new data.
      for (final vote in newVotes) {
        await into(votes).insert(vote);
      }
      for (final change in newChanges) {
        await into(scoreChanges).insert(change);
      }

      // Mark the round as edited.
      await (update(rounds)..where((r) => r.id.equals(roundId))).write(
        RoundsCompanion(editedAt: Value(DateTime.now())),
      );
    });
  }

  /// Deletes a round and cascades to its votes and score changes.
  Future<void> deleteRound(String roundId) {
    return transaction(() async {
      await (delete(votes)..where((v) => v.roundId.equals(roundId))).go();
      await (delete(
        scoreChanges,
      )..where((sc) => sc.roundId.equals(roundId))).go();
      await (delete(rounds)..where((r) => r.id.equals(roundId))).go();
    });
  }

  /// Deletes all score changes for a given round.
  Future<void> deleteScoreChangesForRound(String roundId) async {
    await (delete(
      scoreChanges,
    )..where((sc) => sc.roundId.equals(roundId))).go();
  }

  /// Deletes all votes for a given round.
  Future<void> deleteVotesForRound(String roundId) async {
    await (delete(votes)..where((v) => v.roundId.equals(roundId))).go();
  }

  /// Inserts a round with its votes and score changes.
  /// Called by [RoundProcessor.submitRound].
  Future<void> insertRoundWithScores({
    required String roundId,
    required String sessionId,
    required String storytellerPlayerId,
    required String note,
    required Map<String, String> votesMap,
    required List<dynamic> scoreEntries,
  }) {
    return transaction(() async {
      // Get current round count for this session
      final existingRounds = await (select(
        rounds,
      )..where((r) => r.sessionId.equals(sessionId))).get();
      final roundNumber = existingRounds.length + 1;

      // Insert round
      await into(rounds).insert(
        RoundsCompanion.insert(
          id: roundId,
          sessionId: sessionId,
          roundNumber: roundNumber,
          storytellerPlayerId: storytellerPlayerId,
          note: Value(note),
        ),
      );

      // Insert votes
      for (final entry in votesMap.entries) {
        await into(votes).insert(
          VotesCompanion.insert(
            id: '${roundId}_${entry.key}',
            roundId: roundId,
            voterPlayerId: entry.key,
            votedForPlayerId: entry.value,
          ),
        );
      }

      // Insert score changes
      var changeIdx = 0;
      for (final se in scoreEntries) {
        await into(scoreChanges).insert(
          ScoreChangesCompanion.insert(
            id: '${roundId}_sc_$changeIdx',
            roundId: roundId,
            playerId: se.playerId as String,
            delta: se.delta as int,
            reasonCode: (se.reason as Enum).name,
            reasonLabel: _reasonLabel(se.reason as Enum),
          ),
        );
        changeIdx++;
      }

      // Update session round count and timestamp
      await customStatement(
        'UPDATE game_sessions SET round_count = ?, updated_at = ? WHERE id = ?',
        [roundNumber, DateTime.now().millisecondsSinceEpoch, sessionId],
      );
    });
  }

  /// Updates votes and scores for an existing round.
  /// Called by [RoundProcessor.editRound].
  Future<void> updateRoundVotesAndScores({
    required String roundId,
    required String storytellerPlayerId,
    required String? note,
    required Map<String, String> votesMap,
    required List<dynamic> scoreEntries,
  }) {
    return transaction(() async {
      // Delete old votes and scores
      await (delete(votes)..where((v) => v.roundId.equals(roundId))).go();
      await (delete(
        scoreChanges,
      )..where((sc) => sc.roundId.equals(roundId))).go();

      // Update round metadata
      final companion = RoundsCompanion(
        storytellerPlayerId: Value(storytellerPlayerId),
        editedAt: Value(DateTime.now()),
      );
      if (note != null) {
        await (update(rounds)..where((r) => r.id.equals(roundId))).write(
          RoundsCompanion(
            storytellerPlayerId: Value(storytellerPlayerId),
            note: Value(note),
            editedAt: Value(DateTime.now()),
          ),
        );
      } else {
        await (update(
          rounds,
        )..where((r) => r.id.equals(roundId))).write(companion);
      }

      // Insert new votes
      for (final entry in votesMap.entries) {
        await into(votes).insert(
          VotesCompanion.insert(
            id: '${roundId}_${entry.key}',
            roundId: roundId,
            voterPlayerId: entry.key,
            votedForPlayerId: entry.value,
          ),
        );
      }

      // Insert new score changes
      var changeIdx = 0;
      for (final se in scoreEntries) {
        await into(scoreChanges).insert(
          ScoreChangesCompanion.insert(
            id: '${roundId}_sc_$changeIdx',
            roundId: roundId,
            playerId: se.playerId as String,
            delta: se.delta as int,
            reasonCode: (se.reason as Enum).name,
            reasonLabel: _reasonLabel(se.reason as Enum),
          ),
        );
        changeIdx++;
      }
    });
  }

  /// Deletes the last round in a session (by round number).
  Future<void> deleteLastRound(String sessionId) {
    return transaction(() async {
      final sessionRounds =
          await (select(rounds)
                ..where((r) => r.sessionId.equals(sessionId))
                ..orderBy([(r) => OrderingTerm.desc(r.roundNumber)])
                ..limit(1))
              .get();

      if (sessionRounds.isEmpty) return;

      final lastRound = sessionRounds.first;
      await deleteRound(lastRound.id);

      // Update session round count
      final remainingCount =
          await (select(rounds)..where((r) => r.sessionId.equals(sessionId)))
              .get()
              .then((list) => list.length);

      await customStatement(
        'UPDATE game_sessions SET round_count = ?, updated_at = ? WHERE id = ?',
        [remainingCount, DateTime.now().millisecondsSinceEpoch, sessionId],
      );
    });
  }

  /// Deletes all rounds (and their votes/score changes) for a session.
  Future<void> deleteAllRoundsForSession(String sessionId) {
    return transaction(() async {
      final sessionRounds = await (select(rounds)
            ..where((r) => r.sessionId.equals(sessionId)))
          .get();

      for (final round in sessionRounds) {
        await (delete(votes)..where((v) => v.roundId.equals(round.id))).go();
        await (delete(scoreChanges)
              ..where((sc) => sc.roundId.equals(round.id)))
            .go();
      }

      await (delete(rounds)..where((r) => r.sessionId.equals(sessionId))).go();
    });
  }

  static String _reasonLabel(Enum reason) => switch (reason.name) {
    'storytellerGoodClue' => 'Good clue',
    'correctGuess' => 'Correct guess',
    'fooledBonus' => 'Fooled opponent',
    'allGuessedBonus' => 'Bad clue bonus',
    _ => reason.name,
  };
}
