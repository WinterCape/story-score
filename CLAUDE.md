# StoryScore — AI Developer Guide

## Project Overview
StoryScore is a local-first score counter companion for storytelling card games.
Flutter app targeting iOS + Android, with web-friendly architecture.

## Architecture
- **State management**: Riverpod (flutter_riverpod)
- **Database**: Drift (SQLite ORM) for structured data
- **Settings**: SharedPreferences for flat key-value config
- **Routing**: GoRouter with StatefulShellRoute for in-game tabs
- **IAP**: RevenueCat (purchases_flutter)

## Folder Conventions
```
lib/app/        — App-level: routing, theme, top-level providers
lib/core/       — Shared utilities, constants, l10n
lib/data/       — Persistence: database, settings, export/import
lib/domain/     — Business logic: scoring engine, domain models
lib/features/   — Feature modules (each has screens/, widgets/, providers/)
lib/shared/     — Shared widgets, extensions
```

## Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Providers: `camelCaseProvider` (e.g., `sessionListProvider`)
- Enums: `PascalCase` with `camelCase` values
- Database tables: `PascalCase` (Drift convention)
- Feature folders: `snake_case`

## Coding Conventions
- Use `package:story_score/...` imports (not relative)
- Prefer `const` constructors where possible
- Use `abstract final class` for classes with only static members
- No `dynamic` types unless absolutely necessary
- Theme tokens via `context.storyTheme` extension
- All user-facing strings should be in l10n ARB files (future)

## Scoring Engine
- Located at `lib/domain/scoring/scoring_engine.dart`
- Pure Dart — zero Flutter imports, zero side effects
- Must remain deterministic: same inputs → same outputs
- All scoring rules implemented here, not in UI or database code
- `RoundProcessor` orchestrates scoring + persistence

## Testing
- Scoring engine must have 100% rule coverage
- Widget tests for critical screens (vote entry, scoreboard)
- Integration tests for full game flows
- Run tests: `flutter test`
- Run analysis: `flutter analyze`

## IP Safety
- NEVER use "Dixit", Libellud, Asmodee, or any copyrighted game names
- No copyrighted card art or illustrations
- App uses original visuals only
- Store listings must use neutral language ("storytelling card games")

## Theme
- Celestial/Aurora visual direction
- Dark mode is the hero theme (designed for table use)
- Use design tokens from `lib/app/theme/` — never hardcode colors
- Player colors from `PlayerColors.all` map

## Monetization
- Free app + optional Supporter Pack ($3.99 one-time)
- No ads
- Core gameplay always free
- Premium gates cosmetic features only (themes, effects, presets)
- Never show monetization on gameplay screens
