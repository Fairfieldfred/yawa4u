# YAWA4U - Copilot Instructions

## Project Overview

Flutter workout tracking app (iOS, Android, Web, macOS, Windows, Linux) using **Riverpod 3.0** for state management and **Drift** (SQLite) for local-first persistence. Core hierarchy: TrainingCycle → Period → Workout → Exercise → ExerciseSet.

For comprehensive data model documentation, see [data_structure.md](../data_structure.md).

## Architecture

```
lib/
├── core/           # Utilities, constants, theme system
│   ├── constants/  # enums.dart, muscle_groups.dart, equipment_types.dart
│   ├── env/        # env.dart (--dart-define variables)
│   ├── services/   # SentryService
│   └── theme/      # skins/ (theme system)
├── data/
│   ├── database/   # Drift: app_database.dart, tables.dart, daos/, mappers/
│   ├── models/     # Domain models (plain Dart classes)
│   ├── repositories/  # CRUD operations using DAOs
│   └── services/   # DatabaseService, CsvLoaderService, WifiSyncService
├── domain/
│   ├── providers/  # Riverpod providers (StreamProvider for reactivity)
│   └── controllers/# Notifier<State> for complex screen logic
├── presentation/
│   ├── screens/    # Full-page views
│   ├── widgets/    # Reusable components
│   └── navigation/ # go_router config (app_router.dart)
```

## ⚠️ Critical Domain Concepts

### Workout vs Training Day

The database stores **multiple `Workout` objects per training day** (one per muscle group). All workouts for the same day share `periodNumber` and `dayNumber`, differentiated by `label` (e.g., "Chest", "Back"). **Always aggregate** by `(periodNumber, dayNumber)` when displaying a day's workout.

### Periods vs Weeks

Uses "periods" (not weeks) for flexible schedules (8, 9, 10+ day cycles):

- `periodsTotal` / `daysPerPeriod` - Cycle structure
- `periodNumber` / `dayNumber` - Workout positioning (**1-indexed**)
- `recoveryPeriod` + `RecoveryPeriodType` - Optional deload/rest period

### Data Snapshot Warning

`TrainingCycle.workouts` is a **snapshot at creation**—always use `workoutsByTrainingCycleProvider(cycleId)` for current workout state.

## Drift Database Architecture

Database uses normalized relational schema with DAOs and mappers:

```
data/database/
├── app_database.dart       # @DriftDatabase definition
├── tables.dart             # Table definitions (TrainingCycles, Workouts, etc.)
├── converters.dart         # Enum → int converters
├── daos/                   # One DAO per table (TrainingCycleDao, WorkoutDao...)
└── mappers/                # entity_mappers.dart - Row → Model conversion
```

**Loading hierarchy (repositories handle this automatically):**

```
TrainingCycle → Workouts → Exercises → ExerciseSets → ExerciseFeedback
```

## State Management Patterns

### Reactive Drift via StreamProvider

```dart
// Watch Drift streams for reactive updates
final workoutsProvider = StreamProvider<List<Workout>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.watchAll();
});

// Parameterized access via Provider.family
final workoutsByTrainingCycleProvider = StreamProvider.family<List<Workout>, String>((ref, cycleId) {
  return ref.watch(workoutRepositoryProvider).watchByTrainingCycleId(cycleId);
});
```

### Provider Dependency Chain

```dart
// DAOs from database → Repositories from DAOs → Domain providers from repositories
appDatabaseProvider → trainingCycleDaoProvider → trainingCycleRepositoryProvider → trainingCyclesProvider
```

### Controller Pattern

Complex screens use `Notifier<State>` with immutable state classes (see `domain/controllers/`):

```dart
class WorkoutHomeController extends Notifier<WorkoutHomeState> {
  @override WorkoutHomeState build() => const WorkoutHomeState();
  // Access repos via ref.read(workoutRepositoryProvider)
}
```

## Exercise Library

1. **CSV Library** (`exercises.csv`) - ~290 built-in exercises, loaded via `CsvLoaderService`
2. **Custom Exercises** - User-created, stored in Drift via `CustomExerciseDefinition`

Access combined list via `exerciseLibraryProvider`.

## WiFi Sync & Sharing Architecture

Peer-to-peer sync/sharing between devices on same network using QR codes. All services follow the same pattern:

| Service          | Provider                       | Route                            |
| ---------------- | ------------------------------ | -------------------------------- |
| Full Database    | `wifiSyncServiceProvider`      | N/A (manual trigger)             |
| Template Sharing | `templateShareServiceProvider` | `/template-share?templateId=xxx` |
| Theme Sharing    | `skinShareServiceProvider`     | `/skin-share?skinId=xxx`         |

**Pattern:** Host starts `shelf` HTTP server → generates QR code with `{ip, port, code}` → Client scans via `mobile_scanner` → JSON payload with `type` field routes to handler

Key files:

- `data/services/wifi_sync_service.dart` - Full database sync
- `data/services/template_share_service.dart` - Template sharing
- `data/services/skin_share_service.dart` - Theme sharing

## Template Authoring

Templates in `assets/templates/*.json` auto-discovered via AssetManifest:

```json
{
  "id": "unique_id",
  "name": "Template Name",
  "description": "Optional description",
  "periodsTotal": 6,
  "daysPerPeriod": 4,
  "recoveryPeriod": 7,
  "workouts": [
    {
      "periodNumber": 1,
      "dayNumber": 1,
      "dayName": "Monday - Upper",
      "exercises": [
        {
          "name": "Bench Press",
          "muscleGroup": "chest",
          "equipmentType": "barbell",
          "sets": 4,
          "reps": "6-10",
          "setType": "regular"
        }
      ]
    }
  ]
}
```

**Enum values (lowercase):**

- `muscleGroup`: chest, back, shoulders, biceps, triceps, quads, hamstrings, glutes, calves, traps, forearms, abs
- `equipmentType`: barbell, dumbbells, cable, machine, bodyweight, smithMachine, other
- `setType`: regular, myorep, myorepMatch, maxReps, endWithPartials, dropSet

## Skin/Theme System

Located in `core/theme/skins/`:

- `SkinModel` - JSON-serializable config (`@JsonSerializable`)
- `SkinBuilder.buildTheme()` - Converts `SkinModel` to `ThemeData`
- Built-in skins in `built_in_skins/`
- Access: `Theme.of(context).extension<SkinExtension>()`
- Colors stored as hex strings, parsed via `SkinColors.parseHex()`

## Firebase Analytics

`AnalyticsService` (`data/services/analytics_service.dart`) wraps Firebase Analytics with privacy-first design—**never track personal data or workout performance metrics**.

### Event Categories (defined in `core/constants/app_constants.dart`)

| Category      | Events                                                                                               |
| ------------- | ---------------------------------------------------------------------------------------------------- |
| TrainingCycle | `trainingCycle_created`, `trainingCycle_started`, `trainingCycle_completed`, `trainingCycle_deleted` |
| Workout       | `workout_completed`, `workout_skipped`                                                               |
| Template      | `template_used`                                                                                      |
| Features      | `feedback_logged`, `myorep_set_used`                                                                 |
| Data          | `data_exported`, `data_imported`                                                                     |

### Usage Pattern

```dart
final analytics = AnalyticsService();
await analytics.logWorkoutCompleted(
  periodNumber: workout.periodNumber,
  dayNumber: workout.dayNumber,
  exerciseCount: workout.exercises.length,
  hadMyorepSets: workout.hasMyorepSets,
);
```

**Note:** All analytics calls wrap in try/catch and report errors to Sentry silently.

## Sentry Error Reporting

`SentryService` (`core/services/sentry_service.dart`) manages error reporting with debug support.

### Configuration

- DSN via `--dart-define=SENTRY_DSN=https://...`
- Environment auto-detected: `debug`, `profile`, or `release`
- PII disabled (`sendDefaultPii: false`)
- Uses `feedback_sentry` for in-app user feedback via `BetterFeedback` wrapper

### Usage Pattern

```dart
// Automatic error capture (most errors caught automatically)
Sentry.captureException(error, stackTrace: stackTrace);

// Manual breadcrumbs for context
Sentry.addBreadcrumb(Breadcrumb(
  message: 'User started workout',
  category: 'navigation',
));

// User feedback (via BetterFeedback widget in main.dart)
BetterFeedback.of(context).show((feedback) => ...);
```

## Onboarding System

### Flow Control

`OnboardingService` (`data/services/onboarding_service.dart`) manages user setup state via SharedPreferences:

- `isOnboardingComplete` - Gates access to main app (checked in router redirect)
- `isFirstTimeUser` - Whether user has created their first training cycle

### User Profile Storage (SharedPreferences keys)

| Property           | Key                        | Type           |
| ------------------ | -------------------------- | -------------- |
| Height             | `user_height_cm`           | `double`       |
| Weight             | `user_weight_kg`           | `double`       |
| Metric/Imperial    | `user_use_metric`          | `bool`         |
| Body Fat %         | `user_body_fat_percent`    | `double?`      |
| Lean Mass          | `user_lean_mass_kg`        | `double?`      |
| Equipment          | `user_equipment`           | `List<String>` |
| Equipment Filter   | `equipment_filter_enabled` | `bool`         |
| TrainingCycle Term | `user_training_cycle_term` | `String`       |
| App Icon           | `user_app_icon_index`      | `int`          |

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

## Code Generation

**Run after modifying Drift tables, DAOs, or JSON-serializable classes:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Affected files:**

- `data/database/app_database.dart` → `app_database.g.dart`
- `data/models/*.dart` with `part '*.g.dart'`
- `core/theme/skins/skin_model.dart` - JSON serialization

## Navigation

`go_router` in `presentation/navigation/app_router.dart`:

- Routes in `AppRoutes` class constants
- Onboarding redirect via `redirect` callback
- Pattern: `/trainingCycles/:trainingCycleId/workouts`

## Initialization (main.dart)

```dart
// Critical initialization order
await DatabaseService().initialize();      // Drift database
await SkinRepository().initialize(prefs);  // Theme system
await CsvLoaderService().loadExercises();  // Exercise library

ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
  child: const MyApp(),
)
```

## Common Commands

| Task            | Command                                                    |
| --------------- | ---------------------------------------------------------- |
| Run             | `flutter run`                                              |
| Regenerate code | `dart run build_runner build --delete-conflicting-outputs` |
| Test            | `flutter test`                                             |
| Build APK       | `flutter build apk --release`                              |
| Build iOS       | `flutter build ipa`                                        |
| Build Web       | `flutter build web`                                        |
| Sentry build    | `flutter run --dart-define=SENTRY_DSN=https://...`         |

## Conventions

- **Enums**: All in `core/constants/enums.dart` with extension methods for `displayName`
- **Models**: Immutable with `copyWith()`, ID via `uuid` package
- **Providers**: DAO providers → Repository providers → Domain providers (in `domain/providers/`)
- **Mappers**: Convert Drift rows to domain models in `data/database/mappers/`
- **Tests**: Wrap widgets in `ProviderScope`, use `AppDatabase.forTesting()` for in-memory DB

## Quick Provider Reference

| To find...            | Use provider...                            |
| --------------------- | ------------------------------------------ |
| All training cycles   | `trainingCyclesProvider`                   |
| Single training cycle | `trainingCycleProvider(id)`                |
| Workouts for a cycle  | `workoutsByTrainingCycleProvider(cycleId)` |
| Single workout        | `workoutProvider(id)`                      |
| Exercise library      | `exerciseLibraryProvider`                  |
| Current theme         | `skinProvider`                             |
| WiFi Sync service     | `wifiSyncServiceProvider`                  |
| Template sharing      | `templateShareServiceProvider`             |
| Onboarding state      | `onboardingServiceProvider`                |

## Testing Patterns

### Widget Test Setup

Always wrap widgets in `ProviderScope` with required overrides:

```dart
testWidgets('example test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        appDatabaseProvider.overrideWithValue(AppDatabase.forTesting(NativeDatabase.memory())),
      ],
      child: const MaterialApp(home: MyWidget()),
    ),
  );
});
```

### Database Testing

Use in-memory database for tests:

```dart
final db = AppDatabase.forTesting(NativeDatabase.memory());
```

### Test File Location

Tests in `test/` directory. Name convention: `*_test.dart`
