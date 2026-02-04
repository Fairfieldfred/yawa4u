# YAWA4U - Copilot Instructions

Flutter workout tracking app using **Riverpod 3.0** + **Drift** (SQLite). Multi-platform: iOS, Android, Web, macOS, Windows, Linux.

## ⚠️ Critical Domain Concepts (Read First!)

**Workout vs Training Day**: Database stores **MULTIPLE `Workout` objects per day** (one per muscle group). All share `periodNumber`/`dayNumber`, differ by `label`. Always aggregate by `(periodNumber, dayNumber)` for display—this is the #1 source of bugs.

```dart
// WRONG: Treating each Workout as a full training day
// CORRECT: Group workouts by (periodNumber, dayNumber) to get a complete day
final dayWorkouts = workouts.where((w) => w.periodNumber == period && w.dayNumber == day);
```

**Periods not Weeks**: Uses flexible training schedules (can be 8, 9, 10+ day cycles). Key fields: `periodsTotal`, `daysPerPeriod`, `periodNumber`, `dayNumber`—all **1-indexed**.

**Stale Snapshot Trap**: `TrainingCycle.workouts` is a snapshot populated at creation time. Always use providers for current state:

```dart
// ✅ CORRECT - always current
final workouts = ref.watch(workoutsByTrainingCycleProvider(cycleId));
// ❌ AVOID - may be stale
final workouts = trainingCycle.workouts;
```

## Architecture & Data Flow

```
lib/
├── core/           # Enums (with displayName extensions), theme skins, utils
├── data/
│   ├── database/   # Drift: tables.dart → daos/ → mappers/entity_mappers.dart
│   ├── models/     # Immutable domain models with copyWith, uuid IDs
│   ├── repositories/  # Loads full hierarchy (workout → exercises → sets)
│   └── services/   # DatabaseService, WifiSyncService, ThemeImageService
├── domain/
│   ├── providers/  # StreamProvider for reactivity, Provider.family for params
│   └── controllers/# Notifier<State> for complex screen logic
├── presentation/   # screens/, widgets/, navigation/ (go_router)
```

**Provider Chain**: `appDatabaseProvider → {dao}Provider → {repository}Provider → domain StreamProvider`

**Hierarchy Loading**: Repositories auto-load nested data:

```dart
// WorkoutRepository._mapRowToWorkout automatically loads:
// workout → exercises → sets (complete hierarchy in one call)
```

## Provider Patterns

| Pattern                 | Use When                                  | Example                                                              |
| ----------------------- | ----------------------------------------- | -------------------------------------------------------------------- |
| `StreamProvider`        | Reactive data from DB (auto-updates UI)   | `trainingCyclesProvider` watches `repository.watchAll()`             |
| `Provider`              | Derived/filtered data from StreamProvider | `currentTrainingCycleProvider` filters from `trainingCyclesProvider` |
| `Provider.family`       | Need parameter (ID, filter)               | `workoutsByTrainingCycleProvider(cycleId)`                           |
| `FutureProvider.family` | One-time async fetch with param           | `workoutsByPeriodProvider((cycleId: id, periodNumber: 1))`           |
| `Notifier<State>`       | Complex UI state + business logic         | `WorkoutHomeController` manages selection, set logging               |

```dart
// StreamProvider for reactive lists
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) {
  return ref.watch(trainingCycleRepositoryProvider).watchAll();
});

// Provider.family for parameterized access
final trainingCycleProvider = Provider.family<TrainingCycle?, String>((ref, id) {
  return ref.watch(trainingCyclesProvider).valueOrNull?.firstWhere((m) => m.id == id);
});
```

## Code Patterns

**Models**: Immutable with `copyWith()`. Mutations return new instances:

```dart
final updated = workout.addExercise(exercise);  // Returns NEW Workout
await repository.update(updated);               // Persist to database
```

**Enums**: All in [core/constants/enums.dart](lib/core/constants/enums.dart) with `displayName`, `badge`, and boolean getters:

```dart
SetType.myorep.displayName  // "Myorep"
SetType.myorep.badge        // "M"
SetType.regular.isRegular   // true
```

**Theme images**: Store **relative paths** (e.g., `themes/{id}/workout.jpg`), resolve at runtime via `ThemeImageService.resolveImagePath()`. Asset paths starting with `assets/` use `Image.asset()` directly. This prevents iOS container ID breakage on app updates.

## Navigation (go_router)

**Onboarding redirect**: Router checks `onboardingServiceProvider.isOnboardingComplete` and redirects to `/onboarding` if false.

**Path parameters**: Use `state.pathParameters['id']` for route params:

```dart
GoRoute(
  path: '/trainingCycles/:trainingCycleId/workouts',
  builder: (context, state) {
    final cycleId = state.pathParameters['trainingCycleId']!;
    return EditWorkoutScreen(trainingCycleId: cycleId);
  },
)
```

## WiFi Sync & Data Backup

**WifiSyncService**: P2P sync via local HTTP server (shelf). Host generates QR code with `{ip, port, code}`, client scans to connect.

**DataBackupService**: JSON export/import of all data. Version field (`version: 3`) for migration compatibility. Custom themes include Base64-encoded images.

```dart
// Export
final json = await dataBackupService.exportToJson(includeThemes: true);
// Import
final result = await dataBackupService.importFromJson(json, replace: false);
```

## Theme/Skin System

**SkinModel**: JSON-serializable theme config with colors, backgrounds, muscle group colors.  
**SkinRepository**: Manages built-in + custom skins via SharedPreferences.  
**ThemeImageService**: Handles image compression, storage, and path resolution for custom themes.

```dart
// Get active skin
final skin = ref.watch(skinProvider);
// Change skin
await skinRepository.setActiveSkinId(skinId);
```

## Commands

| Command                                                    | Purpose                                                                         |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `flutter run`                                              | Run app                                                                         |
| `dart run build_runner build --delete-conflicting-outputs` | **Required** after modifying Drift tables, DAOs, or `@JsonSerializable` classes |
| `flutter test`                                             | Run tests                                                                       |

## Testing Patterns

**Widget test with provider overrides**:

```dart
testWidgets('example', (tester) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(mockPrefs),
      appDatabaseProvider.overrideWithValue(AppDatabase.forTesting(NativeDatabase.memory())),
    ],
    child: const MaterialApp(home: MyWidget()),
  ));
});
```

**Unit test for repository logic** (no mocking needed for pure logic):

```dart
test('createTrainingCycleFromTemplate splits workouts by muscle group', () async {
  final repository = TemplateRepository();
  final template = TrainingCycleTemplate(/* ... */);
  final cycle = await repository.createTrainingCycleFromTemplate(template);

  // Verify muscle groups split into separate Workout objects
  expect(cycle.workouts.where((w) => w.label == 'Chest').length, 1);
  expect(cycle.workouts.where((w) => w.label == 'Back').length, 1);
});
```

**Testing controllers**: Override the repository provider, test state changes:

```dart
final container = ProviderContainer(overrides: [
  workoutRepositoryProvider.overrideWithValue(mockRepo),
]);
final controller = container.read(workoutHomeControllerProvider.notifier);
controller.selectDay(1, 2);
expect(container.read(workoutHomeControllerProvider).selectedDay, 2);
```

## Template JSON Format (`assets/templates/*.json`)

```json
{
  "id": "unique_id",
  "name": "Template Name",
  "periodsTotal": 6,
  "daysPerPeriod": 4,
  "workouts": [
    {
      "periodNumber": 1,
      "dayNumber": 1,
      "dayName": "Push Day",
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

**Enum values (lowercase)**: `muscleGroup`: chest, back, shoulders, biceps, triceps, quads, hamstrings, glutes, calves, traps, forearms, abs | `equipmentType`: barbell, dumbbells, cable, machine, bodyweight, smithMachine, other | `setType`: regular, myorep, myorepMatch, maxReps, endWithPartials, dropSet

## Key Files Reference

| Purpose                      | Location                                                                                               |
| ---------------------------- | ------------------------------------------------------------------------------------------------------ |
| All enums + extensions       | [core/constants/enums.dart](lib/core/constants/enums.dart)                                             |
| Database tables              | [data/database/tables.dart](lib/data/database/tables.dart)                                             |
| Row↔Model conversion         | [data/database/mappers/entity_mappers.dart](lib/data/database/mappers/entity_mappers.dart)             |
| Main screen controller       | [domain/controllers/workout_home_controller.dart](lib/domain/controllers/workout_home_controller.dart) |
| Provider definitions         | [domain/providers/](lib/domain/providers/)                                                             |
| Router + onboarding redirect | [presentation/navigation/app_router.dart](lib/presentation/navigation/app_router.dart)                 |
| Theme/skin system            | [core/theme/skins/](lib/core/theme/skins/)                                                             |
| WiFi sync                    | [data/services/wifi_sync_service.dart](lib/data/services/wifi_sync_service.dart)                       |
| Data backup/export           | [data/services/data_backup_service.dart](lib/data/services/data_backup_service.dart)                   |

## Additional Documentation

**📖 [data_structure.md](../data_structure.md)** - Essential reading for understanding:

- Full Drift schema and table relationships
- Detailed provider reference with all available providers
- iOS path handling lessons (why relative paths matter)
- Workout vs Training Day distinction with code examples

**📖 [BUILD_PLAN.md](../BUILD_PLAN.md)** - Feature roadmap, UI specifications, and implementation details
