import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/data/database/daos/round_dao.dart';
import 'package:story_score/data/database/daos/session_dao.dart';
import 'package:story_score/domain/stats/stats_calculator.dart';
import 'package:story_score/domain/stats/stats_models.dart';

/// Service that fetches data from DAOs, converts to domain models,
/// and delegates computation to [StatsCalculator].
class StatsService {
  final SessionDao _sessionDao;
  final RoundDao _roundDao;

  const StatsService({
    required SessionDao sessionDao,
    required RoundDao roundDao,
  }) : _sessionDao = sessionDao,
       _roundDao = roundDao;

  /// Fetches all completed games and converts them to domain models.
  Future<List<CompletedGameData>> fetchAllCompletedGames() async {
    final sessions = await _sessionDao.watchCompletedSessions().first;
    final games = <CompletedGameData>[];

    for (final session in sessions) {
      final players = await _sessionDao
          .watchPlayersForSession(session.id)
          .first;
      final rounds = await _roundDao.watchRoundsForSession(session.id).first;

      if (players.isEmpty) continue;

      final maxScore = players
          .map((p) => p.currentScore)
          .fold(0, (a, b) => a > b ? a : b);

      final playerScores = players
          .map(
            (p) => PlayerScore(
              name: p.name,
              normalizedName: normalizeName(p.name),
              finalScore: p.currentScore,
              isWinner: p.currentScore == maxScore && maxScore > 0,
            ),
          )
          .toList();

      final roundDataList = <RoundData>[];
      for (final round in rounds) {
        final details = await _roundDao.watchRoundWithDetails(round.id).first;
        if (details == null) continue;

        final votes = <String, String>{};
        for (final vote in details.votes) {
          votes[vote.voterPlayerId] = vote.votedForPlayerId;
        }

        final scoreDeltas = <String, int>{};
        for (final change in details.scoreChanges) {
          scoreDeltas[change.playerId] =
              (scoreDeltas[change.playerId] ?? 0) + change.delta;
        }

        // Determine if good clue: some (but not all) voted for storyteller
        final votesForStoryteller = votes.values
            .where((v) => v == round.storytellerPlayerId)
            .length;
        final totalVoters = votes.length;
        final hasGoodClue =
            totalVoters > 0 &&
            votesForStoryteller > 0 &&
            votesForStoryteller < totalVoters;

        roundDataList.add(
          RoundData(
            roundNumber: round.roundNumber,
            storytellerId: round.storytellerPlayerId,
            votes: votes,
            scoreDeltas: scoreDeltas,
            hasGoodClue: hasGoodClue,
          ),
        );
      }

      games.add(
        CompletedGameData(
          sessionId: session.id,
          players: playerScores,
          rounds: roundDataList,
          createdAt: session.createdAt,
        ),
      );
    }

    // Sort chronologically (oldest first) for streak computation
    games.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return games;
  }

  /// Fetches data for a single session and computes session stats.
  Future<SessionStats> computeSessionStats(String sessionId) async {
    final players = await _sessionDao.watchPlayersForSession(sessionId).first;
    final rounds = await _roundDao.watchRoundsForSession(sessionId).first;

    if (players.isEmpty) {
      return const SessionStats(
        bestRound: 0,
        worstRound: 0,
        guessAccuracy: 0.0,
        totalBonusPoints: 0,
        storytellerSuccessRate: 0.0,
        mvpName: '',
        mvpScore: 0,
      );
    }

    final maxScore = players
        .map((p) => p.currentScore)
        .fold(0, (a, b) => a > b ? a : b);

    final playerScores = players
        .map(
          (p) => PlayerScore(
            name: p.name,
            normalizedName: normalizeName(p.name),
            finalScore: p.currentScore,
            isWinner: p.currentScore == maxScore && maxScore > 0,
          ),
        )
        .toList();

    final roundDataList = <RoundData>[];
    for (final round in rounds) {
      final details = await _roundDao.watchRoundWithDetails(round.id).first;
      if (details == null) continue;

      final votes = <String, String>{};
      for (final vote in details.votes) {
        votes[vote.voterPlayerId] = vote.votedForPlayerId;
      }

      final scoreDeltas = <String, int>{};
      for (final change in details.scoreChanges) {
        scoreDeltas[change.playerId] =
            (scoreDeltas[change.playerId] ?? 0) + change.delta;
      }

      final votesForStoryteller = votes.values
          .where((v) => v == round.storytellerPlayerId)
          .length;
      final totalVoters = votes.length;
      final hasGoodClue =
          totalVoters > 0 &&
          votesForStoryteller > 0 &&
          votesForStoryteller < totalVoters;

      roundDataList.add(
        RoundData(
          roundNumber: round.roundNumber,
          storytellerId: round.storytellerPlayerId,
          votes: votes,
          scoreDeltas: scoreDeltas,
          hasGoodClue: hasGoodClue,
        ),
      );
    }

    return StatsCalculator.computeSessionStats(
      players: playerScores,
      rounds: roundDataList,
    );
  }

  /// Computes score progression for charting: per-player cumulative scores
  /// per round.
  Future<Map<String, List<int>>> computeScoreProgression(
    String sessionId,
  ) async {
    final players = await _sessionDao.watchPlayersForSession(sessionId).first;
    final rounds = await _roundDao.watchRoundsForSession(sessionId).first;

    // Initialize cumulative scores
    final progression = <String, List<int>>{};
    for (final player in players) {
      progression[player.name] = [0]; // start at 0
    }

    // Build cumulative running totals
    final cumulative = <String, int>{};
    for (final player in players) {
      cumulative[player.id] = 0;
    }

    for (final round in rounds) {
      final details = await _roundDao.watchRoundWithDetails(round.id).first;
      if (details == null) continue;

      // Add deltas
      for (final change in details.scoreChanges) {
        cumulative[change.playerId] =
            (cumulative[change.playerId] ?? 0) + change.delta;
      }

      // Record cumulative score for each player
      for (final player in players) {
        progression[player.name]!.add(cumulative[player.id] ?? 0);
      }
    }

    return progression;
  }
}

/// Provides the [StatsService].
final statsServiceProvider = Provider<StatsService>((ref) {
  return StatsService(
    sessionDao: ref.watch(sessionDaoProvider),
    roundDao: ref.watch(roundDaoProvider),
  );
});

/// Computes session stats for a given session ID.
final sessionStatsProvider = FutureProvider.family<SessionStats, String>((
  ref,
  sessionId,
) {
  return ref.watch(statsServiceProvider).computeSessionStats(sessionId);
});

/// Computes all-time stats for a given normalized player name.
final allTimeStatsProvider = FutureProvider.family<PlayerAllTimeStats, String>((
  ref,
  normalizedName,
) async {
  final service = ref.watch(statsServiceProvider);
  final allGames = await service.fetchAllCompletedGames();
  return StatsCalculator.computePlayerAllTimeStats(
    normalizedName: normalizedName,
    allGames: allGames,
  );
});

/// Computes the all-time leaderboard.
final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = ref.watch(statsServiceProvider);
  final allGames = await service.fetchAllCompletedGames();
  return StatsCalculator.computeLeaderboard(allGames: allGames);
});

/// Computes score progression for charting in a given session.
final scoreProgressionProvider =
    FutureProvider.family<Map<String, List<int>>, String>((ref, sessionId) {
      return ref.watch(statsServiceProvider).computeScoreProgression(sessionId);
    });
