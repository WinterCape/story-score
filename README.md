# StoryScore

The most beautiful score companion for storytelling card games.

[Screenshot placeholder]

## Features

- Automatic scoring with full storytelling card game rules
- Tap-to-vote round entry -- score a round in 3 taps
- Round history with undo, edit, and delete
- Save and resume multiple games
- Export/import sessions (JSON + CSV)
- Beautiful Celestial/Aurora theme (dark + light mode)
- Works fully offline -- no account, no internet required
- 3-10 players with customizable colors

## Getting Started

### Prerequisites
- Flutter 3.32+ (stable channel)
- Dart 3.8+
- iOS 16.0+ / Android API 21+

### Setup
```bash
git clone https://github.com/WinterCape/story-score.git
cd story-score
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Running Tests
```bash
flutter test                    # All tests
flutter test test/domain/       # Scoring engine tests only
flutter analyze                 # Static analysis
```

## Architecture

- **Framework**: Flutter (iOS + Android + Web-ready)
- **State Management**: Riverpod 3.0
- **Database**: Drift (SQLite ORM)
- **Routing**: GoRouter
- **Theme**: Material 3 with custom Celestial/Aurora design tokens

### Project Structure
```
lib/
  app/          # App config, routing, theme
  core/         # Constants, utilities, l10n
  data/         # Database, settings, export/import
  domain/       # Scoring engine, business models
  features/     # Feature modules (screens, widgets, providers)
  shared/       # Shared widgets, extensions
```

## Scoring Rules

| Scenario | Storyteller | Correct Guessers | Others |
|----------|-------------|-----------------|--------|
| Good clue (some guess right) | +3 | +3 each | -- |
| Bad clue (all/none guess right) | 0 | -- | +2 each |
| Fooled bonus (always) | -- | Can earn too | +1 per vote received |

## Monetization

Free with all core features. Optional Supporter Pack ($3.99) unlocks premium themes, celebration effects, and advanced stats.

## License

[Add license]

## Privacy

StoryScore collects no data. No analytics, no accounts, no network required. See [Privacy Policy](docs/store-materials.md).
