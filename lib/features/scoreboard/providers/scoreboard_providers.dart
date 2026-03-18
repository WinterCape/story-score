import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/data/database/app_database.dart';

/// Watches a single [GameSession] by its ID.
final sessionProvider = StreamProvider.family<GameSession?, String>((
  ref,
  sessionId,
) {
  final dao = ref.watch(sessionDaoProvider);
  return dao.watchSession(sessionId);
});

/// Watches all players for a session, ordered by seat order from the DB.
/// Consumers can re-sort client-side (e.g. by score) as needed.
final playersProvider = StreamProvider.family<List<Player>, String>((
  ref,
  sessionId,
) {
  final dao = ref.watch(sessionDaoProvider);
  return dao.watchPlayersForSession(sessionId);
});

/// Players sorted by score descending (ties broken by seat order).
final playersByScoreProvider =
    Provider.family<AsyncValue<List<Player>>, String>((ref, sessionId) {
      return ref.watch(playersProvider(sessionId)).whenData((players) {
        final sorted = [...players]
          ..sort((a, b) {
            final cmp = b.currentScore.compareTo(a.currentScore);
            if (cmp != 0) return cmp;
            return a.seatOrder.compareTo(b.seatOrder);
          });
        return sorted;
      });
    });

/// Derives the current storyteller player from the session's
/// `currentStorytellerSeat` and the player list.
final currentStorytellerProvider = Provider.family<AsyncValue<Player?>, String>(
  (ref, sessionId) {
    final sessionAsync = ref.watch(sessionProvider(sessionId));
    final playersAsync = ref.watch(playersProvider(sessionId));

    return sessionAsync.when(
      loading: () => const AsyncValue.loading(),
      error: (e, st) => AsyncValue.error(e, st),
      data: (session) {
        if (session == null) return const AsyncValue.data(null);
        return playersAsync.whenData((players) {
          final seat = session.currentStorytellerSeat;
          try {
            return players.firstWhere((p) => p.seatOrder == seat);
          } catch (_) {
            return null;
          }
        });
      },
    );
  },
);

/// Whether to sort the scoreboard by score (true) or by seat order (false).
final sortByScoreProvider = NotifierProvider<_SortNotifier, bool>(
  _SortNotifier.new,
);

class _SortNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}
