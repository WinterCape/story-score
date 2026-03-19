import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/daos/round_dao.dart';

/// Watches all rounds for a session, ordered by round number.
final roundHistoryProvider = StreamProvider.family<List<Round>, String>((
  ref,
  sessionId,
) {
  return ref.watch(roundDaoProvider).watchRoundsForSession(sessionId);
});

/// Watches a single round with its votes and score changes.
final roundWithDetailsProvider =
    StreamProvider.family<RoundWithDetails?, String>((ref, roundId) {
      return ref.watch(roundDaoProvider).watchRoundWithDetails(roundId);
    });

/// Provides a function to undo (delete) the last round in a session
/// and recompute all player scores.
final undoLastRoundProvider = Provider<Future<void> Function(String sessionId)>(
  (ref) {
    final processor = ref.watch(roundProcessorProvider);
    return (String sessionId) => processor.undoLastRound(sessionId: sessionId);
  },
);

/// Provides a function to delete a specific round and recompute scores.
final deleteRoundProvider =
    Provider<
      Future<void> Function({
        required String roundId,
        required String sessionId,
      })
    >((ref) {
      final processor = ref.watch(roundProcessorProvider);
      return ({required String roundId, required String sessionId}) =>
          processor.deleteRound(roundId: roundId, sessionId: sessionId);
    });

/// Provides a function to reset a match: delete all rounds, zero scores.
final resetMatchProvider = Provider<Future<void> Function(String sessionId)>(
  (ref) {
    final processor = ref.watch(roundProcessorProvider);
    return (String sessionId) => processor.resetMatch(sessionId: sessionId);
  },
);
