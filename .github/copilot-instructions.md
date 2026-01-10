# YAWA4U - Copilot Instructions

## Project Overview

Flutter workout tracking app (iOS, Android, Web, macOS, Windows, Linux) using **Riverpod 3.0** for state management and **Hive** for local-first persistence. Core hierarchy: TrainingCycle → Period → Workout → Exercise → ExerciseSet.

## Architecture

```
lib/
├── core/           # Utilities, constants, theme system
│   ├── constants/  # enums.dart (ALL Hive-persisted enums), muscle_groups.dart, equipment_types.dart
│   ├── config/     # sentry_config.dart
│   ├── env/        # env.dart (--dart-define variables)
│   └── services/   # SentryService
├── data/
│   ├── models/     # Hive models with *.g.dart generated files
│   ├── repositories/  # CRUD operations, expose `box` for reactive watching
│   └── services/   # DatabaseService, CsvLoaderService, WifiSyncService
├── domain/
│   ├── providers/  # Riverpod providers (StreamProvider for Hive reactivity)
│   └── controllers/# Notifier<State> for complex screen logic
├── presentation/
│   ├── screens/    # Full-page views
│   ├── widgets/    # Reusable components
│   └── navigation/ # go_router config (app_router.dart)
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

## Exercise Library

Two sources combined into one library:

1. **CSV Library** (`exercises.csv`) - ~290 built-in exercises loaded at startup via `CsvLoaderService`
   - Format: `Name,Muscle Group,Equipment` (e.g., `Barbell Curl,Biceps,Barbell`)
   - Parsed into `ExerciseDefinition` (non-Hive, in-memory only)
2. **Custom Exercises** - User-created, stored in Hive via `CustomExerciseDefinition`
   - Has `@HiveType(typeId: 22)`, persists across sessions
   - Converts to `ExerciseDefinition` via `toExerciseDefinition()` for unified library access

Access combined list via `exerciseRepositoryProvider` which merges both sources.

## WiFi Sync & Sharing Architecture

Peer-to-peer sync/sharing between devices on same network using QR codes:

### Full Database Sync (`data/services/wifi_sync_service.dart`)

- `wifiSyncServiceProvider` - Full app data sync
- Uses `DataBackupService.exportToJson()` / `importFromJson()`

### Template Sharing (`data/services/template_share_service.dart`)

- `templateShareServiceProvider` - Share workout templates
- Route: `/template-share?templateId=xxx&autoStart=true`

### Theme Sharing (`data/services/skin_share_service.dart`)

- `skinShareServiceProvider` - Share custom themes with images
- Route: `/skin-share?skinId=xxx&autoStart=true`

**Common Pattern:**

1. **Host device** starts HTTP server via `shelf` package, generates QR code
2. **Client device** scans QR via `mobile_scanner`, connects and syncs
3. JSON payload includes `type` field (`wifi_sync`, `template_share`, `skin_share`) for routing

## State Management Patterns

### Reactive Hive via StreamProvider (domain/providers/)

```dart
// Pattern: Yield initial, then watch box changes
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) async* {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  yield repository.getAllSorted();
  await for (final _ in repository.box.watch()) { yield repository.getAllSorted(); }
});

// Parameterized access via Provider.family
final trainingCycleProvider = Provider.family<TrainingCycle?, String>((ref, id) => ...);
final workoutsByTrainingCycleProvider = Provider.family<List<Workout>, String>((ref, cycleId) => ...);
```

### Controller Pattern (domain/controllers/)

Complex screens use `Notifier<State>` with immutable state classes:

```dart
class WorkoutHomeState {
  final bool showPeriodSelector;
  final int? selectedPeriod;
  WorkoutHomeState copyWith({...}); // Always immutable
}

class WorkoutHomeController extends Notifier<WorkoutHomeState> {
  @override WorkoutHomeState build() => const WorkoutHomeState();
  // Access repos via ref.read(workoutRepositoryProvider)
}
```

### Repository Pattern (data/repositories/)

All repositories expose `box` property for reactive watching:

```dart
class WorkoutRepository {
  final Box<Workout> _box;
  Box<Workout> get box => _box; // Required for StreamProvider watching
}
```

## Code Generation

Files with `part '*.g.dart'` require regeneration after changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Affected files:**

- `data/models/*.dart` - Hive adapters
- `core/constants/enums.dart` - Enum adapters (ALL enums here)
- `core/theme/skins/skin_model.dart` - JSON serialization

## Sentry & Environment Configuration

Environment variables passed via `--dart-define` (see `core/env/env.dart`):

```bash
# Development (Sentry disabled)
flutter run --dart-define=SENTRY_ENABLED=false

# Production with Sentry
flutter run --dart-define=SENTRY_DSN=https://xxx@sentry.io/xxx \
            --dart-define=SENTRY_ENVIRONMENT=production \
            --dart-define=SENTRY_RELEASE=1.0.0+1
```

- `SentryService` (`core/services/sentry_service.dart`) - Singleton, initialized in `main.dart`
- `SentryConfig` (`core/config/sentry_config.dart`) - Centralized config with `shouldInitialize` check
- Uses `feedback_sentry` package for in-app user feedback via `BetterFeedback` widget

## Skin/Theme System

Located in `core/theme/skins/`:

- `SkinModel` - JSON-serializable config (`@JsonSerializable`)
- `SkinBuilder.buildTheme()` - Converts to `ThemeData`
- Built-in skins in `built_in_skins/`
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
  "recoveryPeriod": 5,
  "workouts": [
    {
      "periodNumber": 1,
      "dayNumber": 1,
      "dayName": "Day 1",
      "exercises": [
        {
          "name": "Bench Press",
          "muscleGroup": "chest", // Must match MuscleGroup enum
          "equipmentType": "barbell", // Must match EquipmentType enum
          "sets": 3,
          "reps": "8-12",
          "setType": "regular" // regular|myorep|myorepMatch|maxReps|endWithPartials
        }
      ]
    }
  ]
}
```

## Navigation

`go_router` in `presentation/navigation/app_router.dart`:

- Routes defined in `AppRoutes` class
- Onboarding redirect in router's `redirect` callback
- Pattern: `/trainingCycles/:trainingCycleId/workouts` for nested routes

## Common Commands

| Task           | Command                                                    |
| -------------- | ---------------------------------------------------------- |
| Run            | `flutter run`                                              |
| Regenerate     | `dart run build_runner build --delete-conflicting-outputs` |
| Test           | `flutter test`                                             |
| Build APK      | `flutter build apk --release`                              |
| Build iOS      | `flutter build ipa`                                        |
| Build Web      | `flutter build web`                                        |
| Disable Sentry | `flutter run --dart-define=SENTRY_ENABLED=false`           |

## Conventions

- **Enums**: ALL Hive-persisted enums in `core/constants/enums.dart` with `@HiveType` + `@HiveField`
- **Models**: Immutable with `copyWith()` methods, `@HiveType(typeId: X)` annotations
- **Providers**: Repository providers in `repository_providers.dart`, domain providers in separate files
- **Tests**: Wrap widgets in `ProviderScope`
- **IDs**: Use `uuid` package for generating unique IDs
