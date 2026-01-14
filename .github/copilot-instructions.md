# YAWA4U - Copilot Instructions

## Project Overview

Flutter workout tracking app (iOS, Android, Web, macOS, Windows, Linux) using **Riverpod 3.0** for state management and **Hive** for local-first persistence. Core hierarchy: TrainingCycle → Period → Workout → Exercise → ExerciseSet.

For comprehensive data model documentation including relationships and field details, see [data_structure.md](../data_structure.md).

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

The database stores **multiple `Workout` objects per training day** (one per muscle group). All workouts for the same day share `periodNumber` and `dayNumber`, differentiated by `label` (e.g., "Chest", "Back"). **Always aggregate** all `Workout` objects when displaying a day's workout to users.

### Periods vs Weeks

Uses "periods" (not weeks) for flexible schedules (8, 9, 10+ day cycles):

- `periodsTotal` / `daysPerPeriod` - Cycle structure (uniform)
- `periodNumber` / `dayNumber` - Workout positioning (**1-indexed**)
- `recoveryPeriod` + `RecoveryPeriodType` - Optional deload/rest period

### Data Snapshot Warning

`TrainingCycle.workouts` is a **snapshot at creation**—always use `workoutsByTrainingCycleProvider(cycleId)` for current workout state.

## State Management Patterns

### Reactive Hive via StreamProvider

All data providers follow this pattern in `domain/providers/`:

```dart
// Yield initial data, then watch for Hive box changes
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) async* {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  yield repository.getAllSorted();
  await for (final _ in repository.box.watch()) { yield repository.getAllSorted(); }
});
```

**Parameterized access** via `Provider.family`:

- `trainingCycleProvider(id)` - Single training cycle by ID
- `workoutsByTrainingCycleProvider(cycleId)` - All workouts for a cycle

### Controller Pattern

Complex screens use `Notifier<State>` with **immutable state classes** (see `domain/controllers/workout_home_controller.dart`):

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

### Repository Pattern

All repositories **must expose** `box` property for reactive watching:

```dart
class WorkoutRepository {
  final Box<Workout> _box;
  Box<Workout> get box => _box; // Required for StreamProvider watching
}
```

## Exercise Library

Two sources combined into one unified library:

1. **CSV Library** (`exercises.csv`) - ~290 built-in exercises loaded at startup via `CsvLoaderService`
   - Format: `Name,Muscle Group,Equipment` (e.g., `Barbell Curl,Biceps,Barbell`)
   - Parsed into `ExerciseDefinition` (non-Hive, in-memory only)
2. **Custom Exercises** - User-created, stored in Hive via `CustomExerciseDefinition`
   - Has `@HiveType(typeId: 22)`, persists across sessions
   - Converts to `ExerciseDefinition` via `toExerciseDefinition()`

Access combined list via `exerciseRepositoryProvider`.

## WiFi Sync & Sharing Architecture

Peer-to-peer sync/sharing between devices on same network using QR codes. All three services follow the same pattern:

| Service          | Provider                       | Route                            |
| ---------------- | ------------------------------ | -------------------------------- |
| Full Database    | `wifiSyncServiceProvider`      | N/A (manual trigger)             |
| Template Sharing | `templateShareServiceProvider` | `/template-share?templateId=xxx` |
| Theme Sharing    | `skinShareServiceProvider`     | `/skin-share?skinId=xxx`         |

**Pattern:** Host starts `shelf` HTTP server → generates QR code → Client scans via `mobile_scanner` → JSON payload with `type` field routes to handler

## Code Generation

**Run after modifying any file with `part '*.g.dart'`:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Affected files:**

- `data/models/*.dart` - Hive type adapters
- `core/constants/enums.dart` - ALL Hive-persisted enum adapters
- `core/theme/skins/skin_model.dart` - JSON serialization

## Skin/Theme System

Located in `core/theme/skins/`:

- `SkinModel` - JSON-serializable config (`@JsonSerializable`)
- `SkinBuilder.buildTheme()` - Converts `SkinModel` to `ThemeData`
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
          "muscleGroup": "chest", // Must match MuscleGroup enum (lowercase)
          "equipmentType": "barbell", // Must match EquipmentType enum (lowercase)
          "sets": 3,
          "reps": "8-12",
          "setType": "regular" // regular|myorep|myorepMatch|maxReps|endWithPartials|dropSet
        }
      ]
    }
  ]
}
```

## Navigation

`go_router` in `presentation/navigation/app_router.dart`:

- Routes in `AppRoutes` class constants
- Onboarding redirect via `redirect` callback
- Pattern: `/trainingCycles/:trainingCycleId/workouts` for nested routes

## Environment & Sentry

Environment variables via `--dart-define` (see `core/env/env.dart`):

```bash
# Development (faster, no Sentry)
flutter run

# Production with Sentry
flutter run --dart-define=SENTRY_DSN=https://xxx@sentry.io/xxx
```

Uses `feedback_sentry` package for in-app user feedback via `BetterFeedback` widget wrapper in `main.dart`.

## Firebase Analytics

`AnalyticsService` (`data/services/analytics_service.dart`) wraps Firebase Analytics with privacy-first design—**never track personal data or workout performance metrics**.

### Event Categories (defined in `core/constants/app_constants.dart`)

| Category      | Events                                                                                               |
| ------------- | ---------------------------------------------------------------------------------------------------- |
| TrainingCycle | `trainingCycle_created`, `trainingCycle_started`, `trainingCycle_completed`, `trainingCycle_deleted` |
| Workout       | `workout_completed`, `workout_skipped`, `workout_reset`                                              |
| Exercise      | `exercise_added_to_workout`, `exercise_removed_from_workout`, `exercise_replaced`                    |
| Template      | `template_viewed`, `template_used`, `template_filter_applied`                                        |
| Features      | `set_logged`, `myorep_set_used`, `feedback_logged`, `filter_used`                                    |
| Data          | `data_exported`, `data_imported`, `data_shared`                                                      |

### Usage Pattern

```dart
final analytics = ref.read(analyticsServiceProvider);
await analytics.logWorkoutCompleted(
  periodNumber: workout.periodNumber,
  dayNumber: workout.dayNumber,
  exerciseCount: workout.exercises.length,
  hadMyorepSets: workout.hasMyorepSets,
);
```

**Note:** All analytics calls wrap in try/catch and report errors to Sentry silently.

## Body Measurements (UserMeasurement)

`UserMeasurement` model (`data/models/user_measurement.dart`, typeId: 24) tracks body composition over time:

- **Required:** `heightCm`, `weightKg`, `timestamp`
- **Optional:** `bodyFatPercent`, `leanMassKg` (from DEXA scans), `notes`
- **Computed:** `bmi`, `calculatedLeanMassKg`, `fatMassKg`

Access via `userMeasurementRepositoryProvider`. User's current height/weight also stored in `OnboardingService` for quick access.

## Onboarding System

### Flow Control

`OnboardingService` (`data/services/onboarding_service.dart`) manages user setup state via SharedPreferences:

- `isOnboardingComplete` - Gates access to main app (checked in router redirect)
- `isFirstTimeUser` - Whether user has created their first training cycle

### User Profile Storage

Onboarding captures and persists:

- Body metrics: `heightCm`, `weightKg`, `bodyFatPercent`, `leanMassKg`, `useMetric`
- Equipment: `equipment` (list), `equipmentFilterEnabled`
- Preferences: `trainingCycleTerm`, `appIconIndex`

### Router Integration

The `go_router` redirect in `app_router.dart` enforces onboarding:

```dart
redirect: (context, state) {
  final isOnboardingComplete = ref.read(onboardingServiceProvider).isOnboardingComplete;
  if (!isOnboardingComplete && !state.matchedLocation.startsWith('/onboarding')) {
    return AppRoutes.onboarding;
  }
  return null;
}
```

### Provider Override Pattern

`SharedPreferences` must be initialized before `ProviderScope` in `main.dart`:

```dart
final sharedPrefs = await SharedPreferences.getInstance();
ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
  child: const MyApp(),
)
```

## Testing Patterns

### Widget Test Setup

Always wrap widgets in `ProviderScope` with required overrides:

```dart
testWidgets('example test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        // Override repository providers with test data
      ],
      child: const MaterialApp(home: MyWidget()),
    ),
  );
});
```

### Repository Mocking Strategy

Since repositories depend on Hive boxes, prefer:

1. Create in-memory Hive boxes for integration tests
2. Override repository providers with mock implementations for unit tests
3. Use `TemplateRepository` pattern (no Hive dependency) for template-related tests

### Test File Location

Tests in `test/` directory. Name convention: `*_test.dart`

## Common Commands

| Task            | Command                                                    |
| --------------- | ---------------------------------------------------------- |
| Run             | `flutter run`                                              |
| Regenerate code | `dart run build_runner build --delete-conflicting-outputs` |
| Test            | `flutter test`                                             |
| Build APK       | `flutter build apk --release`                              |
| Build iOS       | `flutter build ipa`                                        |
| Build Web       | `flutter build web`                                        |

## Conventions

- **Enums**: ALL Hive-persisted enums in `core/constants/enums.dart` with `@HiveType` + `@HiveField` on each value
- **Models**: Immutable with `copyWith()`, `@HiveType(typeId: X)` annotations, ID via `uuid` package
- **Providers**: Repository providers in `repository_providers.dart`, domain providers in separate files by feature
- **Tests**: Wrap widgets in `ProviderScope` for Riverpod access
- **Hive TypeIds**: Check `DatabaseService` for registered adapters before adding new models
