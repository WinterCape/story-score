/// Summary of a completed game for the endgame screen.
class GameSummary {
  final String sessionId;
  final String title;
  final int roundCount;
  final List<PlayerStanding> standings;
  final DateTime startedAt;
  final DateTime endedAt;

  const GameSummary({
    required this.sessionId,
    required this.title,
    required this.roundCount,
    required this.standings,
    required this.startedAt,
    required this.endedAt,
  });

  /// The winner(s) — may be multiple in case of a tie.
  List<PlayerStanding> get winners {
    if (standings.isEmpty) return [];
    final topScore = standings.first.score;
    return standings.where((s) => s.score == topScore).toList();
  }

  bool get hasTie => winners.length > 1;
}

/// A player's final standing in a game.
class PlayerStanding implements Comparable<PlayerStanding> {
  final String playerId;
  final String playerName;
  final String colorKey;
  final int score;
  final int rank;
  final int roundsAsStoryteller;
  final int correctGuesses;
  final int fooledOthersCount;

  const PlayerStanding({
    required this.playerId,
    required this.playerName,
    required this.colorKey,
    required this.score,
    required this.rank,
    this.roundsAsStoryteller = 0,
    this.correctGuesses = 0,
    this.fooledOthersCount = 0,
  });

  @override
  int compareTo(PlayerStanding other) => other.score.compareTo(score);
}
