import 'package:story_score/core/utils/id_generator.dart';
import 'package:story_score/data/database/daos/round_dao.dart';
import 'package:story_score/data/database/daos/session_dao.dart';
import 'package:story_score/domain/scoring/scoring_engine.dart';

/// Orchestrates round submission and editing.
/// Connects the pure ScoringEngine to the database layer.
class RoundProcessor {
  final ScoringEngine _engine;
  final RoundDao _roundDao;
  final SessionDao _sessionDao;

  const RoundProcessor({
    required ScoringEngine engine,
    required RoundDao roundDao,
    required SessionDao sessionDao,
  })  : _engine = engine,
        _roundDao = roundDao,
        _sessionDao = sessionDao;

  /// Submit a new round: compute scores, persist everything atomically.
  Future<RoundResult> submitRound({
    required String sessionId,
    required String storytellerPlayerId,
    required List<String> allPlayerIds,
    required Map<String, String> votes,
    String note = '',
  }) async {
    final input = RoundInput(
      storytellerPlayerId: storytellerPlayerId,
      allPlayerIds: allPlayerIds,
      votes: votes,
    );

    // Validate input
    final errors = _engine.validateInput(input);
    if (errors.isNotEmpty) {
      throw ScoringValidationException(errors);
    }

    final result = _engine.computeRound(input);
    final roundId = IdGenerator.newId();

    await _roundDao.insertRoundWithScores(
      roundId: roundId,
      sessionId: sessionId,
      storytellerPlayerId: storytellerPlayerId,
      note: note,
      votesMap: votes,
      scoreEntries: result.scoreEntries,
    );

    // Recompute cumulative player scores
    await _sessionDao.recomputePlayerScores(sessionId);

    // Advance storyteller to next seat
    await _sessionDao.advanceStoryteller(sessionId);

    return result;
  }

  /// Edit an existing round: recompute scores and update all downstream totals.
  Future<RoundResult> editRound({
    required String roundId,
    required String sessionId,
    required String storytellerPlayerId,
    required List<String> allPlayerIds,
    required Map<String, String> votes,
    String? note,
  }) async {
    final input = RoundInput(
      storytellerPlayerId: storytellerPlayerId,
      allPlayerIds: allPlayerIds,
      votes: votes,
    );

    final errors = _engine.validateInput(input);
    if (errors.isNotEmpty) {
      throw ScoringValidationException(errors);
    }

    final result = _engine.computeRound(input);

    await _roundDao.updateRoundVotesAndScores(
      roundId: roundId,
      storytellerPlayerId: storytellerPlayerId,
      note: note,
      votesMap: votes,
      scoreEntries: result.scoreEntries,
    );

    // Recompute cumulative player scores across ALL rounds
    await _sessionDao.recomputePlayerScores(sessionId);

    return result;
  }

  /// Delete a round and recompute all scores.
  Future<void> deleteRound({
    required String roundId,
    required String sessionId,
  }) async {
    await _roundDao.deleteRound(roundId);
    await _sessionDao.recomputePlayerScores(sessionId);
  }

  /// Undo the last round in a session.
  Future<void> undoLastRound({required String sessionId}) async {
    await _roundDao.deleteLastRound(sessionId);
    await _sessionDao.recomputePlayerScores(sessionId);
  }
}

/// Thrown when round input fails validation.
class ScoringValidationException implements Exception {
  final List<String> errors;
  const ScoringValidationException(this.errors);

  @override
  String toString() => 'ScoringValidationException: ${errors.join(', ')}';
}
