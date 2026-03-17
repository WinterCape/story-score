// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GameSessionsTable extends GameSessions
    with TableInfo<$GameSessionsTable, GameSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<GameStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<GameStatus>($GameSessionsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<TargetType, int> targetType =
      GeneratedColumn<int>(
        'target_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TargetType>($GameSessionsTable.$convertertargetType);
  static const VerificationMeta _targetScoreMeta = const VerificationMeta(
    'targetScore',
  );
  @override
  late final GeneratedColumn<int> targetScore = GeneratedColumn<int>(
    'target_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _continuePastTargetEnabledMeta =
      const VerificationMeta('continuePastTargetEnabled');
  @override
  late final GeneratedColumn<bool> continuePastTargetEnabled =
      GeneratedColumn<bool>(
        'continue_past_target_enabled',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("continue_past_target_enabled" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _currentStorytellerSeatMeta =
      const VerificationMeta('currentStorytellerSeat');
  @override
  late final GeneratedColumn<int> currentStorytellerSeat = GeneratedColumn<int>(
    'current_storyteller_seat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _roundCountMeta = const VerificationMeta(
    'roundCount',
  );
  @override
  late final GeneratedColumn<int> roundCount = GeneratedColumn<int>(
    'round_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    status,
    targetType,
    targetScore,
    continuePastTargetEnabled,
    createdAt,
    updatedAt,
    currentStorytellerSeat,
    roundCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('target_score')) {
      context.handle(
        _targetScoreMeta,
        targetScore.isAcceptableOrUnknown(
          data['target_score']!,
          _targetScoreMeta,
        ),
      );
    }
    if (data.containsKey('continue_past_target_enabled')) {
      context.handle(
        _continuePastTargetEnabledMeta,
        continuePastTargetEnabled.isAcceptableOrUnknown(
          data['continue_past_target_enabled']!,
          _continuePastTargetEnabledMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('current_storyteller_seat')) {
      context.handle(
        _currentStorytellerSeatMeta,
        currentStorytellerSeat.isAcceptableOrUnknown(
          data['current_storyteller_seat']!,
          _currentStorytellerSeatMeta,
        ),
      );
    }
    if (data.containsKey('round_count')) {
      context.handle(
        _roundCountMeta,
        roundCount.isAcceptableOrUnknown(data['round_count']!, _roundCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: $GameSessionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      targetType: $GameSessionsTable.$convertertargetType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}target_type'],
        )!,
      ),
      targetScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_score'],
      ),
      continuePastTargetEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}continue_past_target_enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      currentStorytellerSeat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_storyteller_seat'],
      )!,
      roundCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_count'],
      )!,
    );
  }

  @override
  $GameSessionsTable createAlias(String alias) {
    return $GameSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GameStatus, int, int> $converterstatus =
      const EnumIndexConverter<GameStatus>(GameStatus.values);
  static JsonTypeConverter2<TargetType, int, int> $convertertargetType =
      const EnumIndexConverter<TargetType>(TargetType.values);
}

class GameSession extends DataClass implements Insertable<GameSession> {
  final String id;
  final String title;
  final GameStatus status;
  final TargetType targetType;
  final int? targetScore;
  final bool continuePastTargetEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int currentStorytellerSeat;
  final int roundCount;
  const GameSession({
    required this.id,
    required this.title,
    required this.status,
    required this.targetType,
    this.targetScore,
    required this.continuePastTargetEnabled,
    required this.createdAt,
    required this.updatedAt,
    required this.currentStorytellerSeat,
    required this.roundCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    {
      map['status'] = Variable<int>(
        $GameSessionsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['target_type'] = Variable<int>(
        $GameSessionsTable.$convertertargetType.toSql(targetType),
      );
    }
    if (!nullToAbsent || targetScore != null) {
      map['target_score'] = Variable<int>(targetScore);
    }
    map['continue_past_target_enabled'] = Variable<bool>(
      continuePastTargetEnabled,
    );
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['current_storyteller_seat'] = Variable<int>(currentStorytellerSeat);
    map['round_count'] = Variable<int>(roundCount);
    return map;
  }

  GameSessionsCompanion toCompanion(bool nullToAbsent) {
    return GameSessionsCompanion(
      id: Value(id),
      title: Value(title),
      status: Value(status),
      targetType: Value(targetType),
      targetScore: targetScore == null && nullToAbsent
          ? const Value.absent()
          : Value(targetScore),
      continuePastTargetEnabled: Value(continuePastTargetEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      currentStorytellerSeat: Value(currentStorytellerSeat),
      roundCount: Value(roundCount),
    );
  }

  factory GameSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSession(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      status: $GameSessionsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      targetType: $GameSessionsTable.$convertertargetType.fromJson(
        serializer.fromJson<int>(json['targetType']),
      ),
      targetScore: serializer.fromJson<int?>(json['targetScore']),
      continuePastTargetEnabled: serializer.fromJson<bool>(
        json['continuePastTargetEnabled'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      currentStorytellerSeat: serializer.fromJson<int>(
        json['currentStorytellerSeat'],
      ),
      roundCount: serializer.fromJson<int>(json['roundCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<int>(
        $GameSessionsTable.$converterstatus.toJson(status),
      ),
      'targetType': serializer.toJson<int>(
        $GameSessionsTable.$convertertargetType.toJson(targetType),
      ),
      'targetScore': serializer.toJson<int?>(targetScore),
      'continuePastTargetEnabled': serializer.toJson<bool>(
        continuePastTargetEnabled,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'currentStorytellerSeat': serializer.toJson<int>(currentStorytellerSeat),
      'roundCount': serializer.toJson<int>(roundCount),
    };
  }

  GameSession copyWith({
    String? id,
    String? title,
    GameStatus? status,
    TargetType? targetType,
    Value<int?> targetScore = const Value.absent(),
    bool? continuePastTargetEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentStorytellerSeat,
    int? roundCount,
  }) => GameSession(
    id: id ?? this.id,
    title: title ?? this.title,
    status: status ?? this.status,
    targetType: targetType ?? this.targetType,
    targetScore: targetScore.present ? targetScore.value : this.targetScore,
    continuePastTargetEnabled:
        continuePastTargetEnabled ?? this.continuePastTargetEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    currentStorytellerSeat:
        currentStorytellerSeat ?? this.currentStorytellerSeat,
    roundCount: roundCount ?? this.roundCount,
  );
  GameSession copyWithCompanion(GameSessionsCompanion data) {
    return GameSession(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetScore: data.targetScore.present
          ? data.targetScore.value
          : this.targetScore,
      continuePastTargetEnabled: data.continuePastTargetEnabled.present
          ? data.continuePastTargetEnabled.value
          : this.continuePastTargetEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      currentStorytellerSeat: data.currentStorytellerSeat.present
          ? data.currentStorytellerSeat.value
          : this.currentStorytellerSeat,
      roundCount: data.roundCount.present
          ? data.roundCount.value
          : this.roundCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSession(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('targetType: $targetType, ')
          ..write('targetScore: $targetScore, ')
          ..write('continuePastTargetEnabled: $continuePastTargetEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('currentStorytellerSeat: $currentStorytellerSeat, ')
          ..write('roundCount: $roundCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    status,
    targetType,
    targetScore,
    continuePastTargetEnabled,
    createdAt,
    updatedAt,
    currentStorytellerSeat,
    roundCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSession &&
          other.id == this.id &&
          other.title == this.title &&
          other.status == this.status &&
          other.targetType == this.targetType &&
          other.targetScore == this.targetScore &&
          other.continuePastTargetEnabled == this.continuePastTargetEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.currentStorytellerSeat == this.currentStorytellerSeat &&
          other.roundCount == this.roundCount);
}

class GameSessionsCompanion extends UpdateCompanion<GameSession> {
  final Value<String> id;
  final Value<String> title;
  final Value<GameStatus> status;
  final Value<TargetType> targetType;
  final Value<int?> targetScore;
  final Value<bool> continuePastTargetEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> currentStorytellerSeat;
  final Value<int> roundCount;
  final Value<int> rowid;
  const GameSessionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetScore = const Value.absent(),
    this.continuePastTargetEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.currentStorytellerSeat = const Value.absent(),
    this.roundCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSessionsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required GameStatus status,
    required TargetType targetType,
    this.targetScore = const Value.absent(),
    this.continuePastTargetEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.currentStorytellerSeat = const Value.absent(),
    this.roundCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       targetType = Value(targetType);
  static Insertable<GameSession> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? status,
    Expression<int>? targetType,
    Expression<int>? targetScore,
    Expression<bool>? continuePastTargetEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? currentStorytellerSeat,
    Expression<int>? roundCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (targetType != null) 'target_type': targetType,
      if (targetScore != null) 'target_score': targetScore,
      if (continuePastTargetEnabled != null)
        'continue_past_target_enabled': continuePastTargetEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (currentStorytellerSeat != null)
        'current_storyteller_seat': currentStorytellerSeat,
      if (roundCount != null) 'round_count': roundCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<GameStatus>? status,
    Value<TargetType>? targetType,
    Value<int?>? targetScore,
    Value<bool>? continuePastTargetEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? currentStorytellerSeat,
    Value<int>? roundCount,
    Value<int>? rowid,
  }) {
    return GameSessionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      targetType: targetType ?? this.targetType,
      targetScore: targetScore ?? this.targetScore,
      continuePastTargetEnabled:
          continuePastTargetEnabled ?? this.continuePastTargetEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentStorytellerSeat:
          currentStorytellerSeat ?? this.currentStorytellerSeat,
      roundCount: roundCount ?? this.roundCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $GameSessionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (targetType.present) {
      map['target_type'] = Variable<int>(
        $GameSessionsTable.$convertertargetType.toSql(targetType.value),
      );
    }
    if (targetScore.present) {
      map['target_score'] = Variable<int>(targetScore.value);
    }
    if (continuePastTargetEnabled.present) {
      map['continue_past_target_enabled'] = Variable<bool>(
        continuePastTargetEnabled.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (currentStorytellerSeat.present) {
      map['current_storyteller_seat'] = Variable<int>(
        currentStorytellerSeat.value,
      );
    }
    if (roundCount.present) {
      map['round_count'] = Variable<int>(roundCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSessionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('targetType: $targetType, ')
          ..write('targetScore: $targetScore, ')
          ..write('continuePastTargetEnabled: $continuePastTargetEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('currentStorytellerSeat: $currentStorytellerSeat, ')
          ..write('roundCount: $roundCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_sessions (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seatOrderMeta = const VerificationMeta(
    'seatOrder',
  );
  @override
  late final GeneratedColumn<int> seatOrder = GeneratedColumn<int>(
    'seat_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorKeyMeta = const VerificationMeta(
    'colorKey',
  );
  @override
  late final GeneratedColumn<String> colorKey = GeneratedColumn<String>(
    'color_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarStyleMeta = const VerificationMeta(
    'avatarStyle',
  );
  @override
  late final GeneratedColumn<String> avatarStyle = GeneratedColumn<String>(
    'avatar_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('initials'),
  );
  static const VerificationMeta _currentScoreMeta = const VerificationMeta(
    'currentScore',
  );
  @override
  late final GeneratedColumn<int> currentScore = GeneratedColumn<int>(
    'current_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    name,
    seatOrder,
    colorKey,
    avatarStyle,
    currentScore,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('seat_order')) {
      context.handle(
        _seatOrderMeta,
        seatOrder.isAcceptableOrUnknown(data['seat_order']!, _seatOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_seatOrderMeta);
    }
    if (data.containsKey('color_key')) {
      context.handle(
        _colorKeyMeta,
        colorKey.isAcceptableOrUnknown(data['color_key']!, _colorKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_colorKeyMeta);
    }
    if (data.containsKey('avatar_style')) {
      context.handle(
        _avatarStyleMeta,
        avatarStyle.isAcceptableOrUnknown(
          data['avatar_style']!,
          _avatarStyleMeta,
        ),
      );
    }
    if (data.containsKey('current_score')) {
      context.handle(
        _currentScoreMeta,
        currentScore.isAcceptableOrUnknown(
          data['current_score']!,
          _currentScoreMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      seatOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seat_order'],
      )!,
      colorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_key'],
      )!,
      avatarStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_style'],
      )!,
      currentScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_score'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final String id;
  final String sessionId;
  final String name;
  final int seatOrder;
  final String colorKey;
  final String avatarStyle;
  final int currentScore;
  final DateTime createdAt;
  const Player({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.seatOrder,
    required this.colorKey,
    required this.avatarStyle,
    required this.currentScore,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['name'] = Variable<String>(name);
    map['seat_order'] = Variable<int>(seatOrder);
    map['color_key'] = Variable<String>(colorKey);
    map['avatar_style'] = Variable<String>(avatarStyle);
    map['current_score'] = Variable<int>(currentScore);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      name: Value(name),
      seatOrder: Value(seatOrder),
      colorKey: Value(colorKey),
      avatarStyle: Value(avatarStyle),
      currentScore: Value(currentScore),
      createdAt: Value(createdAt),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      name: serializer.fromJson<String>(json['name']),
      seatOrder: serializer.fromJson<int>(json['seatOrder']),
      colorKey: serializer.fromJson<String>(json['colorKey']),
      avatarStyle: serializer.fromJson<String>(json['avatarStyle']),
      currentScore: serializer.fromJson<int>(json['currentScore']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'name': serializer.toJson<String>(name),
      'seatOrder': serializer.toJson<int>(seatOrder),
      'colorKey': serializer.toJson<String>(colorKey),
      'avatarStyle': serializer.toJson<String>(avatarStyle),
      'currentScore': serializer.toJson<int>(currentScore),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Player copyWith({
    String? id,
    String? sessionId,
    String? name,
    int? seatOrder,
    String? colorKey,
    String? avatarStyle,
    int? currentScore,
    DateTime? createdAt,
  }) => Player(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    name: name ?? this.name,
    seatOrder: seatOrder ?? this.seatOrder,
    colorKey: colorKey ?? this.colorKey,
    avatarStyle: avatarStyle ?? this.avatarStyle,
    currentScore: currentScore ?? this.currentScore,
    createdAt: createdAt ?? this.createdAt,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      name: data.name.present ? data.name.value : this.name,
      seatOrder: data.seatOrder.present ? data.seatOrder.value : this.seatOrder,
      colorKey: data.colorKey.present ? data.colorKey.value : this.colorKey,
      avatarStyle: data.avatarStyle.present
          ? data.avatarStyle.value
          : this.avatarStyle,
      currentScore: data.currentScore.present
          ? data.currentScore.value
          : this.currentScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('seatOrder: $seatOrder, ')
          ..write('colorKey: $colorKey, ')
          ..write('avatarStyle: $avatarStyle, ')
          ..write('currentScore: $currentScore, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    name,
    seatOrder,
    colorKey,
    avatarStyle,
    currentScore,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.name == this.name &&
          other.seatOrder == this.seatOrder &&
          other.colorKey == this.colorKey &&
          other.avatarStyle == this.avatarStyle &&
          other.currentScore == this.currentScore &&
          other.createdAt == this.createdAt);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> name;
  final Value<int> seatOrder;
  final Value<String> colorKey;
  final Value<String> avatarStyle;
  final Value<int> currentScore;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.name = const Value.absent(),
    this.seatOrder = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.avatarStyle = const Value.absent(),
    this.currentScore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required String id,
    required String sessionId,
    required String name,
    required int seatOrder,
    required String colorKey,
    this.avatarStyle = const Value.absent(),
    this.currentScore = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       name = Value(name),
       seatOrder = Value(seatOrder),
       colorKey = Value(colorKey);
  static Insertable<Player> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? name,
    Expression<int>? seatOrder,
    Expression<String>? colorKey,
    Expression<String>? avatarStyle,
    Expression<int>? currentScore,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (name != null) 'name': name,
      if (seatOrder != null) 'seat_order': seatOrder,
      if (colorKey != null) 'color_key': colorKey,
      if (avatarStyle != null) 'avatar_style': avatarStyle,
      if (currentScore != null) 'current_score': currentScore,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? name,
    Value<int>? seatOrder,
    Value<String>? colorKey,
    Value<String>? avatarStyle,
    Value<int>? currentScore,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      seatOrder: seatOrder ?? this.seatOrder,
      colorKey: colorKey ?? this.colorKey,
      avatarStyle: avatarStyle ?? this.avatarStyle,
      currentScore: currentScore ?? this.currentScore,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (seatOrder.present) {
      map['seat_order'] = Variable<int>(seatOrder.value);
    }
    if (colorKey.present) {
      map['color_key'] = Variable<String>(colorKey.value);
    }
    if (avatarStyle.present) {
      map['avatar_style'] = Variable<String>(avatarStyle.value);
    }
    if (currentScore.present) {
      map['current_score'] = Variable<int>(currentScore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('name: $name, ')
          ..write('seatOrder: $seatOrder, ')
          ..write('colorKey: $colorKey, ')
          ..write('avatarStyle: $avatarStyle, ')
          ..write('currentScore: $currentScore, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundsTable extends Rounds with TableInfo<$RoundsTable, Round> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES game_sessions (id)',
    ),
  );
  static const VerificationMeta _roundNumberMeta = const VerificationMeta(
    'roundNumber',
  );
  @override
  late final GeneratedColumn<int> roundNumber = GeneratedColumn<int>(
    'round_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storytellerPlayerIdMeta =
      const VerificationMeta('storytellerPlayerId');
  @override
  late final GeneratedColumn<String> storytellerPlayerId =
      GeneratedColumn<String>(
        'storyteller_player_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES players (id)',
        ),
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    roundNumber,
    storytellerPlayerId,
    note,
    createdAt,
    editedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rounds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Round> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('round_number')) {
      context.handle(
        _roundNumberMeta,
        roundNumber.isAcceptableOrUnknown(
          data['round_number']!,
          _roundNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roundNumberMeta);
    }
    if (data.containsKey('storyteller_player_id')) {
      context.handle(
        _storytellerPlayerIdMeta,
        storytellerPlayerId.isAcceptableOrUnknown(
          data['storyteller_player_id']!,
          _storytellerPlayerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storytellerPlayerIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Round map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Round(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      roundNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_number'],
      )!,
      storytellerPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storyteller_player_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
    );
  }

  @override
  $RoundsTable createAlias(String alias) {
    return $RoundsTable(attachedDatabase, alias);
  }
}

class Round extends DataClass implements Insertable<Round> {
  final String id;
  final String sessionId;
  final int roundNumber;
  final String storytellerPlayerId;
  final String note;
  final DateTime createdAt;
  final DateTime? editedAt;
  const Round({
    required this.id,
    required this.sessionId,
    required this.roundNumber,
    required this.storytellerPlayerId,
    required this.note,
    required this.createdAt,
    this.editedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['round_number'] = Variable<int>(roundNumber);
    map['storyteller_player_id'] = Variable<String>(storytellerPlayerId);
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    return map;
  }

  RoundsCompanion toCompanion(bool nullToAbsent) {
    return RoundsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      roundNumber: Value(roundNumber),
      storytellerPlayerId: Value(storytellerPlayerId),
      note: Value(note),
      createdAt: Value(createdAt),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
    );
  }

  factory Round.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Round(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      roundNumber: serializer.fromJson<int>(json['roundNumber']),
      storytellerPlayerId: serializer.fromJson<String>(
        json['storytellerPlayerId'],
      ),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'roundNumber': serializer.toJson<int>(roundNumber),
      'storytellerPlayerId': serializer.toJson<String>(storytellerPlayerId),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
    };
  }

  Round copyWith({
    String? id,
    String? sessionId,
    int? roundNumber,
    String? storytellerPlayerId,
    String? note,
    DateTime? createdAt,
    Value<DateTime?> editedAt = const Value.absent(),
  }) => Round(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    roundNumber: roundNumber ?? this.roundNumber,
    storytellerPlayerId: storytellerPlayerId ?? this.storytellerPlayerId,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
  );
  Round copyWithCompanion(RoundsCompanion data) {
    return Round(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      roundNumber: data.roundNumber.present
          ? data.roundNumber.value
          : this.roundNumber,
      storytellerPlayerId: data.storytellerPlayerId.present
          ? data.storytellerPlayerId.value
          : this.storytellerPlayerId,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Round(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('storytellerPlayerId: $storytellerPlayerId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    roundNumber,
    storytellerPlayerId,
    note,
    createdAt,
    editedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Round &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.roundNumber == this.roundNumber &&
          other.storytellerPlayerId == this.storytellerPlayerId &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.editedAt == this.editedAt);
}

class RoundsCompanion extends UpdateCompanion<Round> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> roundNumber;
  final Value<String> storytellerPlayerId;
  final Value<String> note;
  final Value<DateTime> createdAt;
  final Value<DateTime?> editedAt;
  final Value<int> rowid;
  const RoundsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.roundNumber = const Value.absent(),
    this.storytellerPlayerId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundsCompanion.insert({
    required String id,
    required String sessionId,
    required int roundNumber,
    required String storytellerPlayerId,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       roundNumber = Value(roundNumber),
       storytellerPlayerId = Value(storytellerPlayerId);
  static Insertable<Round> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? roundNumber,
    Expression<String>? storytellerPlayerId,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? editedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (roundNumber != null) 'round_number': roundNumber,
      if (storytellerPlayerId != null)
        'storyteller_player_id': storytellerPlayerId,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (editedAt != null) 'edited_at': editedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? roundNumber,
    Value<String>? storytellerPlayerId,
    Value<String>? note,
    Value<DateTime>? createdAt,
    Value<DateTime?>? editedAt,
    Value<int>? rowid,
  }) {
    return RoundsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      roundNumber: roundNumber ?? this.roundNumber,
      storytellerPlayerId: storytellerPlayerId ?? this.storytellerPlayerId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (roundNumber.present) {
      map['round_number'] = Variable<int>(roundNumber.value);
    }
    if (storytellerPlayerId.present) {
      map['storyteller_player_id'] = Variable<String>(
        storytellerPlayerId.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('storytellerPlayerId: $storytellerPlayerId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('editedAt: $editedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VotesTable extends Votes with TableInfo<$VotesTable, Vote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundIdMeta = const VerificationMeta(
    'roundId',
  );
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
    'round_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rounds (id)',
    ),
  );
  static const VerificationMeta _voterPlayerIdMeta = const VerificationMeta(
    'voterPlayerId',
  );
  @override
  late final GeneratedColumn<String> voterPlayerId = GeneratedColumn<String>(
    'voter_player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _votedForPlayerIdMeta = const VerificationMeta(
    'votedForPlayerId',
  );
  @override
  late final GeneratedColumn<String> votedForPlayerId = GeneratedColumn<String>(
    'voted_for_player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roundId,
    voterPlayerId,
    votedForPlayerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'votes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('round_id')) {
      context.handle(
        _roundIdMeta,
        roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIdMeta);
    }
    if (data.containsKey('voter_player_id')) {
      context.handle(
        _voterPlayerIdMeta,
        voterPlayerId.isAcceptableOrUnknown(
          data['voter_player_id']!,
          _voterPlayerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_voterPlayerIdMeta);
    }
    if (data.containsKey('voted_for_player_id')) {
      context.handle(
        _votedForPlayerIdMeta,
        votedForPlayerId.isAcceptableOrUnknown(
          data['voted_for_player_id']!,
          _votedForPlayerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_votedForPlayerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_id'],
      )!,
      voterPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voter_player_id'],
      )!,
      votedForPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voted_for_player_id'],
      )!,
    );
  }

  @override
  $VotesTable createAlias(String alias) {
    return $VotesTable(attachedDatabase, alias);
  }
}

class Vote extends DataClass implements Insertable<Vote> {
  final String id;
  final String roundId;
  final String voterPlayerId;
  final String votedForPlayerId;
  const Vote({
    required this.id,
    required this.roundId,
    required this.voterPlayerId,
    required this.votedForPlayerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['round_id'] = Variable<String>(roundId);
    map['voter_player_id'] = Variable<String>(voterPlayerId);
    map['voted_for_player_id'] = Variable<String>(votedForPlayerId);
    return map;
  }

  VotesCompanion toCompanion(bool nullToAbsent) {
    return VotesCompanion(
      id: Value(id),
      roundId: Value(roundId),
      voterPlayerId: Value(voterPlayerId),
      votedForPlayerId: Value(votedForPlayerId),
    );
  }

  factory Vote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vote(
      id: serializer.fromJson<String>(json['id']),
      roundId: serializer.fromJson<String>(json['roundId']),
      voterPlayerId: serializer.fromJson<String>(json['voterPlayerId']),
      votedForPlayerId: serializer.fromJson<String>(json['votedForPlayerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roundId': serializer.toJson<String>(roundId),
      'voterPlayerId': serializer.toJson<String>(voterPlayerId),
      'votedForPlayerId': serializer.toJson<String>(votedForPlayerId),
    };
  }

  Vote copyWith({
    String? id,
    String? roundId,
    String? voterPlayerId,
    String? votedForPlayerId,
  }) => Vote(
    id: id ?? this.id,
    roundId: roundId ?? this.roundId,
    voterPlayerId: voterPlayerId ?? this.voterPlayerId,
    votedForPlayerId: votedForPlayerId ?? this.votedForPlayerId,
  );
  Vote copyWithCompanion(VotesCompanion data) {
    return Vote(
      id: data.id.present ? data.id.value : this.id,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      voterPlayerId: data.voterPlayerId.present
          ? data.voterPlayerId.value
          : this.voterPlayerId,
      votedForPlayerId: data.votedForPlayerId.present
          ? data.votedForPlayerId.value
          : this.votedForPlayerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vote(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('voterPlayerId: $voterPlayerId, ')
          ..write('votedForPlayerId: $votedForPlayerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roundId, voterPlayerId, votedForPlayerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vote &&
          other.id == this.id &&
          other.roundId == this.roundId &&
          other.voterPlayerId == this.voterPlayerId &&
          other.votedForPlayerId == this.votedForPlayerId);
}

class VotesCompanion extends UpdateCompanion<Vote> {
  final Value<String> id;
  final Value<String> roundId;
  final Value<String> voterPlayerId;
  final Value<String> votedForPlayerId;
  final Value<int> rowid;
  const VotesCompanion({
    this.id = const Value.absent(),
    this.roundId = const Value.absent(),
    this.voterPlayerId = const Value.absent(),
    this.votedForPlayerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VotesCompanion.insert({
    required String id,
    required String roundId,
    required String voterPlayerId,
    required String votedForPlayerId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roundId = Value(roundId),
       voterPlayerId = Value(voterPlayerId),
       votedForPlayerId = Value(votedForPlayerId);
  static Insertable<Vote> custom({
    Expression<String>? id,
    Expression<String>? roundId,
    Expression<String>? voterPlayerId,
    Expression<String>? votedForPlayerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roundId != null) 'round_id': roundId,
      if (voterPlayerId != null) 'voter_player_id': voterPlayerId,
      if (votedForPlayerId != null) 'voted_for_player_id': votedForPlayerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VotesCompanion copyWith({
    Value<String>? id,
    Value<String>? roundId,
    Value<String>? voterPlayerId,
    Value<String>? votedForPlayerId,
    Value<int>? rowid,
  }) {
    return VotesCompanion(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      voterPlayerId: voterPlayerId ?? this.voterPlayerId,
      votedForPlayerId: votedForPlayerId ?? this.votedForPlayerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (voterPlayerId.present) {
      map['voter_player_id'] = Variable<String>(voterPlayerId.value);
    }
    if (votedForPlayerId.present) {
      map['voted_for_player_id'] = Variable<String>(votedForPlayerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VotesCompanion(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('voterPlayerId: $voterPlayerId, ')
          ..write('votedForPlayerId: $votedForPlayerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScoreChangesTable extends ScoreChanges
    with TableInfo<$ScoreChangesTable, ScoreChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScoreChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundIdMeta = const VerificationMeta(
    'roundId',
  );
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
    'round_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rounds (id)',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id)',
    ),
  );
  static const VerificationMeta _deltaMeta = const VerificationMeta('delta');
  @override
  late final GeneratedColumn<int> delta = GeneratedColumn<int>(
    'delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonCodeMeta = const VerificationMeta(
    'reasonCode',
  );
  @override
  late final GeneratedColumn<String> reasonCode = GeneratedColumn<String>(
    'reason_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonLabelMeta = const VerificationMeta(
    'reasonLabel',
  );
  @override
  late final GeneratedColumn<String> reasonLabel = GeneratedColumn<String>(
    'reason_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    roundId,
    playerId,
    delta,
    reasonCode,
    reasonLabel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'score_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScoreChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('round_id')) {
      context.handle(
        _roundIdMeta,
        roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roundIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('delta')) {
      context.handle(
        _deltaMeta,
        delta.isAcceptableOrUnknown(data['delta']!, _deltaMeta),
      );
    } else if (isInserting) {
      context.missing(_deltaMeta);
    }
    if (data.containsKey('reason_code')) {
      context.handle(
        _reasonCodeMeta,
        reasonCode.isAcceptableOrUnknown(data['reason_code']!, _reasonCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonCodeMeta);
    }
    if (data.containsKey('reason_label')) {
      context.handle(
        _reasonLabelMeta,
        reasonLabel.isAcceptableOrUnknown(
          data['reason_label']!,
          _reasonLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reasonLabelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScoreChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScoreChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}round_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      delta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delta'],
      )!,
      reasonCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_code'],
      )!,
      reasonLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_label'],
      )!,
    );
  }

  @override
  $ScoreChangesTable createAlias(String alias) {
    return $ScoreChangesTable(attachedDatabase, alias);
  }
}

class ScoreChange extends DataClass implements Insertable<ScoreChange> {
  final String id;
  final String roundId;
  final String playerId;
  final int delta;
  final String reasonCode;
  final String reasonLabel;
  const ScoreChange({
    required this.id,
    required this.roundId,
    required this.playerId,
    required this.delta,
    required this.reasonCode,
    required this.reasonLabel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['round_id'] = Variable<String>(roundId);
    map['player_id'] = Variable<String>(playerId);
    map['delta'] = Variable<int>(delta);
    map['reason_code'] = Variable<String>(reasonCode);
    map['reason_label'] = Variable<String>(reasonLabel);
    return map;
  }

  ScoreChangesCompanion toCompanion(bool nullToAbsent) {
    return ScoreChangesCompanion(
      id: Value(id),
      roundId: Value(roundId),
      playerId: Value(playerId),
      delta: Value(delta),
      reasonCode: Value(reasonCode),
      reasonLabel: Value(reasonLabel),
    );
  }

  factory ScoreChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScoreChange(
      id: serializer.fromJson<String>(json['id']),
      roundId: serializer.fromJson<String>(json['roundId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      delta: serializer.fromJson<int>(json['delta']),
      reasonCode: serializer.fromJson<String>(json['reasonCode']),
      reasonLabel: serializer.fromJson<String>(json['reasonLabel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roundId': serializer.toJson<String>(roundId),
      'playerId': serializer.toJson<String>(playerId),
      'delta': serializer.toJson<int>(delta),
      'reasonCode': serializer.toJson<String>(reasonCode),
      'reasonLabel': serializer.toJson<String>(reasonLabel),
    };
  }

  ScoreChange copyWith({
    String? id,
    String? roundId,
    String? playerId,
    int? delta,
    String? reasonCode,
    String? reasonLabel,
  }) => ScoreChange(
    id: id ?? this.id,
    roundId: roundId ?? this.roundId,
    playerId: playerId ?? this.playerId,
    delta: delta ?? this.delta,
    reasonCode: reasonCode ?? this.reasonCode,
    reasonLabel: reasonLabel ?? this.reasonLabel,
  );
  ScoreChange copyWithCompanion(ScoreChangesCompanion data) {
    return ScoreChange(
      id: data.id.present ? data.id.value : this.id,
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      delta: data.delta.present ? data.delta.value : this.delta,
      reasonCode: data.reasonCode.present
          ? data.reasonCode.value
          : this.reasonCode,
      reasonLabel: data.reasonLabel.present
          ? data.reasonLabel.value
          : this.reasonLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScoreChange(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('playerId: $playerId, ')
          ..write('delta: $delta, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('reasonLabel: $reasonLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, roundId, playerId, delta, reasonCode, reasonLabel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreChange &&
          other.id == this.id &&
          other.roundId == this.roundId &&
          other.playerId == this.playerId &&
          other.delta == this.delta &&
          other.reasonCode == this.reasonCode &&
          other.reasonLabel == this.reasonLabel);
}

class ScoreChangesCompanion extends UpdateCompanion<ScoreChange> {
  final Value<String> id;
  final Value<String> roundId;
  final Value<String> playerId;
  final Value<int> delta;
  final Value<String> reasonCode;
  final Value<String> reasonLabel;
  final Value<int> rowid;
  const ScoreChangesCompanion({
    this.id = const Value.absent(),
    this.roundId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.delta = const Value.absent(),
    this.reasonCode = const Value.absent(),
    this.reasonLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScoreChangesCompanion.insert({
    required String id,
    required String roundId,
    required String playerId,
    required int delta,
    required String reasonCode,
    required String reasonLabel,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roundId = Value(roundId),
       playerId = Value(playerId),
       delta = Value(delta),
       reasonCode = Value(reasonCode),
       reasonLabel = Value(reasonLabel);
  static Insertable<ScoreChange> custom({
    Expression<String>? id,
    Expression<String>? roundId,
    Expression<String>? playerId,
    Expression<int>? delta,
    Expression<String>? reasonCode,
    Expression<String>? reasonLabel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roundId != null) 'round_id': roundId,
      if (playerId != null) 'player_id': playerId,
      if (delta != null) 'delta': delta,
      if (reasonCode != null) 'reason_code': reasonCode,
      if (reasonLabel != null) 'reason_label': reasonLabel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScoreChangesCompanion copyWith({
    Value<String>? id,
    Value<String>? roundId,
    Value<String>? playerId,
    Value<int>? delta,
    Value<String>? reasonCode,
    Value<String>? reasonLabel,
    Value<int>? rowid,
  }) {
    return ScoreChangesCompanion(
      id: id ?? this.id,
      roundId: roundId ?? this.roundId,
      playerId: playerId ?? this.playerId,
      delta: delta ?? this.delta,
      reasonCode: reasonCode ?? this.reasonCode,
      reasonLabel: reasonLabel ?? this.reasonLabel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (delta.present) {
      map['delta'] = Variable<int>(delta.value);
    }
    if (reasonCode.present) {
      map['reason_code'] = Variable<String>(reasonCode.value);
    }
    if (reasonLabel.present) {
      map['reason_label'] = Variable<String>(reasonLabel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScoreChangesCompanion(')
          ..write('id: $id, ')
          ..write('roundId: $roundId, ')
          ..write('playerId: $playerId, ')
          ..write('delta: $delta, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('reasonLabel: $reasonLabel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseEntitlementsTable extends PurchaseEntitlements
    with TableInfo<$PurchaseEntitlementsTable, PurchaseEntitlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseEntitlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entitlementTypeMeta = const VerificationMeta(
    'entitlementType',
  );
  @override
  late final GeneratedColumn<String> entitlementType = GeneratedColumn<String>(
    'entitlement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceStoreMeta = const VerificationMeta(
    'sourceStore',
  );
  @override
  late final GeneratedColumn<String> sourceStore = GeneratedColumn<String>(
    'source_store',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasedAtMeta = const VerificationMeta(
    'purchasedAt',
  );
  @override
  late final GeneratedColumn<DateTime> purchasedAt = GeneratedColumn<DateTime>(
    'purchased_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restoredAtMeta = const VerificationMeta(
    'restoredAt',
  );
  @override
  late final GeneratedColumn<DateTime> restoredAt = GeneratedColumn<DateTime>(
    'restored_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastValidatedAtMeta = const VerificationMeta(
    'lastValidatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastValidatedAt =
      GeneratedColumn<DateTime>(
        'last_validated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    productId,
    entitlementType,
    isActive,
    sourceStore,
    purchasedAt,
    restoredAt,
    lastValidatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_entitlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseEntitlement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('entitlement_type')) {
      context.handle(
        _entitlementTypeMeta,
        entitlementType.isAcceptableOrUnknown(
          data['entitlement_type']!,
          _entitlementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entitlementTypeMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('source_store')) {
      context.handle(
        _sourceStoreMeta,
        sourceStore.isAcceptableOrUnknown(
          data['source_store']!,
          _sourceStoreMeta,
        ),
      );
    }
    if (data.containsKey('purchased_at')) {
      context.handle(
        _purchasedAtMeta,
        purchasedAt.isAcceptableOrUnknown(
          data['purchased_at']!,
          _purchasedAtMeta,
        ),
      );
    }
    if (data.containsKey('restored_at')) {
      context.handle(
        _restoredAtMeta,
        restoredAt.isAcceptableOrUnknown(data['restored_at']!, _restoredAtMeta),
      );
    }
    if (data.containsKey('last_validated_at')) {
      context.handle(
        _lastValidatedAtMeta,
        lastValidatedAt.isAcceptableOrUnknown(
          data['last_validated_at']!,
          _lastValidatedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  PurchaseEntitlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseEntitlement(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      entitlementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entitlement_type'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sourceStore: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_store'],
      ),
      purchasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchased_at'],
      ),
      restoredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}restored_at'],
      ),
      lastValidatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_validated_at'],
      ),
    );
  }

  @override
  $PurchaseEntitlementsTable createAlias(String alias) {
    return $PurchaseEntitlementsTable(attachedDatabase, alias);
  }
}

class PurchaseEntitlement extends DataClass
    implements Insertable<PurchaseEntitlement> {
  final String productId;
  final String entitlementType;
  final bool isActive;
  final String? sourceStore;
  final DateTime? purchasedAt;
  final DateTime? restoredAt;
  final DateTime? lastValidatedAt;
  const PurchaseEntitlement({
    required this.productId,
    required this.entitlementType,
    required this.isActive,
    this.sourceStore,
    this.purchasedAt,
    this.restoredAt,
    this.lastValidatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['entitlement_type'] = Variable<String>(entitlementType);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || sourceStore != null) {
      map['source_store'] = Variable<String>(sourceStore);
    }
    if (!nullToAbsent || purchasedAt != null) {
      map['purchased_at'] = Variable<DateTime>(purchasedAt);
    }
    if (!nullToAbsent || restoredAt != null) {
      map['restored_at'] = Variable<DateTime>(restoredAt);
    }
    if (!nullToAbsent || lastValidatedAt != null) {
      map['last_validated_at'] = Variable<DateTime>(lastValidatedAt);
    }
    return map;
  }

  PurchaseEntitlementsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseEntitlementsCompanion(
      productId: Value(productId),
      entitlementType: Value(entitlementType),
      isActive: Value(isActive),
      sourceStore: sourceStore == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceStore),
      purchasedAt: purchasedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasedAt),
      restoredAt: restoredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(restoredAt),
      lastValidatedAt: lastValidatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastValidatedAt),
    );
  }

  factory PurchaseEntitlement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseEntitlement(
      productId: serializer.fromJson<String>(json['productId']),
      entitlementType: serializer.fromJson<String>(json['entitlementType']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sourceStore: serializer.fromJson<String?>(json['sourceStore']),
      purchasedAt: serializer.fromJson<DateTime?>(json['purchasedAt']),
      restoredAt: serializer.fromJson<DateTime?>(json['restoredAt']),
      lastValidatedAt: serializer.fromJson<DateTime?>(json['lastValidatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'entitlementType': serializer.toJson<String>(entitlementType),
      'isActive': serializer.toJson<bool>(isActive),
      'sourceStore': serializer.toJson<String?>(sourceStore),
      'purchasedAt': serializer.toJson<DateTime?>(purchasedAt),
      'restoredAt': serializer.toJson<DateTime?>(restoredAt),
      'lastValidatedAt': serializer.toJson<DateTime?>(lastValidatedAt),
    };
  }

  PurchaseEntitlement copyWith({
    String? productId,
    String? entitlementType,
    bool? isActive,
    Value<String?> sourceStore = const Value.absent(),
    Value<DateTime?> purchasedAt = const Value.absent(),
    Value<DateTime?> restoredAt = const Value.absent(),
    Value<DateTime?> lastValidatedAt = const Value.absent(),
  }) => PurchaseEntitlement(
    productId: productId ?? this.productId,
    entitlementType: entitlementType ?? this.entitlementType,
    isActive: isActive ?? this.isActive,
    sourceStore: sourceStore.present ? sourceStore.value : this.sourceStore,
    purchasedAt: purchasedAt.present ? purchasedAt.value : this.purchasedAt,
    restoredAt: restoredAt.present ? restoredAt.value : this.restoredAt,
    lastValidatedAt: lastValidatedAt.present
        ? lastValidatedAt.value
        : this.lastValidatedAt,
  );
  PurchaseEntitlement copyWithCompanion(PurchaseEntitlementsCompanion data) {
    return PurchaseEntitlement(
      productId: data.productId.present ? data.productId.value : this.productId,
      entitlementType: data.entitlementType.present
          ? data.entitlementType.value
          : this.entitlementType,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sourceStore: data.sourceStore.present
          ? data.sourceStore.value
          : this.sourceStore,
      purchasedAt: data.purchasedAt.present
          ? data.purchasedAt.value
          : this.purchasedAt,
      restoredAt: data.restoredAt.present
          ? data.restoredAt.value
          : this.restoredAt,
      lastValidatedAt: data.lastValidatedAt.present
          ? data.lastValidatedAt.value
          : this.lastValidatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseEntitlement(')
          ..write('productId: $productId, ')
          ..write('entitlementType: $entitlementType, ')
          ..write('isActive: $isActive, ')
          ..write('sourceStore: $sourceStore, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('restoredAt: $restoredAt, ')
          ..write('lastValidatedAt: $lastValidatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    productId,
    entitlementType,
    isActive,
    sourceStore,
    purchasedAt,
    restoredAt,
    lastValidatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseEntitlement &&
          other.productId == this.productId &&
          other.entitlementType == this.entitlementType &&
          other.isActive == this.isActive &&
          other.sourceStore == this.sourceStore &&
          other.purchasedAt == this.purchasedAt &&
          other.restoredAt == this.restoredAt &&
          other.lastValidatedAt == this.lastValidatedAt);
}

class PurchaseEntitlementsCompanion
    extends UpdateCompanion<PurchaseEntitlement> {
  final Value<String> productId;
  final Value<String> entitlementType;
  final Value<bool> isActive;
  final Value<String?> sourceStore;
  final Value<DateTime?> purchasedAt;
  final Value<DateTime?> restoredAt;
  final Value<DateTime?> lastValidatedAt;
  final Value<int> rowid;
  const PurchaseEntitlementsCompanion({
    this.productId = const Value.absent(),
    this.entitlementType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sourceStore = const Value.absent(),
    this.purchasedAt = const Value.absent(),
    this.restoredAt = const Value.absent(),
    this.lastValidatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseEntitlementsCompanion.insert({
    required String productId,
    required String entitlementType,
    this.isActive = const Value.absent(),
    this.sourceStore = const Value.absent(),
    this.purchasedAt = const Value.absent(),
    this.restoredAt = const Value.absent(),
    this.lastValidatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       entitlementType = Value(entitlementType);
  static Insertable<PurchaseEntitlement> custom({
    Expression<String>? productId,
    Expression<String>? entitlementType,
    Expression<bool>? isActive,
    Expression<String>? sourceStore,
    Expression<DateTime>? purchasedAt,
    Expression<DateTime>? restoredAt,
    Expression<DateTime>? lastValidatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (entitlementType != null) 'entitlement_type': entitlementType,
      if (isActive != null) 'is_active': isActive,
      if (sourceStore != null) 'source_store': sourceStore,
      if (purchasedAt != null) 'purchased_at': purchasedAt,
      if (restoredAt != null) 'restored_at': restoredAt,
      if (lastValidatedAt != null) 'last_validated_at': lastValidatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseEntitlementsCompanion copyWith({
    Value<String>? productId,
    Value<String>? entitlementType,
    Value<bool>? isActive,
    Value<String?>? sourceStore,
    Value<DateTime?>? purchasedAt,
    Value<DateTime?>? restoredAt,
    Value<DateTime?>? lastValidatedAt,
    Value<int>? rowid,
  }) {
    return PurchaseEntitlementsCompanion(
      productId: productId ?? this.productId,
      entitlementType: entitlementType ?? this.entitlementType,
      isActive: isActive ?? this.isActive,
      sourceStore: sourceStore ?? this.sourceStore,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      restoredAt: restoredAt ?? this.restoredAt,
      lastValidatedAt: lastValidatedAt ?? this.lastValidatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (entitlementType.present) {
      map['entitlement_type'] = Variable<String>(entitlementType.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sourceStore.present) {
      map['source_store'] = Variable<String>(sourceStore.value);
    }
    if (purchasedAt.present) {
      map['purchased_at'] = Variable<DateTime>(purchasedAt.value);
    }
    if (restoredAt.present) {
      map['restored_at'] = Variable<DateTime>(restoredAt.value);
    }
    if (lastValidatedAt.present) {
      map['last_validated_at'] = Variable<DateTime>(lastValidatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseEntitlementsCompanion(')
          ..write('productId: $productId, ')
          ..write('entitlementType: $entitlementType, ')
          ..write('isActive: $isActive, ')
          ..write('sourceStore: $sourceStore, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('restoredAt: $restoredAt, ')
          ..write('lastValidatedAt: $lastValidatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GameSessionsTable gameSessions = $GameSessionsTable(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $RoundsTable rounds = $RoundsTable(this);
  late final $VotesTable votes = $VotesTable(this);
  late final $ScoreChangesTable scoreChanges = $ScoreChangesTable(this);
  late final $PurchaseEntitlementsTable purchaseEntitlements =
      $PurchaseEntitlementsTable(this);
  late final SessionDao sessionDao = SessionDao(this as AppDatabase);
  late final RoundDao roundDao = RoundDao(this as AppDatabase);
  late final PurchaseDao purchaseDao = PurchaseDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gameSessions,
    players,
    rounds,
    votes,
    scoreChanges,
    purchaseEntitlements,
  ];
}

typedef $$GameSessionsTableCreateCompanionBuilder =
    GameSessionsCompanion Function({
      required String id,
      Value<String> title,
      required GameStatus status,
      required TargetType targetType,
      Value<int?> targetScore,
      Value<bool> continuePastTargetEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> currentStorytellerSeat,
      Value<int> roundCount,
      Value<int> rowid,
    });
typedef $$GameSessionsTableUpdateCompanionBuilder =
    GameSessionsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<GameStatus> status,
      Value<TargetType> targetType,
      Value<int?> targetScore,
      Value<bool> continuePastTargetEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> currentStorytellerSeat,
      Value<int> roundCount,
      Value<int> rowid,
    });

final class $$GameSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession> {
  $$GameSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayersTable, List<Player>> _playersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.players,
    aliasName: $_aliasNameGenerator(db.gameSessions.id, db.players.sessionId),
  );

  $$PlayersTableProcessedTableManager get playersRefs {
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_playersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoundsTable, List<Round>> _roundsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rounds,
    aliasName: $_aliasNameGenerator(db.gameSessions.id, db.rounds.sessionId),
  );

  $$RoundsTableProcessedTableManager get roundsRefs {
    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roundsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GameSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GameStatus, GameStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TargetType, TargetType, int> get targetType =>
      $composableBuilder(
        column: $table.targetType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get targetScore => $composableBuilder(
    column: $table.targetScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get continuePastTargetEnabled => $composableBuilder(
    column: $table.continuePastTargetEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStorytellerSeat => $composableBuilder(
    column: $table.currentStorytellerSeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundCount => $composableBuilder(
    column: $table.roundCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playersRefs(
    Expression<bool> Function($$PlayersTableFilterComposer f) f,
  ) {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> roundsRefs(
    Expression<bool> Function($$RoundsTableFilterComposer f) f,
  ) {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetScore => $composableBuilder(
    column: $table.targetScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get continuePastTargetEnabled => $composableBuilder(
    column: $table.continuePastTargetEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStorytellerSeat => $composableBuilder(
    column: $table.currentStorytellerSeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundCount => $composableBuilder(
    column: $table.roundCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GameStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TargetType, int> get targetType =>
      $composableBuilder(
        column: $table.targetType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get targetScore => $composableBuilder(
    column: $table.targetScore,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get continuePastTargetEnabled => $composableBuilder(
    column: $table.continuePastTargetEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get currentStorytellerSeat => $composableBuilder(
    column: $table.currentStorytellerSeat,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundCount => $composableBuilder(
    column: $table.roundCount,
    builder: (column) => column,
  );

  Expression<T> playersRefs<T extends Object>(
    Expression<T> Function($$PlayersTableAnnotationComposer a) f,
  ) {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> roundsRefs<T extends Object>(
    Expression<T> Function($$RoundsTableAnnotationComposer a) f,
  ) {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GameSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSessionsTable,
          GameSession,
          $$GameSessionsTableFilterComposer,
          $$GameSessionsTableOrderingComposer,
          $$GameSessionsTableAnnotationComposer,
          $$GameSessionsTableCreateCompanionBuilder,
          $$GameSessionsTableUpdateCompanionBuilder,
          (GameSession, $$GameSessionsTableReferences),
          GameSession,
          PrefetchHooks Function({bool playersRefs, bool roundsRefs})
        > {
  $$GameSessionsTableTableManager(_$AppDatabase db, $GameSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<GameStatus> status = const Value.absent(),
                Value<TargetType> targetType = const Value.absent(),
                Value<int?> targetScore = const Value.absent(),
                Value<bool> continuePastTargetEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> currentStorytellerSeat = const Value.absent(),
                Value<int> roundCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSessionsCompanion(
                id: id,
                title: title,
                status: status,
                targetType: targetType,
                targetScore: targetScore,
                continuePastTargetEnabled: continuePastTargetEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                currentStorytellerSeat: currentStorytellerSeat,
                roundCount: roundCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> title = const Value.absent(),
                required GameStatus status,
                required TargetType targetType,
                Value<int?> targetScore = const Value.absent(),
                Value<bool> continuePastTargetEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> currentStorytellerSeat = const Value.absent(),
                Value<int> roundCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSessionsCompanion.insert(
                id: id,
                title: title,
                status: status,
                targetType: targetType,
                targetScore: targetScore,
                continuePastTargetEnabled: continuePastTargetEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                currentStorytellerSeat: currentStorytellerSeat,
                roundCount: roundCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GameSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playersRefs = false, roundsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playersRefs) db.players,
                if (roundsRefs) db.rounds,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playersRefs)
                    await $_getPrefetchedData<
                      GameSession,
                      $GameSessionsTable,
                      Player
                    >(
                      currentTable: table,
                      referencedTable: $$GameSessionsTableReferences
                          ._playersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GameSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).playersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                  if (roundsRefs)
                    await $_getPrefetchedData<
                      GameSession,
                      $GameSessionsTable,
                      Round
                    >(
                      currentTable: table,
                      referencedTable: $$GameSessionsTableReferences
                          ._roundsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GameSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).roundsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GameSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSessionsTable,
      GameSession,
      $$GameSessionsTableFilterComposer,
      $$GameSessionsTableOrderingComposer,
      $$GameSessionsTableAnnotationComposer,
      $$GameSessionsTableCreateCompanionBuilder,
      $$GameSessionsTableUpdateCompanionBuilder,
      (GameSession, $$GameSessionsTableReferences),
      GameSession,
      PrefetchHooks Function({bool playersRefs, bool roundsRefs})
    >;
typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({
      required String id,
      required String sessionId,
      required String name,
      required int seatOrder,
      required String colorKey,
      Value<String> avatarStyle,
      Value<int> currentScore,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> name,
      Value<int> seatOrder,
      Value<String> colorKey,
      Value<String> avatarStyle,
      Value<int> currentScore,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PlayersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayersTable, Player> {
  $$PlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GameSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.gameSessions.createAlias(
        $_aliasNameGenerator(db.players.sessionId, db.gameSessions.id),
      );

  $$GameSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$GameSessionsTableTableManager(
      $_db,
      $_db.gameSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RoundsTable, List<Round>> _roundsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rounds,
    aliasName: $_aliasNameGenerator(
      db.players.id,
      db.rounds.storytellerPlayerId,
    ),
  );

  $$RoundsTableProcessedTableManager get roundsRefs {
    final manager = $$RoundsTableTableManager($_db, $_db.rounds).filter(
      (f) => f.storytellerPlayerId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_roundsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScoreChangesTable, List<ScoreChange>>
  _scoreChangesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scoreChanges,
    aliasName: $_aliasNameGenerator(db.players.id, db.scoreChanges.playerId),
  );

  $$ScoreChangesTableProcessedTableManager get scoreChangesRefs {
    final manager = $$ScoreChangesTableTableManager(
      $_db,
      $_db.scoreChanges,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scoreChangesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seatOrder => $composableBuilder(
    column: $table.seatOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarStyle => $composableBuilder(
    column: $table.avatarStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentScore => $composableBuilder(
    column: $table.currentScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GameSessionsTableFilterComposer get sessionId {
    final $$GameSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.gameSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSessionsTableFilterComposer(
            $db: $db,
            $table: $db.gameSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> roundsRefs(
    Expression<bool> Function($$RoundsTableFilterComposer f) f,
  ) {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.storytellerPlayerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scoreChangesRefs(
    Expression<bool> Function($$ScoreChangesTableFilterComposer f) f,
  ) {
    final $$ScoreChangesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreChanges,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreChangesTableFilterComposer(
            $db: $db,
            $table: $db.scoreChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seatOrder => $composableBuilder(
    column: $table.seatOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarStyle => $composableBuilder(
    column: $table.avatarStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentScore => $composableBuilder(
    column: $table.currentScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameSessionsTableOrderingComposer get sessionId {
    final $$GameSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.gameSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.gameSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get seatOrder =>
      $composableBuilder(column: $table.seatOrder, builder: (column) => column);

  GeneratedColumn<String> get colorKey =>
      $composableBuilder(column: $table.colorKey, builder: (column) => column);

  GeneratedColumn<String> get avatarStyle => $composableBuilder(
    column: $table.avatarStyle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentScore => $composableBuilder(
    column: $table.currentScore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GameSessionsTableAnnotationComposer get sessionId {
    final $$GameSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.gameSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.gameSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> roundsRefs<T extends Object>(
    Expression<T> Function($$RoundsTableAnnotationComposer a) f,
  ) {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.storytellerPlayerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scoreChangesRefs<T extends Object>(
    Expression<T> Function($$ScoreChangesTableAnnotationComposer a) f,
  ) {
    final $$ScoreChangesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreChanges,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreChangesTableAnnotationComposer(
            $db: $db,
            $table: $db.scoreChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, $$PlayersTableReferences),
          Player,
          PrefetchHooks Function({
            bool sessionId,
            bool roundsRefs,
            bool scoreChangesRefs,
          })
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> seatOrder = const Value.absent(),
                Value<String> colorKey = const Value.absent(),
                Value<String> avatarStyle = const Value.absent(),
                Value<int> currentScore = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion(
                id: id,
                sessionId: sessionId,
                name: name,
                seatOrder: seatOrder,
                colorKey: colorKey,
                avatarStyle: avatarStyle,
                currentScore: currentScore,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String name,
                required int seatOrder,
                required String colorKey,
                Value<String> avatarStyle = const Value.absent(),
                Value<int> currentScore = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                sessionId: sessionId,
                name: name,
                seatOrder: seatOrder,
                colorKey: colorKey,
                avatarStyle: avatarStyle,
                currentScore: currentScore,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                roundsRefs = false,
                scoreChangesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (roundsRefs) db.rounds,
                    if (scoreChangesRefs) db.scoreChanges,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable: $$PlayersTableReferences
                                        ._sessionIdTable(db),
                                    referencedColumn: $$PlayersTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (roundsRefs)
                        await $_getPrefetchedData<Player, $PlayersTable, Round>(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._roundsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).roundsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.storytellerPlayerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scoreChangesRefs)
                        await $_getPrefetchedData<
                          Player,
                          $PlayersTable,
                          ScoreChange
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._scoreChangesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).scoreChangesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.playerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, $$PlayersTableReferences),
      Player,
      PrefetchHooks Function({
        bool sessionId,
        bool roundsRefs,
        bool scoreChangesRefs,
      })
    >;
typedef $$RoundsTableCreateCompanionBuilder =
    RoundsCompanion Function({
      required String id,
      required String sessionId,
      required int roundNumber,
      required String storytellerPlayerId,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<DateTime?> editedAt,
      Value<int> rowid,
    });
typedef $$RoundsTableUpdateCompanionBuilder =
    RoundsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> roundNumber,
      Value<String> storytellerPlayerId,
      Value<String> note,
      Value<DateTime> createdAt,
      Value<DateTime?> editedAt,
      Value<int> rowid,
    });

final class $$RoundsTableReferences
    extends BaseReferences<_$AppDatabase, $RoundsTable, Round> {
  $$RoundsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GameSessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.gameSessions.createAlias(
        $_aliasNameGenerator(db.rounds.sessionId, db.gameSessions.id),
      );

  $$GameSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$GameSessionsTableTableManager(
      $_db,
      $_db.gameSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _storytellerPlayerIdTable(_$AppDatabase db) =>
      db.players.createAlias(
        $_aliasNameGenerator(db.rounds.storytellerPlayerId, db.players.id),
      );

  $$PlayersTableProcessedTableManager get storytellerPlayerId {
    final $_column = $_itemColumn<String>('storyteller_player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_storytellerPlayerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VotesTable, List<Vote>> _votesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.votes,
    aliasName: $_aliasNameGenerator(db.rounds.id, db.votes.roundId),
  );

  $$VotesTableProcessedTableManager get votesRefs {
    final manager = $$VotesTableTableManager(
      $_db,
      $_db.votes,
    ).filter((f) => f.roundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_votesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScoreChangesTable, List<ScoreChange>>
  _scoreChangesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scoreChanges,
    aliasName: $_aliasNameGenerator(db.rounds.id, db.scoreChanges.roundId),
  );

  $$ScoreChangesTableProcessedTableManager get scoreChangesRefs {
    final manager = $$ScoreChangesTableTableManager(
      $_db,
      $_db.scoreChanges,
    ).filter((f) => f.roundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scoreChangesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoundsTableFilterComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GameSessionsTableFilterComposer get sessionId {
    final $$GameSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.gameSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSessionsTableFilterComposer(
            $db: $db,
            $table: $db.gameSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get storytellerPlayerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storytellerPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> votesRefs(
    Expression<bool> Function($$VotesTableFilterComposer f) f,
  ) {
    final $$VotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.votes,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VotesTableFilterComposer(
            $db: $db,
            $table: $db.votes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scoreChangesRefs(
    Expression<bool> Function($$ScoreChangesTableFilterComposer f) f,
  ) {
    final $$ScoreChangesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreChanges,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreChangesTableFilterComposer(
            $db: $db,
            $table: $db.scoreChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GameSessionsTableOrderingComposer get sessionId {
    final $$GameSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.gameSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.gameSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get storytellerPlayerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storytellerPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  $$GameSessionsTableAnnotationComposer get sessionId {
    final $$GameSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.gameSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GameSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.gameSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get storytellerPlayerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storytellerPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> votesRefs<T extends Object>(
    Expression<T> Function($$VotesTableAnnotationComposer a) f,
  ) {
    final $$VotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.votes,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VotesTableAnnotationComposer(
            $db: $db,
            $table: $db.votes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scoreChangesRefs<T extends Object>(
    Expression<T> Function($$ScoreChangesTableAnnotationComposer a) f,
  ) {
    final $$ScoreChangesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scoreChanges,
      getReferencedColumn: (t) => t.roundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScoreChangesTableAnnotationComposer(
            $db: $db,
            $table: $db.scoreChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoundsTable,
          Round,
          $$RoundsTableFilterComposer,
          $$RoundsTableOrderingComposer,
          $$RoundsTableAnnotationComposer,
          $$RoundsTableCreateCompanionBuilder,
          $$RoundsTableUpdateCompanionBuilder,
          (Round, $$RoundsTableReferences),
          Round,
          PrefetchHooks Function({
            bool sessionId,
            bool storytellerPlayerId,
            bool votesRefs,
            bool scoreChangesRefs,
          })
        > {
  $$RoundsTableTableManager(_$AppDatabase db, $RoundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> roundNumber = const Value.absent(),
                Value<String> storytellerPlayerId = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoundsCompanion(
                id: id,
                sessionId: sessionId,
                roundNumber: roundNumber,
                storytellerPlayerId: storytellerPlayerId,
                note: note,
                createdAt: createdAt,
                editedAt: editedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int roundNumber,
                required String storytellerPlayerId,
                Value<String> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoundsCompanion.insert(
                id: id,
                sessionId: sessionId,
                roundNumber: roundNumber,
                storytellerPlayerId: storytellerPlayerId,
                note: note,
                createdAt: createdAt,
                editedAt: editedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$RoundsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionId = false,
                storytellerPlayerId = false,
                votesRefs = false,
                scoreChangesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (votesRefs) db.votes,
                    if (scoreChangesRefs) db.scoreChanges,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sessionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sessionId,
                                    referencedTable: $$RoundsTableReferences
                                        ._sessionIdTable(db),
                                    referencedColumn: $$RoundsTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (storytellerPlayerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.storytellerPlayerId,
                                    referencedTable: $$RoundsTableReferences
                                        ._storytellerPlayerIdTable(db),
                                    referencedColumn: $$RoundsTableReferences
                                        ._storytellerPlayerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (votesRefs)
                        await $_getPrefetchedData<Round, $RoundsTable, Vote>(
                          currentTable: table,
                          referencedTable: $$RoundsTableReferences
                              ._votesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoundsTableReferences(db, table, p0).votesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roundId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (scoreChangesRefs)
                        await $_getPrefetchedData<
                          Round,
                          $RoundsTable,
                          ScoreChange
                        >(
                          currentTable: table,
                          referencedTable: $$RoundsTableReferences
                              ._scoreChangesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoundsTableReferences(
                                db,
                                table,
                                p0,
                              ).scoreChangesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.roundId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoundsTable,
      Round,
      $$RoundsTableFilterComposer,
      $$RoundsTableOrderingComposer,
      $$RoundsTableAnnotationComposer,
      $$RoundsTableCreateCompanionBuilder,
      $$RoundsTableUpdateCompanionBuilder,
      (Round, $$RoundsTableReferences),
      Round,
      PrefetchHooks Function({
        bool sessionId,
        bool storytellerPlayerId,
        bool votesRefs,
        bool scoreChangesRefs,
      })
    >;
typedef $$VotesTableCreateCompanionBuilder =
    VotesCompanion Function({
      required String id,
      required String roundId,
      required String voterPlayerId,
      required String votedForPlayerId,
      Value<int> rowid,
    });
typedef $$VotesTableUpdateCompanionBuilder =
    VotesCompanion Function({
      Value<String> id,
      Value<String> roundId,
      Value<String> voterPlayerId,
      Value<String> votedForPlayerId,
      Value<int> rowid,
    });

final class $$VotesTableReferences
    extends BaseReferences<_$AppDatabase, $VotesTable, Vote> {
  $$VotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoundsTable _roundIdTable(_$AppDatabase db) => db.rounds.createAlias(
    $_aliasNameGenerator(db.votes.roundId, db.rounds.id),
  );

  $$RoundsTableProcessedTableManager get roundId {
    final $_column = $_itemColumn<String>('round_id')!;

    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _voterPlayerIdTable(_$AppDatabase db) => db.players
      .createAlias($_aliasNameGenerator(db.votes.voterPlayerId, db.players.id));

  $$PlayersTableProcessedTableManager get voterPlayerId {
    final $_column = $_itemColumn<String>('voter_player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_voterPlayerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _votedForPlayerIdTable(_$AppDatabase db) =>
      db.players.createAlias(
        $_aliasNameGenerator(db.votes.votedForPlayerId, db.players.id),
      );

  $$PlayersTableProcessedTableManager get votedForPlayerId {
    final $_column = $_itemColumn<String>('voted_for_player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_votedForPlayerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VotesTableFilterComposer extends Composer<_$AppDatabase, $VotesTable> {
  $$VotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get voterPlayerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voterPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get votedForPlayerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.votedForPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VotesTableOrderingComposer
    extends Composer<_$AppDatabase, $VotesTable> {
  $$VotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableOrderingComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get voterPlayerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voterPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get votedForPlayerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.votedForPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VotesTable> {
  $$VotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$RoundsTableAnnotationComposer get roundId {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get voterPlayerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.voterPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get votedForPlayerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.votedForPlayerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VotesTable,
          Vote,
          $$VotesTableFilterComposer,
          $$VotesTableOrderingComposer,
          $$VotesTableAnnotationComposer,
          $$VotesTableCreateCompanionBuilder,
          $$VotesTableUpdateCompanionBuilder,
          (Vote, $$VotesTableReferences),
          Vote,
          PrefetchHooks Function({
            bool roundId,
            bool voterPlayerId,
            bool votedForPlayerId,
          })
        > {
  $$VotesTableTableManager(_$AppDatabase db, $VotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roundId = const Value.absent(),
                Value<String> voterPlayerId = const Value.absent(),
                Value<String> votedForPlayerId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VotesCompanion(
                id: id,
                roundId: roundId,
                voterPlayerId: voterPlayerId,
                votedForPlayerId: votedForPlayerId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roundId,
                required String voterPlayerId,
                required String votedForPlayerId,
                Value<int> rowid = const Value.absent(),
              }) => VotesCompanion.insert(
                id: id,
                roundId: roundId,
                voterPlayerId: voterPlayerId,
                votedForPlayerId: votedForPlayerId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                roundId = false,
                voterPlayerId = false,
                votedForPlayerId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (roundId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.roundId,
                                    referencedTable: $$VotesTableReferences
                                        ._roundIdTable(db),
                                    referencedColumn: $$VotesTableReferences
                                        ._roundIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (voterPlayerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.voterPlayerId,
                                    referencedTable: $$VotesTableReferences
                                        ._voterPlayerIdTable(db),
                                    referencedColumn: $$VotesTableReferences
                                        ._voterPlayerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (votedForPlayerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.votedForPlayerId,
                                    referencedTable: $$VotesTableReferences
                                        ._votedForPlayerIdTable(db),
                                    referencedColumn: $$VotesTableReferences
                                        ._votedForPlayerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$VotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VotesTable,
      Vote,
      $$VotesTableFilterComposer,
      $$VotesTableOrderingComposer,
      $$VotesTableAnnotationComposer,
      $$VotesTableCreateCompanionBuilder,
      $$VotesTableUpdateCompanionBuilder,
      (Vote, $$VotesTableReferences),
      Vote,
      PrefetchHooks Function({
        bool roundId,
        bool voterPlayerId,
        bool votedForPlayerId,
      })
    >;
typedef $$ScoreChangesTableCreateCompanionBuilder =
    ScoreChangesCompanion Function({
      required String id,
      required String roundId,
      required String playerId,
      required int delta,
      required String reasonCode,
      required String reasonLabel,
      Value<int> rowid,
    });
typedef $$ScoreChangesTableUpdateCompanionBuilder =
    ScoreChangesCompanion Function({
      Value<String> id,
      Value<String> roundId,
      Value<String> playerId,
      Value<int> delta,
      Value<String> reasonCode,
      Value<String> reasonLabel,
      Value<int> rowid,
    });

final class $$ScoreChangesTableReferences
    extends BaseReferences<_$AppDatabase, $ScoreChangesTable, ScoreChange> {
  $$ScoreChangesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoundsTable _roundIdTable(_$AppDatabase db) => db.rounds.createAlias(
    $_aliasNameGenerator(db.scoreChanges.roundId, db.rounds.id),
  );

  $$RoundsTableProcessedTableManager get roundId {
    final $_column = $_itemColumn<String>('round_id')!;

    final manager = $$RoundsTableTableManager(
      $_db,
      $_db.rounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias(
        $_aliasNameGenerator(db.scoreChanges.playerId, db.players.id),
      );

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<String>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScoreChangesTableFilterComposer
    extends Composer<_$AppDatabase, $ScoreChangesTable> {
  $$ScoreChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonLabel => $composableBuilder(
    column: $table.reasonLabel,
    builder: (column) => ColumnFilters(column),
  );

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableFilterComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScoreChangesTable> {
  $$ScoreChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get delta => $composableBuilder(
    column: $table.delta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonLabel => $composableBuilder(
    column: $table.reasonLabel,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableOrderingComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScoreChangesTable> {
  $$ScoreChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get delta =>
      $composableBuilder(column: $table.delta, builder: (column) => column);

  GeneratedColumn<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reasonLabel => $composableBuilder(
    column: $table.reasonLabel,
    builder: (column) => column,
  );

  $$RoundsTableAnnotationComposer get roundId {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roundId,
      referencedTable: $db.rounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.rounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScoreChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScoreChangesTable,
          ScoreChange,
          $$ScoreChangesTableFilterComposer,
          $$ScoreChangesTableOrderingComposer,
          $$ScoreChangesTableAnnotationComposer,
          $$ScoreChangesTableCreateCompanionBuilder,
          $$ScoreChangesTableUpdateCompanionBuilder,
          (ScoreChange, $$ScoreChangesTableReferences),
          ScoreChange,
          PrefetchHooks Function({bool roundId, bool playerId})
        > {
  $$ScoreChangesTableTableManager(_$AppDatabase db, $ScoreChangesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScoreChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScoreChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScoreChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roundId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<int> delta = const Value.absent(),
                Value<String> reasonCode = const Value.absent(),
                Value<String> reasonLabel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScoreChangesCompanion(
                id: id,
                roundId: roundId,
                playerId: playerId,
                delta: delta,
                reasonCode: reasonCode,
                reasonLabel: reasonLabel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roundId,
                required String playerId,
                required int delta,
                required String reasonCode,
                required String reasonLabel,
                Value<int> rowid = const Value.absent(),
              }) => ScoreChangesCompanion.insert(
                id: id,
                roundId: roundId,
                playerId: playerId,
                delta: delta,
                reasonCode: reasonCode,
                reasonLabel: reasonLabel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScoreChangesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roundId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (roundId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.roundId,
                                referencedTable: $$ScoreChangesTableReferences
                                    ._roundIdTable(db),
                                referencedColumn: $$ScoreChangesTableReferences
                                    ._roundIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (playerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playerId,
                                referencedTable: $$ScoreChangesTableReferences
                                    ._playerIdTable(db),
                                referencedColumn: $$ScoreChangesTableReferences
                                    ._playerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScoreChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScoreChangesTable,
      ScoreChange,
      $$ScoreChangesTableFilterComposer,
      $$ScoreChangesTableOrderingComposer,
      $$ScoreChangesTableAnnotationComposer,
      $$ScoreChangesTableCreateCompanionBuilder,
      $$ScoreChangesTableUpdateCompanionBuilder,
      (ScoreChange, $$ScoreChangesTableReferences),
      ScoreChange,
      PrefetchHooks Function({bool roundId, bool playerId})
    >;
typedef $$PurchaseEntitlementsTableCreateCompanionBuilder =
    PurchaseEntitlementsCompanion Function({
      required String productId,
      required String entitlementType,
      Value<bool> isActive,
      Value<String?> sourceStore,
      Value<DateTime?> purchasedAt,
      Value<DateTime?> restoredAt,
      Value<DateTime?> lastValidatedAt,
      Value<int> rowid,
    });
typedef $$PurchaseEntitlementsTableUpdateCompanionBuilder =
    PurchaseEntitlementsCompanion Function({
      Value<String> productId,
      Value<String> entitlementType,
      Value<bool> isActive,
      Value<String?> sourceStore,
      Value<DateTime?> purchasedAt,
      Value<DateTime?> restoredAt,
      Value<DateTime?> lastValidatedAt,
      Value<int> rowid,
    });

class $$PurchaseEntitlementsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseEntitlementsTable> {
  $$PurchaseEntitlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitlementType => $composableBuilder(
    column: $table.entitlementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceStore => $composableBuilder(
    column: $table.sourceStore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get restoredAt => $composableBuilder(
    column: $table.restoredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastValidatedAt => $composableBuilder(
    column: $table.lastValidatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurchaseEntitlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseEntitlementsTable> {
  $$PurchaseEntitlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitlementType => $composableBuilder(
    column: $table.entitlementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceStore => $composableBuilder(
    column: $table.sourceStore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get restoredAt => $composableBuilder(
    column: $table.restoredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastValidatedAt => $composableBuilder(
    column: $table.lastValidatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchaseEntitlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseEntitlementsTable> {
  $$PurchaseEntitlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get entitlementType => $composableBuilder(
    column: $table.entitlementType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get sourceStore => $composableBuilder(
    column: $table.sourceStore,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get restoredAt => $composableBuilder(
    column: $table.restoredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastValidatedAt => $composableBuilder(
    column: $table.lastValidatedAt,
    builder: (column) => column,
  );
}

class $$PurchaseEntitlementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseEntitlementsTable,
          PurchaseEntitlement,
          $$PurchaseEntitlementsTableFilterComposer,
          $$PurchaseEntitlementsTableOrderingComposer,
          $$PurchaseEntitlementsTableAnnotationComposer,
          $$PurchaseEntitlementsTableCreateCompanionBuilder,
          $$PurchaseEntitlementsTableUpdateCompanionBuilder,
          (
            PurchaseEntitlement,
            BaseReferences<
              _$AppDatabase,
              $PurchaseEntitlementsTable,
              PurchaseEntitlement
            >,
          ),
          PurchaseEntitlement,
          PrefetchHooks Function()
        > {
  $$PurchaseEntitlementsTableTableManager(
    _$AppDatabase db,
    $PurchaseEntitlementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseEntitlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseEntitlementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PurchaseEntitlementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> productId = const Value.absent(),
                Value<String> entitlementType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> sourceStore = const Value.absent(),
                Value<DateTime?> purchasedAt = const Value.absent(),
                Value<DateTime?> restoredAt = const Value.absent(),
                Value<DateTime?> lastValidatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseEntitlementsCompanion(
                productId: productId,
                entitlementType: entitlementType,
                isActive: isActive,
                sourceStore: sourceStore,
                purchasedAt: purchasedAt,
                restoredAt: restoredAt,
                lastValidatedAt: lastValidatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productId,
                required String entitlementType,
                Value<bool> isActive = const Value.absent(),
                Value<String?> sourceStore = const Value.absent(),
                Value<DateTime?> purchasedAt = const Value.absent(),
                Value<DateTime?> restoredAt = const Value.absent(),
                Value<DateTime?> lastValidatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseEntitlementsCompanion.insert(
                productId: productId,
                entitlementType: entitlementType,
                isActive: isActive,
                sourceStore: sourceStore,
                purchasedAt: purchasedAt,
                restoredAt: restoredAt,
                lastValidatedAt: lastValidatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchaseEntitlementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseEntitlementsTable,
      PurchaseEntitlement,
      $$PurchaseEntitlementsTableFilterComposer,
      $$PurchaseEntitlementsTableOrderingComposer,
      $$PurchaseEntitlementsTableAnnotationComposer,
      $$PurchaseEntitlementsTableCreateCompanionBuilder,
      $$PurchaseEntitlementsTableUpdateCompanionBuilder,
      (
        PurchaseEntitlement,
        BaseReferences<
          _$AppDatabase,
          $PurchaseEntitlementsTable,
          PurchaseEntitlement
        >,
      ),
      PurchaseEntitlement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GameSessionsTableTableManager get gameSessions =>
      $$GameSessionsTableTableManager(_db, _db.gameSessions);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$RoundsTableTableManager get rounds =>
      $$RoundsTableTableManager(_db, _db.rounds);
  $$VotesTableTableManager get votes =>
      $$VotesTableTableManager(_db, _db.votes);
  $$ScoreChangesTableTableManager get scoreChanges =>
      $$ScoreChangesTableTableManager(_db, _db.scoreChanges);
  $$PurchaseEntitlementsTableTableManager get purchaseEntitlements =>
      $$PurchaseEntitlementsTableTableManager(_db, _db.purchaseEntitlements);
}
