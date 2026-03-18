# Premium Features Design — Supporter Pack Fulfillment

**Date:** 2026-03-18
**Status:** Approved
**Scope:** Deliver the 3 promised but unbuilt Supporter Pack features

---

## Context

The Supporter Pack ($3.99 one-time) currently promises 4 tangible features but only delivers 1 (premium color themes). This spec covers building the remaining 3:

1. Player Presets & Saved Groups
2. Advanced Score Statistics
3. Premium Celebration Effects

All features are premium-gated using the existing `isSupporterProvider` pattern.

**Monetization boundary clarification:** The endgame screen is considered a *post-gameplay* screen, not a live gameplay screen. Subtle premium CTAs (e.g., a locked chart with "Unlock with Supporter Pack" link) are acceptable there. Blocking gates or interstitials are never acceptable on any screen.

---

## 1. Player Presets & Saved Groups

### Data Model

New database tables (schema v1 → v2 migration):

```
PlayerPresets
  - id: TEXT PK (UUID)
  - name: TEXT NOT NULL
  - lastUsedAt: INTEGER NULLABLE
  - createdAt: INTEGER NOT NULL
  - updatedAt: INTEGER NOT NULL

PresetPlayers
  - id: TEXT PK (UUID)
  - presetId: TEXT FK → PlayerPresets.id (CASCADE DELETE)
  - name: TEXT NOT NULL
  - colorKey: TEXT NOT NULL
  - avatarStyle: TEXT NOT NULL DEFAULT 'initials'
  - seatOrder: INTEGER NOT NULL
  - isFavorite: INTEGER NOT NULL DEFAULT 0
```

### Constraints

- Maximum 20 presets per app (soft limit, show "limit reached" message)
- Preset names are not required to be unique (users may want "Friday Group" variants)
- Minimum 3 players per preset (matches game minimum); presets with fewer than 3 cannot be loaded
- Maximum 10 players per preset (matches game maximum)
- Removing players below 3 in edit mode shows a warning
- Quick Start MRU: tracked by `lastUsedAt` on `PlayerPresets`. If the MRU preset is deleted, the next most recent is used. If no presets exist, Quick Start chip is hidden.

### Favorites

- `isFavorite` is stored per-player per-preset (column on `PresetPlayers`)
- Favorites query unions across all presets, deduplicating by name (case-insensitive, trimmed)
- Maximum 10 favorites shown as quick-add chips
- A player can be favorited without being in any preset (future consideration — for now, favorites are always part of a preset)

### Features

**Save group:**
- "Save as Preset" action available on game setup screen (after adding 3+ players) and endgame screen
- Opens a dialog asking for preset name (defaults to game title or "My Group")
- Saves all current players (name, color, avatar, seat order) to a new preset
- Premium-gated: free users see locked CTA

**Load group:**
- "Load Preset" button on game setup screen, above the player list
- Opens bottom sheet listing all saved presets with player count and color dots preview
- Tapping a preset replaces all current players with the preset's players
- Confirmation dialog if players already exist: "Replace current players?"

**Favorite players:**
- Individual players can be starred/favorited when saving a preset or in preset management
- On add-player sheet, favorited players appear as quick-add chips at the top
- Tapping a favorite chip instantly adds that player (skipping name/color entry)

**Quick Start:**
- When 1+ presets exist, home screen shows a "Quick Start" chip below the "New Game" FAB area
- Tapping opens a small sheet: pick a preset → game created with default 30 target → straight to scoreboard
- Most recently used preset shown first (by `lastUsedAt`)

**Manage presets:**
- Settings → "Player Presets" row navigates to `/settings/presets`
- List of saved presets with swipe-to-delete
- Tap to edit: rename, reorder players, remove individual players, toggle favorites
- Premium-gated: entire management screen requires supporter status

### Premium Gate

- Saving, loading, quick start, and management all require `isSupporterProvider == true`
- Free users see: locked icon on "Load Preset" button, "Save as Preset" shows upgrade dialog
- Favorite chips do not appear for free users

---

## 2. Advanced Score Statistics

### Session Stats (Per-Game) — FREE

Displayed as a new "Game Stats" section on the endgame screen, below standings:

| Stat | Computation |
|------|-------------|
| Best round | Max single-round delta across all players |
| Worst round | Min single-round delta (can be 0) |
| Guess accuracy % | (correct guesses / total voting opportunities) × 100 |
| Total bonus points | Sum of all `fooledBonus` score changes |
| Storyteller performance | (rounds with good clue / total rounds) × 100% |
| MVP | Player with highest single-round delta |

Session stats are **free** — they enrich the endgame experience for all users.

### Cross-Session Stats (All-Time) — PREMIUM

New Stats screen accessible from home screen app bar (chart icon).

**Per-player all-time stats:**
- Games played
- Wins (including shared wins for ties)
- Win rate %
- Average score per game
- Best game score (highest final score)
- Total points earned across all games

**Head-to-head records:**
- When viewing a player's stats, section showing win/loss against each opponent they've played
- Only counts games where both players participated

**Streaks:**
- Current win streak
- Longest win streak ever
- Games since last win

**Leaderboard:**
- Ranked list of all players by win rate (min 3 games) or total wins
- Toggleable sort

### Charts (using `fl_chart`) — PREMIUM

| Chart | Type | Description |
|-------|------|-------------|
| Score progression | Line chart | x = round number, y = cumulative score, one colored line per player. Shown per-game on endgame screen. |
| Win rate comparison | Bar chart | Horizontal bars for each player's win rate %. Cross-session stats screen. |
| Score distribution | Histogram | How often each player scores 0, 2, 3, 4+ in a round. Cross-session. |
| Storyteller success | Pie/donut chart | Good clue vs bad clue ratio for a player. Cross-session. |

### Player Identity for Cross-Session Stats

Player identity is matched by **normalized name**:
- Trim leading/trailing whitespace
- Case-fold to lowercase
- Unicode NFC normalization
- "Mike" and "mike" are the same player; "Mike" and "Michael" are different

**Limitations (documented, not solved in this version):**
- No "merge players" feature — different spellings create separate entities
- No persistent player ID across sessions
- These are planned for v2 with a persistent player registry

### Data Source

All stats computed from existing tables: `GameSessions`, `Players`, `Rounds`, `Votes`, `ScoreChanges`. No new tables needed.

`StatsCalculator` — pure Dart class, zero Flutter/Drift imports. Methods accept pre-fetched domain data, not database IDs:

```dart
class StatsCalculator {
  SessionStats computeSessionStats({
    required List<PlayerScore> players,
    required List<RoundData> rounds,
  });

  PlayerAllTimeStats computePlayerAllTimeStats({
    required String normalizedName,
    required List<CompletedGameData> allGames,
  });

  HeadToHeadRecord computeHeadToHead({
    required String playerA,
    required String playerB,
    required List<CompletedGameData> sharedGames,
  });

  List<LeaderboardEntry> computeLeaderboard({
    required List<CompletedGameData> allGames,
    int minGames = 3,
  });
}
```

A separate `StatsService` provider fetches data from DAOs and passes it to `StatsCalculator`.

### Premium Gate

- Session stats on endgame: **free**
- Score progression chart on endgame: **premium** (shown as locked with subtle "Unlock" link, not blocking)
- Stats screen, cross-session stats, charts, leaderboard: **premium**
- Free users see the Stats icon but get a locked preview with blurred content and "Unlock with Supporter Pack" CTA

---

## 3. Premium Celebration Effects

### Free Celebrations (Unchanged)

- Trophy icon scale bounce on endgame
- Animated score counter (0 → final)
- Staggered standings fade-in

### Premium: Confetti & Particles

**Winner reveal (endgame screen):**
- Full-screen confetti rain: gold and theme-colored rectangles/circles falling for 3 seconds
- Sparkle burst: radial particle explosion behind trophy icon
- Implementation: `CustomPainter` with animated particle list (no external animation packages needed)

**Winner glow (scoreboard):**
- When a player reaches the target score, their `PlayerScoreCard` gets a subtle animated glow border (gold pulse, 2 cycles)

### Premium: Theme-Specific Particles

Each premium theme has a unique particle style for the winner confetti:

| Theme | Particle Style |
|-------|---------------|
| Celestial (default) | Gold star shapes + white shimmer dots |
| Ocean Depths | Rising blue bubbles + wave ripple overlay |
| Ember | Floating orange/red ember sparks + warm glow |
| Frost | Falling white snowflakes + ice crystal shimmer |
| Enchanted Forest | Drifting green/amber leaves + yellow firefly dots |

Free theme (Celestial) gets the default gold confetti only when supporter.

### Premium: Milestone Toasts

Detected by `MilestoneDetector` after each round is scored:

| Milestone | Trigger | Icon |
|-----------|---------|------|
| First Correct Guess | Player's first correct vote in this session | 🎯 |
| On Fire! | 3 correct guesses in a row | 🔥 |
| Master Storyteller | 3 good clues in a row as storyteller | ⭐ |
| Trickster! | 3+ bonus votes received in a single round | 🃏 |

`MilestoneDetector` — pure Dart class. Methods accept round history data and return a list of triggered milestones:

```dart
class MilestoneDetector {
  List<Milestone> detectMilestones({
    required List<RoundData> sessionRounds,
    required RoundData latestRound,
    required String playerId,
  });
}
```

**Toast UX:**
- Appears as an animated banner sliding down from top of scoreboard screen
- Shows icon + milestone name + player name
- Auto-dismisses after 2.5 seconds
- Max 1 toast at a time (queue if multiple)
- Haptic feedback on show (light impact)

### Premium: Sound Effects

- Soft chime on milestone toast
- Celebration fanfare on winner reveal (short, 1-2 seconds)
- Bundled as small audio assets (~50KB total)
- Controlled by new "Sound Effects" toggle in Settings (default: **off** — the app is designed for table use in potentially quiet environments; users opt in)
- Respects device mute/silent switch
- Implementation: `AudioPlayer` from `audioplayers` package (lightweight, well-maintained)

### Reduced Motion Behavior

Celebration effects respect the OS accessibility setting via `MediaQuery.disableAnimations`:
- **When reduced motion is on:** No particle effects, no confetti, no glow animations. Trophy icon appears statically. Milestone toasts appear/disappear instantly (no slide animation). Score counter shows final value immediately. Sound effects still play (they are not motion).
- **When reduced motion is off:** Full animations as described above.
- This applies to both free and premium celebrations.

### Premium Gate

- Free users keep all existing celebrations unchanged
- Confetti, theme particles, milestone toasts, sound effects: all require `isSupporterProvider == true`
- `CelebrationEngine` returns a list of `CelebrationEffect` objects (pure decision logic, zero Flutter imports). A separate `CelebrationController` widget reads the list and triggers the actual Flutter animations/painters.
- Reduced motion overrides all particle effects regardless of supporter status

---

## Architecture

### New Dependencies

| Package | Purpose | Justification |
|---------|---------|---------------|
| `fl_chart: ^0.70.0` | Stats charts | Most popular Flutter charting lib, pure Dart, well-maintained |
| `audioplayers: ^6.0.0` | Sound effects | Lightweight audio playback, no native code bloat |

### New Domain Classes (Pure Dart, Zero Flutter Imports)

```
lib/domain/stats/stats_calculator.dart       — Accepts data, returns computed stats
lib/domain/stats/stats_models.dart           — SessionStats, PlayerAllTimeStats, etc.
lib/domain/stats/milestone_detector.dart     — Accepts round history, returns milestones
lib/domain/celebrations/celebration_engine.dart — Accepts round result + supporter status, returns effects list
lib/domain/celebrations/celebration_models.dart — CelebrationEffect, Milestone enums
```

### New Flutter Classes (UI/Controller Layer)

```
lib/features/celebrations/celebration_controller.dart — Reads CelebrationEffect list, triggers painters/audio
lib/features/stats/providers/stats_providers.dart     — StatsService fetches data, passes to StatsCalculator
```

### New Database

- `PlayerPresets` and `PresetPlayers` tables added to `AppDatabase`
- `PresetDao` for CRUD operations
- Schema migration v1 → v2

### Database Migration v1 → v2

The migration is **additive only** — two new tables, no changes to existing tables, no data transforms:

```dart
onUpgrade: (Migrator m, int from, int to) async {
  if (from < 2) {
    await m.createTable(playerPresets);
    await m.createTable(presetPlayers);
  }
}
```

No rollback needed — if the app crashes mid-migration, Drift's transaction ensures atomicity. The new tables simply won't exist and will be created on next launch.

### New Screens

| Route | Screen | Gate |
|-------|--------|------|
| `/stats` | Cross-session stats + charts | Premium |
| `/settings/presets` | Preset management | Premium |

### Modified Screens

| Screen | Changes |
|--------|---------|
| Home | Quick Start chip, Stats icon in app bar |
| Game Setup | "Load Preset" + "Save as Preset" buttons |
| Endgame | Session stats section (free), score progression chart (premium), enhanced celebrations (premium) |
| Scoreboard | Milestone toasts overlay (premium), winner glow effect (premium) |
| Settings | Sound Effects toggle, Player Presets row |
| Premium | Update feature list descriptions to match actual delivered features |

### New Widgets

- `ConfettiOverlay` — full-screen particle CustomPainter
- `MilestoneToast` — animated top banner
- `CelebrationController` — orchestrates effects from CelebrationEngine output
- `StatCard` — reusable stat display tile
- `ScoreProgressionChart` — fl_chart line chart wrapper
- `PresetListTile` — preset display with player color dots
- `FavoritePlayerChips` — quick-add row for favorited players

### Testing

| Area | Type | Coverage |
|------|------|----------|
| `StatsCalculator` | Unit | All stat computations, edge cases (0 games, ties, single player, no rounds) |
| `MilestoneDetector` | Unit | All 4 milestones, streak reset, boundary cases, empty history |
| `CelebrationEngine` | Unit | Decision logic for each effect type, supporter vs free output |
| Premium gating | Widget | Locked vs unlocked states for presets, stats, celebrations |
| Preset save/load | Integration | Full round-trip: save preset → load in new game → verify players |
| Stats accuracy | Unit | Verify computed stats match expected values for known game data |
| Player name normalization | Unit | Case folding, trimming, Unicode NFC |

---

## Implementation Order

1. **Player Presets** — new tables, migration, DAO, preset management screen, save/load/favorites/quick-start
2. **Stats Calculator + Stats Screen** — pure logic first, then UI with charts
3. **Celebrations** — milestone detector, celebration engine, confetti painter, toasts, sounds
4. **Integration** — wire everything, update premium screen descriptions, final testing

Each feature is independent and can be built in parallel.

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| `fl_chart` adds bundle size | ~200KB increase, acceptable for value delivered |
| Audio assets increase app size | Keep sounds under 100KB total, use compressed formats |
| Cross-session player identity by name is fragile | Document limitation, define normalization rules, plan persistent identity for v2 |
| Particle effects may jank on older devices | Use `RepaintBoundary`, limit particle count (max 150), respect reduced motion |
| Schema migration breaks existing data | Additive-only migration in transaction, tested thoroughly |
| Sound plays unexpectedly in quiet settings | Default sound toggle to OFF, respect device mute switch |
