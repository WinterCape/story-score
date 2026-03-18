# Premium Features Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the 3 remaining Supporter Pack features: Player Presets, Advanced Stats, and Premium Celebrations.

**Architecture:** Three independent feature modules built on the existing Riverpod + Drift stack. Pure Dart domain classes for all business logic (StatsCalculator, MilestoneDetector, CelebrationEngine). Flutter UI layer reads domain output and renders effects. Database schema v1 → v2 with additive-only migration.

**Tech Stack:** Flutter/Dart, Riverpod, Drift, fl_chart (new), audioplayers (new), CustomPainter for particles.

**Spec:** `docs/superpowers/specs/2026-03-18-premium-features-design.md`

---

## File Map

### New Files

**Domain layer (pure Dart, zero Flutter imports):**
- `lib/domain/stats/stats_models.dart` — SessionStats, PlayerAllTimeStats, HeadToHeadRecord, LeaderboardEntry, CompletedGameData, RoundData, PlayerScore
- `lib/domain/stats/stats_calculator.dart` — computeSessionStats, computePlayerAllTimeStats, computeHeadToHead, computeLeaderboard
- `lib/domain/stats/milestone_detector.dart` — Milestone enum, MilestoneDetector.detectMilestones
- `lib/domain/celebrations/celebration_models.dart` — CelebrationEffect enum, CelebrationResult
- `lib/domain/celebrations/celebration_engine.dart` — CelebrationEngine.computeEffects

**Database layer:**
- `lib/data/database/tables/player_presets.dart` — PlayerPresets Drift table
- `lib/data/database/tables/preset_players.dart` — PresetPlayers Drift table
- `lib/data/database/daos/preset_dao.dart` — PresetDao CRUD

**Feature: Presets**
- `lib/features/presets/providers/preset_providers.dart` — presetsProvider, favoritePlayersProvider, savePresetProvider, loadPresetProvider, quickStartProvider
- `lib/features/presets/screens/preset_management_screen.dart` — list/edit/delete presets
- `lib/features/presets/widgets/preset_list_tile.dart` — preset card with color dots
- `lib/features/presets/widgets/favorite_player_chips.dart` — quick-add chips

**Feature: Stats**
- `lib/features/stats/providers/stats_providers.dart` — StatsService, sessionStatsProvider, allTimeStatsProvider, leaderboardProvider
- `lib/features/stats/screens/stats_screen.dart` — cross-session stats + charts
- `lib/features/stats/widgets/stat_card.dart` — reusable stat tile
- `lib/features/stats/widgets/score_progression_chart.dart` — fl_chart line chart (per-game)
- `lib/features/stats/widgets/win_rate_bar_chart.dart` — fl_chart bar chart (leaderboard)
- `lib/features/stats/widgets/score_distribution_chart.dart` — fl_chart bar chart (round score frequency)
- `lib/features/stats/widgets/storyteller_success_chart.dart` — fl_chart pie chart (good/bad clue ratio)
- `lib/features/stats/widgets/session_stats_section.dart` — endgame stats section
- `lib/features/stats/widgets/head_to_head_card.dart` — compact H2H record card
- `lib/features/stats/widgets/player_detail_sheet.dart` — bottom sheet with all-time stats + streaks

**Feature: Celebrations**
- `lib/features/celebrations/celebration_controller.dart` — orchestrates effects from engine output
- `lib/features/celebrations/widgets/confetti_overlay.dart` — CustomPainter particle system
- `lib/features/celebrations/widgets/milestone_toast.dart` — animated top banner

**Tests:**
- `test/domain/stats/stats_calculator_test.dart` — unit: all stats + streaks
- `test/domain/stats/milestone_detector_test.dart` — unit: all milestones
- `test/domain/stats/name_normalization_test.dart` — unit: case folding, trimming, Unicode
- `test/domain/celebrations/celebration_engine_test.dart` — unit: effects + reduced motion
- `test/features/presets/preset_integration_test.dart` — integration: save/load/delete + constraints
- `test/features/premium/premium_gating_test.dart` — widget: locked/unlocked states

**Assets:**
- `assets/sounds/chime.mp3` — milestone toast sound (~10KB)
- `assets/sounds/celebration.mp3` — winner fanfare (~30KB)

### Modified Files

- `lib/data/database/app_database.dart` — add tables, DAOs, schema v2, migration
- `lib/app/router/app_router.dart` — add /stats and /settings/presets routes
- `lib/features/home/screens/home_screen.dart` — add Stats icon, Quick Start chip
- `lib/features/game_setup/screens/game_setup_screen.dart` — add Load/Save Preset buttons, favorite chips
- `lib/features/endgame/screens/endgame_screen.dart` — add session stats, premium chart, confetti
- `lib/features/scoreboard/screens/scoreboard_screen.dart` — add milestone toasts, winner glow
- `lib/features/settings/screens/settings_screen.dart` — add Sound Effects toggle, Presets row
- `lib/features/premium/widgets/feature_preview_list.dart` — update descriptions
- `lib/data/settings/app_settings.dart` — add soundEffectsEnabled field
- `lib/data/settings/app_settings_repository.dart` — persist soundEffectsEnabled
- `lib/features/settings/providers/settings_providers.dart` — add soundEffects setter
- `pubspec.yaml` — add fl_chart, audioplayers dependencies

---

## Chunk 1: Database Migration + Player Presets

### Task 1: Add new dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add fl_chart and audioplayers to pubspec.yaml**

Add under `dependencies:`:
```yaml
  # Charts
  fl_chart: ^0.70.2

  # Audio
  audioplayers: ^6.1.0
```

- [ ] **Step 2: Run pub get**

Run: `flutter pub get`
Expected: resolves successfully

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add fl_chart and audioplayers dependencies"
```

---

### Task 2: Database tables + migration

**Files:**
- Create: `lib/data/database/tables/player_presets.dart`
- Create: `lib/data/database/tables/preset_players.dart`
- Modify: `lib/data/database/app_database.dart`

- [ ] **Step 1: Create PlayerPresets table**

```dart
// lib/data/database/tables/player_presets.dart
import 'package:drift/drift.dart';

class PlayerPresets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 2: Create PresetPlayers table**

```dart
// lib/data/database/tables/preset_players.dart
import 'package:drift/drift.dart';
import 'player_presets.dart';

class PresetPlayers extends Table {
  TextColumn get id => text()();
  TextColumn get presetId => text().references(PlayerPresets, #id)();
  TextColumn get name => text()();
  TextColumn get colorKey => text()();
  TextColumn get avatarStyle => text().withDefault(const Constant('initials'))();
  IntColumn get seatOrder => integer()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 3: Update AppDatabase — add tables, DAOs, migrate to v2**

In `app_database.dart`:
- Add imports for new tables
- Add `PlayerPresets` and `PresetPlayers` to `@DriftDatabase(tables: [...])`
- Add `PresetDao` to `daos: [...]`
- Change `schemaVersion => 2`
- Update `migration` to handle v1→v2:

```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      await m.createTable(playerPresets);
      await m.createTable(presetPlayers);
    }
  },
);
```

- [ ] **Step 4: Create PresetDao**

```dart
// lib/data/database/daos/preset_dao.dart
import 'package:drift/drift.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/tables/player_presets.dart';
import 'package:story_score/data/database/tables/preset_players.dart';

part 'preset_dao.g.dart';

@DriftAccessor(tables: [PlayerPresets, PresetPlayers])
class PresetDao extends DatabaseAccessor<AppDatabase> with _$PresetDaoMixin {
  PresetDao(super.db);

  Stream<List<PlayerPreset>> watchAllPresets() {
    return (select(playerPresets)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  Stream<List<PresetPlayer>> watchPlayersForPreset(String presetId) {
    return (select(presetPlayers)
          ..where((t) => t.presetId.equals(presetId))
          ..orderBy([(t) => OrderingTerm.asc(t.seatOrder)]))
        .watch();
  }

  /// Get favorites deduplicated by normalized name, max 10
  Future<List<PresetPlayer>> getFavorites() async {
    final all = await (select(presetPlayers)
          ..where((t) => t.isFavorite.equals(true)))
        .get();
    // Deduplicate by normalized name (case-insensitive, trimmed)
    final seen = <String>{};
    final deduped = <PresetPlayer>[];
    for (final p in all) {
      final key = p.name.trim().toLowerCase();
      if (seen.add(key) && deduped.length < 10) {
        deduped.add(p);
      }
    }
    return deduped;
  }

  Future<int> getPresetCount() async {
    final count = countAll();
    final query = selectOnly(playerPresets)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  static const maxPresets = 20;
  static const minPlayersPerPreset = 3;
  static const maxPlayersPerPreset = 10;

  Future<void> createPreset({
    required String id,
    required String name,
    required List<PresetPlayersCompanion> players,
  }) async {
    // Enforce constraints
    final count = await getPresetCount();
    if (count >= maxPresets) {
      throw StateError('Maximum $maxPresets presets reached');
    }
    if (players.length < minPlayersPerPreset || players.length > maxPlayersPerPreset) {
      throw ArgumentError('Preset must have $minPlayersPerPreset-$maxPlayersPerPreset players');
    }
    return transaction(() async {
      await into(playerPresets).insert(PlayerPresetsCompanion.insert(
        id: id,
        name: name,
      ));
      for (final player in players) {
        await into(presetPlayers).insert(player);
      }
    });
  }

  Future<void> deletePreset(String id) {
    return transaction(() async {
      await (delete(presetPlayers)..where((t) => t.presetId.equals(id))).go();
      await (delete(playerPresets)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> updatePresetName(String id, String name) {
    return (update(playerPresets)..where((t) => t.id.equals(id)))
        .write(PlayerPresetsCompanion(
      name: Value(name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> markUsed(String id) {
    return (update(playerPresets)..where((t) => t.id.equals(id)))
        .write(PlayerPresetsCompanion(
      lastUsedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> toggleFavorite(String playerId, bool isFav) {
    return (update(presetPlayers)..where((t) => t.id.equals(playerId)))
        .write(PresetPlayersCompanion(isFavorite: Value(isFav)));
  }
}
```

- [ ] **Step 5: Run build_runner**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: generates .g.dart files with no errors

- [ ] **Step 6: Run analyze**

Run: `flutter analyze`
Expected: no errors

- [ ] **Step 7: Commit**

```bash
git add lib/data/database/
git commit -m "feat: add player presets tables, DAO, and schema v2 migration"
```

---

### Task 3: Preset providers

**Files:**
- Create: `lib/features/presets/providers/preset_providers.dart`

- [ ] **Step 1: Create preset providers**

```dart
// lib/features/presets/providers/preset_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/app/providers.dart';
import 'package:story_score/core/utils/id_generator.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/daos/preset_dao.dart';
import 'package:story_score/data/database/daos/session_dao.dart';
import 'package:story_score/data/database/tables/preset_players.dart';
import 'package:story_score/data/database/tables/players.dart';
import 'package:story_score/data/database/tables/game_sessions.dart';

final presetDaoProvider = Provider<PresetDao>((ref) {
  return ref.watch(appDatabaseProvider).presetDao;
});

final presetsProvider = StreamProvider<List<PlayerPreset>>((ref) {
  return ref.watch(presetDaoProvider).watchAllPresets();
});

final presetPlayersProvider =
    StreamProvider.family<List<PresetPlayer>, String>((ref, presetId) {
  return ref.watch(presetDaoProvider).watchPlayersForPreset(presetId);
});

final favoritePlayersProvider = FutureProvider<List<PresetPlayer>>((ref) {
  return ref.watch(presetDaoProvider).getFavorites();
});

final presetCountProvider = FutureProvider<int>((ref) {
  return ref.watch(presetDaoProvider).getPresetCount();
});

Future<String> savePreset({
  required PresetDao dao,
  required String name,
  required List<({String name, String colorKey, String avatarStyle, int seatOrder})> players,
}) async {
  final presetId = IdGenerator.newId();
  final companions = players.map((p) => PresetPlayersCompanion.insert(
    id: IdGenerator.newId(),
    presetId: presetId,
    name: p.name,
    colorKey: p.colorKey,
    avatarStyle: p.avatarStyle,
    seatOrder: p.seatOrder,
  )).toList();

  await dao.createPreset(id: presetId, name: name, players: companions);
  return presetId;
}

/// Quick Start: creates a game from the most recently used preset
/// with default 30 target score. Returns the new session ID.
Future<String> quickStart({
  required PresetDao presetDao,
  required SessionDao sessionDao,
  required String presetId,
}) async {
  final players = await (presetDao.watchPlayersForPreset(presetId).first);
  if (players.length < 3) throw StateError('Preset has fewer than 3 players');

  final sessionId = IdGenerator.newId();
  await sessionDao.createSession(
    session: GameSessionsCompanion.insert(
      id: sessionId,
      title: '',
      targetType: TargetType.score,
      continuePastTargetEnabled: false,
      currentStorytellerSeat: 0,
      roundCount: 0,
      targetScore: const Value(30),
    ),
    players: players.map((p) => PlayersCompanion.insert(
      id: IdGenerator.newId(),
      sessionId: sessionId,
      name: p.name,
      seatOrder: p.seatOrder,
      colorKey: p.colorKey,
      avatarStyle: Value(p.avatarStyle),
    )).toList(),
  );

  await presetDao.markUsed(presetId);
  return sessionId;
}
```

- [ ] **Step 2: Run analyze**

Run: `flutter analyze`
Expected: no errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/presets/ lib/app/providers.dart
git commit -m "feat: add preset providers and save/load logic"
```

---

### Task 4: Preset management screen + widgets

**Files:**
- Create: `lib/features/presets/screens/preset_management_screen.dart`
- Create: `lib/features/presets/widgets/preset_list_tile.dart`
- Create: `lib/features/presets/widgets/favorite_player_chips.dart`
- Modify: `lib/app/router/app_router.dart` — add route

- [ ] **Step 1: Create PresetListTile widget**

Shows preset name, player count, color dot preview, swipe-to-delete. Tapping navigates to edit.

- [ ] **Step 2: Create PresetManagementScreen**

ListView of PresetListTile widgets. Premium-gated: if `!isSupporter`, show locked state with CTA. Edit mode: rename preset, reorder/remove players, toggle favorites.

- [ ] **Step 3: Create FavoritePlayerChips widget**

Horizontal scrollable row of chips showing favorited players. Tapping a chip calls `onSelect(name, colorKey, avatarStyle)`.

- [ ] **Step 4: Add route `/settings/presets` to app_router.dart**

```dart
GoRoute(
  path: 'presets',
  builder: (context, state) => const PresetManagementScreen(),
),
```
Nest under the `/settings` route.

- [ ] **Step 5: Run analyze**

Run: `flutter analyze`
Expected: no errors

- [ ] **Step 6: Commit**

```bash
git add lib/features/presets/ lib/app/router/
git commit -m "feat: add preset management screen and widgets"
```

---

### Task 5: Wire presets into game setup + home

**Files:**
- Modify: `lib/features/game_setup/screens/game_setup_screen.dart`
- Modify: `lib/features/home/screens/home_screen.dart`
- Modify: `lib/features/endgame/screens/endgame_screen.dart`
- Modify: `lib/features/settings/screens/settings_screen.dart`

- [ ] **Step 1: Add "Load Preset" and "Save as Preset" to game setup**

Above player list: "Load Preset" button (premium-gated). Below player list or in app bar: "Save as Preset" (shown when 3+ players, premium-gated). Load opens bottom sheet listing presets. Save opens name dialog.

- [ ] **Step 2: Add FavoritePlayerChips to add-player sheet**

If supporter && favorites exist, show chips above the name field. Tapping a chip auto-fills name, color, avatar.

- [ ] **Step 3a: Add Quick Start chip to home screen**

Below the active sessions section, show "Quick Start" `ActionChip` when presets exist and user is supporter. Uses `presetsProvider` to check.

- [ ] **Step 3b: Implement Quick Start tap handler**

Tapping opens a bottom sheet listing saved presets with `PresetListTile` widgets. Selecting one calls `quickStart()` from `preset_providers.dart`, then navigates to `/game/$sessionId/scoreboard` via GoRouter.

> **Note:** `home_screen.dart` is also modified in Task 9 (Stats icon). If using parallel subagents, these tasks must be serialized or merged carefully.

- [ ] **Step 4: Add "Save as Preset" to endgame screen**

OutlinedButton below "Share Results". Premium-gated.

- [ ] **Step 5: Add "Player Presets" row to settings screen**

ListTile navigating to `/settings/presets`. Show lock icon if not supporter.

- [ ] **Step 6: Run analyze and test**

Run: `flutter analyze && flutter test`
Expected: no errors, all tests pass

- [ ] **Step 7: Commit**

```bash
git add lib/features/game_setup/ lib/features/home/ lib/features/endgame/ lib/features/settings/
git commit -m "feat: wire presets into game setup, home, endgame, and settings"
```

---

## Chunk 2: Advanced Score Statistics

### Task 6: Stats domain models + calculator

**Files:**
- Create: `lib/domain/stats/stats_models.dart`
- Create: `lib/domain/stats/stats_calculator.dart`
- Create: `test/domain/stats/stats_calculator_test.dart`

- [ ] **Step 1: Write stats_models.dart**

Pure Dart data classes:
- `PlayerScore` (name, normalizedName, finalScore, isWinner)
- `RoundData` (roundNumber, storytellerId, votes Map, scoreDeltas Map, hasGoodClue)
- `CompletedGameData` (sessionId, players List<PlayerScore>, rounds List<RoundData>, createdAt)
- `SessionStats` (bestRound, worstRound, guessAccuracy, totalBonusPoints, storytellerSuccessRate, mvpName, mvpScore)
- `PlayerAllTimeStats` (normalizedName, gamesPlayed, wins, winRate, avgScore, bestGameScore, totalPoints, currentWinStreak, longestWinStreak, gamesSinceLastWin)
- `HeadToHeadRecord` (playerA, playerB, winsA, winsB, ties, sharedGames)
- `LeaderboardEntry` (normalizedName, displayName, wins, winRate, gamesPlayed, totalPoints)

Name normalization helper using Unicode NFC:
```dart
import 'package:intl/intl.dart';
String normalizeName(String name) => Intl.canonicalizedLocale(name.trim().toLowerCase());
```
Note: Dart's `String` is UTF-16, `trim().toLowerCase()` handles most cases. For full NFC, use `package:characters` if needed. Test with accented characters (e.g., "José" vs "Jose").

- [ ] **Step 2: Write failing tests for StatsCalculator**

Test cases:
- Session stats with known round data (3 players, 5 rounds)
- Perfect accuracy (all correct guesses)
- Zero accuracy (no correct guesses)
- MVP detection with ties
- All-time stats across 3 completed games
- Head-to-head with 2 players in 5 shared games
- Leaderboard with min 3 games filter
- Streaks: current win streak, longest win streak, games since last win
- Streak reset: verify streak resets after a loss
- Edge case: 0 completed games
- Edge case: single round game
- Name normalization: case folding ("Alice" == "alice"), trimming, accented chars

- [ ] **Step 3: Run tests to verify they fail**

Run: `flutter test test/domain/stats/stats_calculator_test.dart`
Expected: FAIL (class not found)

- [ ] **Step 4: Implement StatsCalculator**

Pure Dart class with methods accepting domain model inputs:
- `computeSessionStats({required List<PlayerScore> players, required List<RoundData> rounds})` → `SessionStats`
- `computePlayerAllTimeStats({required String normalizedName, required List<CompletedGameData> allGames})` → `PlayerAllTimeStats`
- `computeHeadToHead({required String playerA, required String playerB, required List<CompletedGameData> sharedGames})` → `HeadToHeadRecord`
- `computeLeaderboard({required List<CompletedGameData> allGames, int minGames = 3})` → `List<LeaderboardEntry>`

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/domain/stats/stats_calculator_test.dart`
Expected: all PASS

- [ ] **Step 6: Commit**

```bash
git add lib/domain/stats/ test/domain/stats/
git commit -m "feat: add StatsCalculator with full test coverage"
```

---

### Task 7: Milestone detector

**Files:**
- Create: `lib/domain/stats/milestone_detector.dart`
- Create: `test/domain/stats/milestone_detector_test.dart`

- [ ] **Step 1: Write failing tests**

Test cases:
- First correct guess detected on first correct vote
- First correct guess NOT triggered on second correct vote
- On Fire: 3 correct in a row triggers
- On Fire: streak resets after incorrect
- Master Storyteller: 3 good clues in a row
- Trickster: 3+ bonus votes in single round
- No milestones when nothing special happens
- Multiple milestones in same round
- Empty round history

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/domain/stats/milestone_detector_test.dart`
Expected: FAIL

- [ ] **Step 3: Implement MilestoneDetector**

```dart
enum Milestone { firstCorrectGuess, onFire, masterStoryteller, trickster }

class MilestoneResult {
  final Milestone milestone;
  final String playerId;
  final String playerName;
  const MilestoneResult({required this.milestone, required this.playerId, required this.playerName});
}

class MilestoneDetector {
  List<MilestoneResult> detectMilestones({
    required List<RoundData> sessionRounds,
    required RoundData latestRound,
    required Map<String, String> playerNames, // id -> name
  });
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/domain/stats/milestone_detector_test.dart`
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add lib/domain/stats/milestone_detector.dart test/domain/stats/
git commit -m "feat: add MilestoneDetector with test coverage"
```

---

### Task 8: Stats providers + service

**Files:**
- Create: `lib/features/stats/providers/stats_providers.dart`

- [ ] **Step 1: Create StatsService and providers**

`StatsService` fetches data from DAOs, converts to domain models, passes to `StatsCalculator`. Providers:
- `statsServiceProvider` — provides StatsService
- `sessionStatsProvider(sessionId)` — FutureProvider computing session stats
- `allTimeStatsProvider(normalizedName)` — FutureProvider computing all-time stats
- `leaderboardProvider` — FutureProvider computing leaderboard
- `scoreProgressionProvider(sessionId)` — FutureProvider returning per-player per-round cumulative scores for charting

- [ ] **Step 2: Run analyze**

Run: `flutter analyze`
Expected: no errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/stats/
git commit -m "feat: add stats providers and StatsService"
```

---

### Task 9: Stats UI — widgets + charts

**Files:**
- Create: `lib/features/stats/widgets/stat_card.dart`
- Create: `lib/features/stats/widgets/score_progression_chart.dart`
- Create: `lib/features/stats/widgets/win_rate_bar_chart.dart`
- Create: `lib/features/stats/widgets/score_distribution_chart.dart`
- Create: `lib/features/stats/widgets/storyteller_success_chart.dart`
- Create: `lib/features/stats/widgets/session_stats_section.dart`
- Create: `lib/features/stats/widgets/head_to_head_card.dart`
- Create: `lib/features/stats/widgets/player_detail_sheet.dart`

- [ ] **Step 1: Create StatCard widget**

Reusable tile: icon, label, value, optional subtitle. Uses theme tokens.

- [ ] **Step 2: Create ScoreProgressionChart**

fl_chart `LineChart` wrapper. Takes `Map<String, List<int>>` (playerName → cumulative scores per round). One colored line per player using `PlayerColors`.

- [ ] **Step 3: Create WinRateBarChart**

fl_chart `BarChart`. Takes `List<LeaderboardEntry>`. Horizontal bars, player names on y-axis, win rate % on x-axis, colored by player color.

- [ ] **Step 4: Create ScoreDistributionChart**

fl_chart `BarChart`. Takes per-player round score frequency data. Shows how often each player scores 0, 2, 3, 4+ in a round.

- [ ] **Step 5: Create StorytellerSuccessChart**

fl_chart `PieChart`. Takes good clue count and bad clue count. Shows storyteller success ratio as a donut chart.

- [ ] **Step 6: Create SessionStatsSection**

Column of StatCard widgets showing session stats (best round, worst round, accuracy, MVP). Takes `SessionStats` as input. Free for all users.

- [ ] **Step 7: Create HeadToHeadCard**

Shows two player names with win/loss/tie record between them. Compact card format.

- [ ] **Step 8: Create PlayerDetailSheet**

Bottom sheet showing all-time stats for a tapped player: wins, win rate, avg score, best game, streaks (currentWinStreak, longestWinStreak, gamesSinceLastWin), head-to-head records with other players, and storyteller success chart.

- [ ] **Step 9: Commit**

```bash
git add lib/features/stats/widgets/
git commit -m "feat: add stats widgets — cards, 4 chart types, player detail, head-to-head"
```

---

### Task 10: Stats screen + wiring

**Files:**
- Create: `lib/features/stats/screens/stats_screen.dart`
- Modify: `lib/app/router/app_router.dart` — add /stats route
- Modify: `lib/features/endgame/screens/endgame_screen.dart` — add session stats section
- Modify: `lib/features/home/screens/home_screen.dart` — add Stats icon

> **Note:** `home_screen.dart` is also modified in Task 5 (Quick Start chip). Serialize these tasks.

- [ ] **Step 1: Create StatsScreen**

Premium-gated `ConsumerWidget`. Layout:
- Tab bar: "Leaderboard" / "Players"
- Leaderboard tab: `WinRateBarChart` + ranked list of `LeaderboardEntry` items
- Players tab: List of all known players. Tapping opens `PlayerDetailSheet`
- Free users see `ImageFiltered` blur over content + "Unlock with Supporter Pack" CTA overlay

- [ ] **Step 2: Add /stats route**

```dart
GoRoute(
  path: '/stats',
  builder: (context, state) => const StatsScreen(),
),
```

- [ ] **Step 3: Wire SessionStatsSection into endgame screen**

Add below standings list. `SessionStatsSection` is free. Score progression chart below it is premium-gated (show lock icon overlay if not supporter).

- [ ] **Step 4: Add Stats icon to home screen app bar**

`IconButton(icon: Icon(Icons.insights_rounded), onPressed: () => context.go('/stats'))` — visible to all users, but screen content is premium-gated.

- [ ] **Step 5: Run analyze and test**

Run: `flutter analyze && flutter test`
Expected: no errors, all tests pass

- [ ] **Step 6: Commit**

```bash
git add lib/features/stats/screens/ lib/features/endgame/ lib/features/home/ lib/app/router/
git commit -m "feat: add stats screen, wire into endgame and home"
```

---

## Chunk 3: Premium Celebration Effects

### Task 11: Celebration domain logic

**Files:**
- Create: `lib/domain/celebrations/celebration_models.dart`
- Create: `lib/domain/celebrations/celebration_engine.dart`
- Create: `test/domain/celebrations/celebration_engine_test.dart`

- [ ] **Step 1: Create celebration_models.dart**

```dart
enum CelebrationEffect {
  confettiRain,
  sparkleBurst,
  winnerGlow,
  milestoneToast,
  celebrationSound,
  milestoneChime,
}

enum ParticleTheme {
  celestialStars,
  oceanBubbles,
  emberSparks,
  frostSnowflakes,
  forestLeaves,
}

class CelebrationResult {
  final List<CelebrationEffect> effects;
  final ParticleTheme particleTheme;
  final List<MilestoneResult> milestones;
  const CelebrationResult({
    required this.effects,
    required this.particleTheme,
    required this.milestones,
  });
}
```

- [ ] **Step 2: Write failing tests for CelebrationEngine**

Test cases:
- Supporter + winner reveal → confetti + sparkle + sound
- Free user + winner reveal → no premium effects
- Supporter + milestone → toast + chime
- Theme-specific particle selection (ocean, ember, frost, forest, celestial)
- Reduced motion → no particle effects, sound still included
- Multiple milestones → all included in result

- [ ] **Step 3: Run tests to verify they fail**

Run: `flutter test test/domain/celebrations/celebration_engine_test.dart`
Expected: FAIL

- [ ] **Step 4: Implement CelebrationEngine**

Pure Dart class. Takes round result, supporter status, selected theme, reduced motion flag. Returns `CelebrationResult` describing which effects to play.

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/domain/celebrations/celebration_engine_test.dart`
Expected: all PASS

- [ ] **Step 6: Commit**

```bash
git add lib/domain/celebrations/ test/domain/celebrations/
git commit -m "feat: add CelebrationEngine with test coverage"
```

---

### Task 12: Confetti overlay + particle painter

**Files:**
- Create: `lib/features/celebrations/widgets/confetti_overlay.dart`

- [ ] **Step 1: Implement ConfettiOverlay**

`StatefulWidget` with `AnimationController` (3 second duration). `CustomPainter` renders 100-150 particles:
- Each particle: position, velocity, rotation, color, shape (rect/circle/star)
- Colors sourced from `ParticleTheme`
- Gravity + slight horizontal drift
- `RepaintBoundary` for performance

Theme-specific particle behaviors:
- `celestialStars`: gold/white, star shapes falling
- `oceanBubbles`: blue circles rising
- `emberSparks`: orange/red small dots floating up
- `frostSnowflakes`: white hexagons falling slowly
- `forestLeaves`: green/amber leaf shapes drifting

- [ ] **Step 2: Run analyze**

Run: `flutter analyze`
Expected: no errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/celebrations/
git commit -m "feat: add confetti overlay with theme-specific particles"
```

---

### Task 13: Milestone toast widget

**Files:**
- Create: `lib/features/celebrations/widgets/milestone_toast.dart`

- [ ] **Step 1: Implement MilestoneToast**

Animated banner that slides down from top. Shows icon + milestone name + player name. Auto-dismisses after 2.5s. Queue system for multiple toasts.

```dart
class MilestoneToast extends StatefulWidget {
  final MilestoneResult milestone;
  final VoidCallback onDismissed;
  // ...
}
```

Uses `SlideTransition` + `FadeTransition`. Respects reduced motion (instant show/hide).

- [ ] **Step 2: Run analyze**

Run: `flutter analyze`
Expected: no errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/celebrations/widgets/milestone_toast.dart
git commit -m "feat: add milestone toast widget with animation"
```

---

### Task 14: Celebration controller + sound effects

**Files:**
- Create: `lib/features/celebrations/celebration_controller.dart`
- Create: `assets/sounds/` (placeholder — actual audio files needed)
- Modify: `lib/data/settings/app_settings.dart` — add soundEffectsEnabled
- Modify: `lib/data/settings/app_settings_repository.dart` — persist soundEffectsEnabled
- Modify: `lib/features/settings/providers/settings_providers.dart` — add setter
- Modify: `lib/features/settings/screens/settings_screen.dart` — add Sound Effects toggle
- Modify: `pubspec.yaml` — add assets/sounds/ to assets

- [ ] **Step 1: Add soundEffectsEnabled to AppSettings**

Add `bool soundEffectsEnabled = false` (default OFF). Add to `copyWith`, `load`, `save`.

- [ ] **Step 2: Add Sound Effects toggle to settings screen**

SwitchListTile below Haptic Feedback toggle. Premium-gated: only visible/enabled for supporters.

- [ ] **Step 3: Create CelebrationController**

Reads `CelebrationResult` from engine. Accepts `BuildContext` to read `MediaQuery.disableAnimations` for reduced motion. Triggers:
- `ConfettiOverlay` as overlay entry (skipped if reduced motion)
- `MilestoneToast` as overlay entry (instant show/hide if reduced motion)
- Audio playback via `audioplayers` (if soundEffectsEnabled && supporter — NOT affected by reduced motion)
- Haptics via `Haptics.heavy()`

```dart
class CelebrationController {
  final OverlayState overlay;
  final bool isReducedMotion;
  final bool isSoundEnabled;
  // ...
  void play(CelebrationResult result) {
    if (!isReducedMotion) {
      // show confetti, sparkle
    }
    if (isSoundEnabled) {
      // play audio
    }
    // always show milestone toasts (adapts to reduced motion internally)
  }
}
```

- [ ] **Step 4: Create placeholder sound assets**

Create `assets/sounds/chime.mp3` and `assets/sounds/celebration.mp3` as silent placeholder files (to be replaced with real audio later).

- [ ] **Step 4b: Register sound assets in pubspec.yaml**

Add to `flutter.assets` in `pubspec.yaml`:
```yaml
  assets:
    - assets/sounds/
```
Run `flutter pub get` to verify asset registration.

- [ ] **Step 5: Run analyze**

Run: `flutter analyze`
Expected: no errors

- [ ] **Step 6: Commit**

```bash
git add lib/features/celebrations/ lib/data/settings/ lib/features/settings/ assets/sounds/ pubspec.yaml
git commit -m "feat: add celebration controller, sound settings, and audio support"
```

---

### Task 15: Wire celebrations into scoreboard + endgame

**Files:**
- Modify: `lib/features/scoreboard/screens/scoreboard_screen.dart`
- Modify: `lib/features/endgame/screens/endgame_screen.dart`

- [ ] **Step 1: Add milestone toasts to scoreboard**

After round submission in `RoundScreen`, pass round result to `MilestoneDetector`. If milestones detected and user is supporter, show `MilestoneToast` overlay on scoreboard.

- [ ] **Step 2: Add winner glow to scoreboard**

When a player reaches target score, their `PlayerScoreCard` gets animated gold border glow (2 cycles). Premium-gated.

- [ ] **Step 3: Add confetti to endgame screen**

On endgame screen load, if supporter, trigger `ConfettiOverlay` as overlay. Add `ConfettiOverlay` above trophy animation. Theme-specific particles.

- [ ] **Step 4: Run analyze and test**

Run: `flutter analyze && flutter test`
Expected: no errors, all tests pass

- [ ] **Step 5: Commit**

```bash
git add lib/features/scoreboard/ lib/features/endgame/ lib/features/round/
git commit -m "feat: wire celebrations into scoreboard and endgame screens"
```

---

## Chunk 4: Integration + Polish

### Task 16: Update premium screen + feature list

**Files:**
- Modify: `lib/features/premium/widgets/feature_preview_list.dart`

- [ ] **Step 1: Update feature descriptions to match actual delivered features**

Update the 5 `_FeatureItem` entries to accurately describe what supporters get:
1. "4 Premium Color Themes" → keep as-is
2. "Premium Celebration Effects" → "Confetti, themed particles, milestone toasts, and sound effects"
3. "Player Presets & Saved Groups" → "Save player groups, quick start, and favorite players"
4. "Advanced Score Statistics" → "All-time stats, charts, leaderboard, and head-to-head records"
5. "Support Independent Development" → keep as-is

- [ ] **Step 2: Run analyze**

Run: `flutter analyze`
Expected: no errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/premium/
git commit -m "chore: update premium feature list to match delivered features"
```

---

### Task 17: Full integration test + premium gating tests

**Files:**
- Create: `test/features/premium/premium_gating_test.dart`
- Create: `test/features/presets/preset_integration_test.dart`
- Create: `test/domain/stats/name_normalization_test.dart`
- Verify: `test/domain/stats/stats_calculator_test.dart`
- Verify: `test/domain/stats/milestone_detector_test.dart`
- Verify: `test/domain/celebrations/celebration_engine_test.dart`

- [ ] **Step 1: Create premium gating widget tests**

Test locked vs unlocked states for:
- `ThemePicker` (existing) — verify lock icon shown when not supporter
- `StatsScreen` — verify blur overlay shown when not supporter
- `PresetManagementScreen` — verify locked CTA when not supporter
- Each test: render with `isSupporterProvider` overridden to false, verify lock UI; override to true, verify feature accessible

- [ ] **Step 2: Create preset save/load integration test**

Full round-trip:
1. Create preset with 4 players
2. Save preset via `savePreset()`
3. Load preset via `watchPlayersForPreset()`
4. Verify player names, colors, seat order match
5. Delete preset, verify it's gone
6. Test constraint: create 21st preset → expect error
7. Test constraint: create preset with 2 players → expect error

- [ ] **Step 3: Create name normalization unit tests**

Test cases:
- `"Alice"` → `"alice"` (case folding)
- `"  Bob  "` → `"bob"` (trimming)
- `"José"` handled correctly
- `"alice"` == `"Alice"` == `" ALICE "` (equivalence)

- [ ] **Step 4: Run full test suite**

Run: `flutter test`
Expected: all tests pass

- [ ] **Step 5: Run analyze**

Run: `flutter analyze`
Expected: no errors

- [ ] **Step 6: Build iOS**

Run: `flutter build ios --release --no-codesign`
Expected: build succeeds

- [ ] **Step 7: Build Android**

Run: `flutter build appbundle --release`
Expected: build succeeds

- [ ] **Step 8: Commit all tests**

```bash
git add test/
git commit -m "test: add premium gating, preset integration, and name normalization tests"
```

- [ ] **Step 9: Push**

```bash
git push origin claude/recursing-lewin
```
