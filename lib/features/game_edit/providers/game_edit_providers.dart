import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/core/utils/id_generator.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// A player being edited — may be an existing DB player or a new addition.
class EditablePlayer {
  EditablePlayer({
    required this.id,
    required this.name,
    required this.colorKey,
    required this.seatOrder,
    this.avatarStyle = 'initials',
    this.isNew = false,
  });

  final String id;
  final String name;
  final String colorKey;
  final int seatOrder;
  final String avatarStyle;
  final bool isNew;

  EditablePlayer copyWith({
    String? name,
    String? colorKey,
    int? seatOrder,
    String? avatarStyle,
    bool? isNew,
  }) {
    return EditablePlayer(
      id: id,
      name: name ?? this.name,
      colorKey: colorKey ?? this.colorKey,
      seatOrder: seatOrder ?? this.seatOrder,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      isNew: isNew ?? this.isNew,
    );
  }
}

/// Immutable snapshot of the game-edit form state.
class GameEditState {
  const GameEditState({
    this.sessionId = '',
    this.title = '',
    this.targetType = TargetType.score,
    this.targetScore = 30,
    this.continuePastTarget = false,
    this.players = const [],
    this.isLoaded = false,
  });

  final String sessionId;
  final String title;
  final TargetType targetType;
  final int targetScore;
  final bool continuePastTarget;
  final List<EditablePlayer> players;
  final bool isLoaded;

  bool get isPlayerLimitReached => players.length >= 10;

  Set<String> get usedColorKeys => players.map((p) => p.colorKey).toSet();

  GameEditState copyWith({
    String? sessionId,
    String? title,
    TargetType? targetType,
    int? targetScore,
    bool? continuePastTarget,
    List<EditablePlayer>? players,
    bool? isLoaded,
  }) {
    return GameEditState(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      targetType: targetType ?? this.targetType,
      targetScore: targetScore ?? this.targetScore,
      continuePastTarget: continuePastTarget ?? this.continuePastTarget,
      players: players ?? this.players,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class GameEditNotifier extends Notifier<GameEditState> {
  @override
  GameEditState build() => const GameEditState();

  /// Load the current session and players from the database.
  Future<void> loadSession(String sessionId) async {
    final dao = ref.read(sessionDaoProvider);
    final session =
        await (dao.watchSession(sessionId)).first;
    if (session == null) return;

    final players = await dao.getPlayersForSession(sessionId);

    state = GameEditState(
      sessionId: sessionId,
      title: session.title,
      targetType: session.targetType,
      targetScore: session.targetScore ?? 30,
      continuePastTarget: session.continuePastTargetEnabled,
      players: players
          .map((p) => EditablePlayer(
                id: p.id,
                name: p.name,
                colorKey: p.colorKey,
                seatOrder: p.seatOrder,
                avatarStyle: p.avatarStyle,
              ))
          .toList(),
      isLoaded: true,
    );
  }

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

  void updatePlayerName(int index, String name) {
    final updated = List<EditablePlayer>.from(state.players);
    updated[index] = updated[index].copyWith(name: name);
    state = state.copyWith(players: updated);
  }

  void updatePlayerColor(int index, String colorKey) {
    final updated = List<EditablePlayer>.from(state.players);
    updated[index] = updated[index].copyWith(colorKey: colorKey);
    state = state.copyWith(players: updated);
  }

  void addPlayer({
    required String name,
    required String colorKey,
    String avatarStyle = 'initials',
  }) {
    if (state.isPlayerLimitReached) return;
    final player = EditablePlayer(
      id: IdGenerator.newId(),
      name: name,
      colorKey: colorKey,
      seatOrder: state.players.length,
      avatarStyle: avatarStyle,
      isNew: true,
    );
    state = state.copyWith(players: [...state.players, player]);
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    final updated = List<EditablePlayer>.from(state.players);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    for (int i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(seatOrder: i);
    }
    state = state.copyWith(players: updated);
  }

  /// Persist all changes back to the database.
  Future<void> save() async {
    final dao = ref.read(sessionDaoProvider);

    // Update session fields
    await dao.updateSession(
      state.sessionId,
      GameSessionsCompanion(
        title: Value(state.title),
        targetType: Value(state.targetType),
        targetScore: state.targetType == TargetType.freeplay
            ? const Value(null)
            : Value(state.targetScore),
        continuePastTargetEnabled: Value(state.continuePastTarget),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Update existing players and add new ones
    for (final player in state.players) {
      if (player.isNew) {
        await dao.addPlayerToSession(
          PlayersCompanion.insert(
            id: player.id,
            sessionId: state.sessionId,
            name: player.name,
            seatOrder: player.seatOrder,
            colorKey: player.colorKey,
            avatarStyle: Value(player.avatarStyle),
          ),
        );
      } else {
        await dao.updatePlayer(
          player.id,
          PlayersCompanion(
            name: Value(player.name),
            colorKey: Value(player.colorKey),
            seatOrder: Value(player.seatOrder),
          ),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final gameEditProvider = NotifierProvider<GameEditNotifier, GameEditState>(
  GameEditNotifier.new,
);
