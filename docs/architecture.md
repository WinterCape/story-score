# StoryScore Architecture

## Project Structure

StoryScore uses a **feature-first** layout. Each screen or domain concept lives in its own folder under `lib/features/`, keeping UI, providers, and widgets co-located.

```
lib/
  main.dart                     # Entry point, ProviderScope bootstrap
  app/
    app.dart                    # MaterialApp.router wrapper
    providers.dart              # Root-level Riverpod providers (DB, DAOs, engine)
    router/
      app_router.dart           # GoRouter definition + onboarding guard
    theme/
      color_tokens.dart         # Dark + light palette constants
      text_tokens.dart          # Nunito typography scale
      spacing_tokens.dart       # Spacing + corner-radius scale
      motion_tokens.dart        # Duration + curve constants
      story_score_theme.dart    # ThemeData builder (dark + light)
      theme_extensions.dart     # StoryScoreThemeExtension (gradients, player colors)
  core/
    constants/
      player_colors.dart        # 12-color palette for player assignment
      score_reasons.dart        # UI labels for scoring reasons
    utils/
      id_generator.dart         # UUID wrapper
  data/
    database/
      app_database.dart         # Drift database class + schema version
      tables/                   # Table definitions (GameSessions, Players, Rounds, Votes, ScoreChanges, PurchaseEntitlements)
      daos/                     # SessionDao, RoundDao, PurchaseDao
    export/
      session_exporter.dart     # JSON export
      session_importer.dart     # JSON import
      export_schema.dart        # Versioned export format
    settings/
      app_settings.dart         # Settings model
      app_settings_repository.dart  # SharedPreferences persistence
  domain/
    models/
      game_summary.dart         # Aggregate view model
      round_with_details.dart   # Round + votes + score changes
    scoring/
      scoring_engine.dart       # Pure Dart scoring logic
      round_processor.dart      # Orchestrator: engine + DAO writes
      score_reason.dart         # ScoreReason enum + ClueOutcome enum
  features/
    home/                       # Session list, empty state
    onboarding/                 # First-launch walkthrough
    game_setup/                 # Player names, colors, seat order
    scoreboard/                 # Live leaderboard
    round/                      # Vote capture + round detail
    history/                    # Per-session round timeline
    endgame/                    # Final standings + share
    settings/                   # App preferences
    premium/                    # Supporter Pack purchase screen
  shared/
    extensions/
      context_extensions.dart   # BuildContext helpers
    widgets/
      game_shell.dart           # StatefulShellRoute bottom-nav wrapper
```

## State Management -- Riverpod

- **Provider types**: `Provider` for singletons (DB, DAOs, ScoringEngine), `StreamProvider` for reactive database queries, `StateNotifierProvider` / `NotifierProvider` for mutable UI state.
- **Root overrides**: `appDatabaseProvider` is overridden in the root `ProviderScope` so the database instance is created once at startup.
- **Code generation**: `riverpod_generator` + `riverpod_annotation` produce `*.g.dart` files for annotated providers. Feature-level providers live next to their screens in `features/<name>/providers/`.

## Database -- Drift / SQLite

- **ORM**: Drift (formerly Moor) with `drift_flutter` for platform-specific SQLite binaries.
- **Tables**: `GameSessions`, `Players`, `Rounds`, `Votes`, `ScoreChanges`, `PurchaseEntitlements`.
- **DAOs**: `SessionDao` (CRUD sessions + players, score recomputation, storyteller rotation), `RoundDao` (insert/update/delete rounds, votes, score changes), `PurchaseDao` (IAP entitlement records).
- **Transactions**: Multi-table writes (e.g., `createSession`, `insertRoundWithScores`, `deleteSession`) are wrapped in `transaction()` for atomicity.
- **Schema version**: Currently `1`. Migrations are handled via `MigrationStrategy.onCreate`.
- **Testing constructor**: `AppDatabase.forTesting(QueryExecutor)` allows injecting an in-memory database.

## Scoring Engine -- Pure Dart

`ScoringEngine` is a **stateless, pure-Dart class** with zero Flutter or database dependencies. It implements the standard storytelling card game scoring rules:

| Scenario | Storyteller | Correct guesser | Other non-storytellers |
|---|---|---|---|
| **Good clue** (some guess correctly) | +3 | +3 each | -- |
| **Perfect fail** (all or none guess correctly) | 0 | -- | +2 each |
| **Fooled bonus** (always) | -- | -- | +1 per vote received |

Key design decisions:
- `RoundInput` validates via factory constructor; an `unvalidated` constructor exists for testing validation itself.
- `RoundResult` contains a flat list of `ScoreEntry` objects and a `ClueOutcome` enum.
- `RoundProcessor` orchestrates the full flow: validate -> compute -> persist -> recompute cumulative scores -> advance storyteller.

## Navigation -- GoRouter

- **Declarative routing** via `GoRouter` with path-based routes.
- **StatefulShellRoute.indexedStack** provides the in-game bottom navigation (Scoreboard / Round / History tabs) with independent navigator keys per tab.
- **Onboarding guard**: A redirect function checks first-launch status and redirects to `/onboarding` if needed.
- **Route parameters**: Session and round IDs passed as path parameters (`/game/:sessionId/scoreboard`, `/game/:sessionId/round/:roundId`).

### Route map

| Path | Screen |
|---|---|
| `/` | HomeScreen |
| `/onboarding` | OnboardingFlow |
| `/settings` | SettingsScreen |
| `/settings/premium` | PremiumScreen |
| `/game/new` | GameSetupScreen |
| `/game/:sessionId/scoreboard` | ScoreboardScreen (tab 0) |
| `/game/:sessionId/round` | RoundScreen (tab 1) |
| `/game/:sessionId/round/:roundId` | RoundDetailScreen |
| `/game/:sessionId/history` | HistoryScreen (tab 2) |
| `/game/:sessionId/endgame` | EndgameScreen |
| `/archive/:sessionId` | ScoreboardScreen (read-only) |

## Theme System

- **Material 3** with `useMaterial3: true`.
- **Two themes**: dark (default, deep purple/aurora palette) and light (warm parchment).
- **Token classes**: `ColorTokens`, `TextTokens`, `SpacingTokens`, `MotionTokens` -- all `abstract final class` with static constants.
- **ThemeExtension**: `StoryScoreThemeExtension` carries app-specific values (gold accent, aurora gradient, card gradient, player colors) that don't map to `ColorScheme`.
- **Access pattern**: `Theme.of(context).storyScore.goldAccent` via an extension on `ThemeData`.

## Testing Strategy

- **Unit tests**: Pure Dart logic (ScoringEngine, validation, models) tested with `flutter_test` + `mocktail` for mocks.
- **Widget tests**: Individual widgets and screens tested with `WidgetTester`, pumping a `ProviderScope` with overridden providers.
- **Integration tests**: End-to-end flows planned in `integration_test/` (currently empty scaffold).
- **Code generation**: `build_runner` generates Drift, Riverpod, Freezed, and JSON serialization code. Must run before tests if schema or providers change.
- **Linting**: `flutter_lints` + `custom_lint` + `riverpod_lint` for Riverpod best practices.
