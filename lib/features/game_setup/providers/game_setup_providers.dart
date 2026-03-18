import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/core/utils/id_generator.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/daos/session_dao.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// A player pending creation — not yet persisted to the database.
class PendingPlayer {
  PendingPlayer({
    required this.name,
    required this.colorKey,
    required this.seatOrder,
    this.avatarStyle = 'initials',
  });

  final String name;
  final String colorKey;
  final int seatOrder;
  final String avatarStyle;

  PendingPlayer copyWith({
    String? name,
    String? colorKey,
    int? seatOrder,
    String? avatarStyle,
  }) {
    return PendingPlayer(
      name: name ?? this.name,
      colorKey: colorKey ?? this.colorKey,
      seatOrder: seatOrder ?? this.seatOrder,
      avatarStyle: avatarStyle ?? this.avatarStyle,
    );
  }
}

/// Immutable snapshot of the game-setup form state.
class GameSetupState {
  const GameSetupState({
    this.title = '',
    this.targetType = TargetType.score,
    this.targetScore = 30,
    this.continuePastTarget = false,
    this.players = const [],
  });

  final String title;
  final TargetType targetType;
  final int targetScore;
  final bool continuePastTarget;
  final List<PendingPlayer> players;

  /// True when the minimum player count is met.
  bool get canStart => players.length >= 3;

  /// True when the maximum player count has been reached.
  bool get isPlayerLimitReached => players.length >= 10;

  /// Color keys already taken by current players.
  Set<String> get usedColorKeys => players.map((p) => p.colorKey).toSet();

  GameSetupState copyWith({
    String? title,
    TargetType? targetType,
    int? targetScore,
    bool? continuePastTarget,
    List<PendingPlayer>? players,
  }) {
    return GameSetupState(
      title: title ?? this.title,
      targetType: targetType ?? this.targetType,
      targetScore: targetScore ?? this.targetScore,
      continuePastTarget: continuePastTarget ?? this.continuePastTarget,
      players: players ?? this.players,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class GameSetupNotifier extends Notifier<GameSetupState> {
  @override
  GameSetupState build() => const GameSetupState();

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setTargetType(TargetType type) {
    state = state.copyWith(targetType: type);
  }

  void setTargetScore(int score) {
    state = state.copyWith(targetScore: score.clamp(10, 200));
  }

  void setContinuePastTarget(bool value) {
    state = state.copyWith(continuePastTarget: value);
  }

  void addPlayer({
    required String name,
    required String colorKey,
    String avatarStyle = 'initials',
  }) {
    if (state.isPlayerLimitReached) return;
    final player = PendingPlayer(
      name: name,
      colorKey: colorKey,
      seatOrder: state.players.length,
      avatarStyle: avatarStyle,
    );
    state = state.copyWith(players: [...state.players, player]);
  }

  void removePlayer(int index) {
    final updated = List<PendingPlayer>.from(state.players)..removeAt(index);
    for (int i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(seatOrder: i);
    }
    state = state.copyWith(players: updated);
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    final updated = List<PendingPlayer>.from(state.players);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    for (int i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(seatOrder: i);
    }
    state = state.copyWith(players: updated);
  }

  /// Persists the session and players to the database.
  /// Returns the new session ID.
  Future<String> createGame(SessionDao dao) async {
    final sessionId = IdGenerator.newId();

    final sessionCompanion = GameSessionsCompanion.insert(
      id: sessionId,
      title: Value(state.title),
      status: GameStatus.active,
      targetType: state.targetType,
      targetScore: state.targetType == TargetType.freeplay
          ? const Value(null)
          : Value(state.targetScore),
      continuePastTargetEnabled: Value(state.continuePastTarget),
    );

    final playerCompanions = state.players.map((p) {
      return PlayersCompanion.insert(
        id: IdGenerator.newId(),
        sessionId: sessionId,
        name: p.name,
        seatOrder: p.seatOrder,
        colorKey: p.colorKey,
        avatarStyle: Value(p.avatarStyle),
      );
    }).toList();

    await dao.createSession(sessionCompanion, playerCompanions);
    return sessionId;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final gameSetupProvider = NotifierProvider<GameSetupNotifier, GameSetupState>(
  GameSetupNotifier.new,
);
