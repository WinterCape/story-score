# StoryScore Testing Guide

## Prerequisites

- Flutter SDK ^3.8.1
- Run code generation before testing if you have changed any annotated files (Drift tables, Riverpod providers, Freezed models):

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Unit Tests

Pure Dart tests for logic with no Flutter dependency.

```bash
# Run all unit tests
flutter test test/domain/

# Run a specific test file
flutter test test/domain/scoring/scoring_engine_test.dart
```

### What to unit test
- `ScoringEngine.computeRound` -- all scoring scenarios (good clue, perfect fail, fooled bonus)
- `ScoringEngine.validateInput` -- invalid inputs (self-votes, missing voters, unknown players)
- `RoundInput` factory validation
- Export/import schema round-trips
- `PlayerColors.nextAvailable` allocation logic
- `IdGenerator` uniqueness

### Mocking

Use `mocktail` for mocks. Example:

```dart
class MockRoundDao extends Mock implements RoundDao {}
class MockSessionDao extends Mock implements SessionDao {}
```

## Widget Tests

Test individual widgets and screens with `WidgetTester`.

```bash
# Run all widget tests
flutter test test/

# Run with verbose output
flutter test --reporter expanded
```

### Pattern for widget tests with Riverpod

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(testDb),
      scoringEngineProvider.overrideWithValue(const ScoringEngine()),
    ],
    child: const MaterialApp(home: MyWidget()),
  ),
);
```

### What to widget test
- Screen rendering with various data states (empty, loading, populated)
- User interactions (taps, form input, navigation)
- Error states and edge cases
- Theme-dependent rendering (dark vs. light)

## Integration Tests

End-to-end tests that run on a real device or emulator.

```bash
# Run all integration tests
flutter test integration_test/

# Run on a specific device
flutter test integration_test/ -d <device-id>
```

### Planned integration test flows
- Full game lifecycle: setup -> rounds -> endgame
- Session persistence: create, close app, resume
- Export/import round-trip
- Onboarding flow completion

## Code Generation

Several packages require generated code. Always regenerate after modifying:
- Drift table definitions or DAO queries
- `@riverpod` annotated providers
- `@freezed` model classes
- `@JsonSerializable` classes

```bash
# One-shot build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (rebuilds on file save)
dart run build_runner watch --delete-conflicting-outputs
```

Generated files follow the `*.g.dart` and `*.freezed.dart` naming convention. They are checked into version control.

## Linting

```bash
# Run the analyzer
flutter analyze

# Auto-fix lint issues
dart fix --apply
```

Active lint packages:
- `flutter_lints` -- standard Flutter lint rules
- `custom_lint` -- project-specific rules
- `riverpod_lint` -- Riverpod best practices (missing `ref.watch`, provider naming)

## CI Pipeline

Recommended GitHub Actions workflow:

```yaml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.x'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --debug  # Smoke-test Android build
```

### Coverage

```bash
# Generate coverage report
flutter test --coverage

# View HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test File Organization

```
test/
  domain/
    scoring/
      scoring_engine_test.dart   # Scoring logic tests
  widget_test.dart               # Default widget test scaffold
integration_test/
  (planned)
```

Place new tests adjacent to the code they cover:
- `test/domain/scoring/` for scoring logic
- `test/data/` for database and export tests
- `test/features/<name>/` for widget tests per feature
