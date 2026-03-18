/// A round combined with its votes and score changes for display.
class RoundWithDetails {
  final String id;
  final int roundNumber;
  final String storytellerPlayerId;
  final String storytellerName;
  final String note;
  final DateTime createdAt;
  final DateTime? editedAt;
  final List<VoteDetail> votes;
  final List<ScoreChangeDetail> scoreChanges;

  const RoundWithDetails({
    required this.id,
    required this.roundNumber,
    required this.storytellerPlayerId,
    required this.storytellerName,
    required this.note,
    required this.createdAt,
    this.editedAt,
    required this.votes,
    required this.scoreChanges,
  });

  /// Whether all/none guessed correctly (perfect fail case).
  bool get wasPerfectFail {
    final votersWhoGuessedStoryteller = votes
        .where((v) => v.votedForPlayerId == storytellerPlayerId)
        .length;
    final totalVoters = votes.length;
    return votersWhoGuessedStoryteller == 0 ||
        votersWhoGuessedStoryteller == totalVoters;
  }

  /// Total score delta for the round.
  int get totalPoints => scoreChanges.fold(0, (sum, sc) => sum + sc.delta);
}

class VoteDetail {
  final String voterPlayerId;
  final String voterName;
  final String votedForPlayerId;
  final String votedForName;
  final bool votedForStoryteller;

  const VoteDetail({
    required this.voterPlayerId,
    required this.voterName,
    required this.votedForPlayerId,
    required this.votedForName,
    required this.votedForStoryteller,
  });
}

class ScoreChangeDetail {
  final String playerId;
  final String playerName;
  final int delta;
  final String reasonCode;
  final String reasonLabel;

  const ScoreChangeDetail({
    required this.playerId,
    required this.playerName,
    required this.delta,
    required this.reasonCode,
    required this.reasonLabel,
  });
}
