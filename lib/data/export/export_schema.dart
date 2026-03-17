import 'dart:convert';

/// Version 1 export schema for StoryScore sessions.
class ExportedSession {
  final int schemaVersion;
  final String appVersion;
  final DateTime exportedAt;
  final ExportedGameSession session;
  final List<ExportedPlayer> players;
  final List<ExportedRound> rounds;

  const ExportedSession({
    this.schemaVersion = 1,
    required this.appVersion,
    required this.exportedAt,
    required this.session,
    required this.players,
    required this.rounds,
  });

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'session': session.toJson(),
    'players': players.map((p) => p.toJson()).toList(),
    'rounds': rounds.map((r) => r.toJson()).toList(),
  };

  factory ExportedSession.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'] as int? ?? 1;
    if (version != 1) {
      throw FormatException('Unsupported schema version: $version');
    }
    return ExportedSession(
      schemaVersion: version,
      appVersion: json['appVersion'] as String? ?? 'unknown',
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      session: ExportedGameSession.fromJson(
          json['session'] as Map<String, dynamic>),
      players: (json['players'] as List)
          .map((p) => ExportedPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
      rounds: (json['rounds'] as List)
          .map((r) => ExportedRound.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}

class ExportedGameSession {
  final String id;
  final String title;
  final String status;
  final String targetType;
  final int? targetScore;
  final int roundCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExportedGameSession({
    required this.id,
    required this.title,
    required this.status,
    required this.targetType,
    this.targetScore,
    required this.roundCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'status': status,
    'targetType': targetType,
    'targetScore': targetScore,
    'roundCount': roundCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ExportedGameSession.fromJson(Map<String, dynamic> json) =>
      ExportedGameSession(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        status: json['status'] as String,
        targetType: json['targetType'] as String,
        targetScore: json['targetScore'] as int?,
        roundCount: json['roundCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class ExportedPlayer {
  final String id;
  final String name;
  final int seatOrder;
  final String colorKey;
  final String avatarStyle;
  final int currentScore;

  const ExportedPlayer({
    required this.id,
    required this.name,
    required this.seatOrder,
    required this.colorKey,
    this.avatarStyle = 'initials',
    required this.currentScore,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'seatOrder': seatOrder,
    'colorKey': colorKey,
    'avatarStyle': avatarStyle,
    'currentScore': currentScore,
  };

  factory ExportedPlayer.fromJson(Map<String, dynamic> json) =>
      ExportedPlayer(
        id: json['id'] as String,
        name: json['name'] as String,
        seatOrder: json['seatOrder'] as int,
        colorKey: json['colorKey'] as String,
        avatarStyle: json['avatarStyle'] as String? ?? 'initials',
        currentScore: json['currentScore'] as int? ?? 0,
      );
}

class ExportedRound {
  final String id;
  final int roundNumber;
  final String storytellerPlayerId;
  final String note;
  final DateTime createdAt;
  final List<ExportedVote> votes;
  final List<ExportedScoreChange> scoreChanges;

  const ExportedRound({
    required this.id,
    required this.roundNumber,
    required this.storytellerPlayerId,
    this.note = '',
    required this.createdAt,
    required this.votes,
    required this.scoreChanges,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roundNumber': roundNumber,
    'storytellerPlayerId': storytellerPlayerId,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'votes': votes.map((v) => v.toJson()).toList(),
    'scoreChanges': scoreChanges.map((sc) => sc.toJson()).toList(),
  };

  factory ExportedRound.fromJson(Map<String, dynamic> json) => ExportedRound(
    id: json['id'] as String,
    roundNumber: json['roundNumber'] as int,
    storytellerPlayerId: json['storytellerPlayerId'] as String,
    note: json['note'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String),
    votes: (json['votes'] as List)
        .map((v) => ExportedVote.fromJson(v as Map<String, dynamic>))
        .toList(),
    scoreChanges: (json['scoreChanges'] as List)
        .map((sc) =>
            ExportedScoreChange.fromJson(sc as Map<String, dynamic>))
        .toList(),
  );
}

class ExportedVote {
  final String voterPlayerId;
  final String votedForPlayerId;

  const ExportedVote({
    required this.voterPlayerId,
    required this.votedForPlayerId,
  });

  Map<String, dynamic> toJson() => {
    'voterPlayerId': voterPlayerId,
    'votedForPlayerId': votedForPlayerId,
  };

  factory ExportedVote.fromJson(Map<String, dynamic> json) => ExportedVote(
    voterPlayerId: json['voterPlayerId'] as String,
    votedForPlayerId: json['votedForPlayerId'] as String,
  );
}

class ExportedScoreChange {
  final String playerId;
  final int delta;
  final String reasonCode;
  final String reasonLabel;

  const ExportedScoreChange({
    required this.playerId,
    required this.delta,
    required this.reasonCode,
    required this.reasonLabel,
  });

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'delta': delta,
    'reasonCode': reasonCode,
    'reasonLabel': reasonLabel,
  };

  factory ExportedScoreChange.fromJson(Map<String, dynamic> json) =>
      ExportedScoreChange(
        playerId: json['playerId'] as String,
        delta: json['delta'] as int,
        reasonCode: json['reasonCode'] as String,
        reasonLabel: json['reasonLabel'] as String,
      );
}
