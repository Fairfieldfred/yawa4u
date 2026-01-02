# YAWA4U - Copilot Instructions

## Project Overview

Flutter workout tracking app (iOS, Android, Web, macOS, Windows, Linux) using **Riverpod 3.0** for state management and **Hive** for local-first persistence. Tracks: TrainingCycle → Period → Workout → Exercise → ExerciseSet.

## Architecture

```
lib/
├── core/          # Utilities, constants, theme system (enums.dart for all Hive-persisted enums)
├── data/          # Models (*.g.dart generated), repositories, services
├── domain/        # Providers (Riverpod), controllers (WorkoutHomeController)
├── presentation/  # Screens, widgets, go_router navigation
```

## ⚠️ Critical Domain Concepts

### Workout vs Training Day

The database stores **multiple `Workout` objects per training day** (one per muscle group). All workouts for the same day share `periodNumber` and `dayNumber`, differentiated by `label`. Aggregate all `Workout` objects when displaying a day's workout to users.

### Periods vs Weeks

Uses "periods" (not weeks) for flexible schedules (8, 9, 10+ day cycles):

- `periodsTotal` / `daysPerPeriod` - Cycle structure (uniform)
- `periodNumber` / `dayNumber` - Workout positioning (1-indexed)
- `recoveryPeriod` + `RecoveryPeriodType` - Optional deload/rest period

### Data Snapshot Warning

`TrainingCycle.workouts` is a **snapshot at creation**—always use `workoutsByTrainingCycleProvider(cycleId)` for current workout state.

## State Management

### Provider Pattern (domain/providers/)

```dart
// Reactive Hive watching via StreamProvider
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) async* {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  yield repository.getAllSorted();
  await for (final _ in repository.box.watch()) { yield repository.getAllSorted(); }
});

// Parameterized access via Provider.family
final trainingCycleProvider = Provider.family<TrainingCycle?, String>((ref, id) => ...);
```

### Controller Pattern (domain/controllers/)

Complex screens use `Notifier<State>` with immutable state classes:

```dart
class WorkoutHomeController extends Notifier<WorkoutHomeState> {
  // Access repos via ref.read(workoutRepositoryProvider)
}
```

## Code Generation

Files with `part '*.g.dart'` require regeneration after changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Affected: `data/models/*.dart`, `core/constants/enums.dart`, `core/theme/skins/skin_model.dart`

## Skin/Theme System

Located in `core/theme/skins/`:

- `SkinModel` - JSON-serializable config (`@JsonSerializable`)
- `SkinBuilder.buildTheme()` - Converts to `ThemeData`
- Built-in skins in `built_in_skins/` (e.g., `default_skin.dart`)
- Access: `Theme.of(context).extension<SkinExtension>()`
- Colors stored as hex strings, parsed via `SkinColors.parseHex()`

## Template Authoring

Templates in `assets/templates/*.json` auto-discovered via AssetManifest:

```json
{
  "id": "unique_id",
  "name": "Template Name",
  "periodsTotal": 5,
  "daysPerPeriod": 8,
  "workouts": [
    {
      "periodNumber": 1,
      "dayNumber": 1,
      "dayName": "Day 1",
      "exercises": [
        {
          "name": "Bench Press",
          "muscleGroup": "chest",
          "equipmentType": "barbell",
          "sets": 3,
          "reps": "8-12",
          "setType": "regular"
        }
      ]
    }
  ]
}
```

Enum values (`muscleGroup`, `equipmentType`, `setType`) must match `core/constants/enums.dart`.

## Navigation

`go_router` in `presentation/navigation/app_router.dart`. Routes in `AppRoutes` class. Onboarding redirect handled in router's `redirect` callback.

## Common Commands

| Task           | Command                                                                   |
| -------------- | ------------------------------------------------------------------------- |
| Run            | `flutter run`                                                             |
| Regenerate     | `dart run build_runner build --delete-conflicting-outputs`                |
| Test           | `flutter test`                                                            |
| Build          | `flutter build apk --release` / `flutter build ipa` / `flutter build web` |
| Disable Sentry | `flutter run --dart-define=SENTRY_ENABLED=false`                          |

## Conventions

- Enums: `@HiveType` + `@HiveField` annotations in `core/constants/enums.dart`
- Models: Immutable with `copyWith()` methods
- Repositories: Expose `box` property for stream-based watching
- Tests: Wrap widgets in `ProviderScope`
