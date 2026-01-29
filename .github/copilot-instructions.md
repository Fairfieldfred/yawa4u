# YAWA4U - Copilot Instructions

Flutter workout tracking app using **Riverpod 3.0** + **Drift** (SQLite). Targets iOS, Android, Web, macOS, Windows, Linux.

## Architecture Overview

```
lib/
├── core/           # Constants (enums.dart), theme system (skins/), services
├── data/
│   ├── database/   # Drift: tables.dart, daos/, mappers/
│   ├── models/     # Domain models (immutable, copyWith, uuid IDs)
│   ├── repositories/  # CRUD via DAOs, loads full hierarchy
│   └── services/   # DatabaseService, CsvLoaderService, WifiSyncService
├── domain/
│   ├── providers/  # StreamProvider for reactivity, Provider.family for params
│   └── controllers/# Notifier<State> for complex screens
├── presentation/   # screens/, widgets/, navigation/ (go_router)
```

## ⚠️ Critical Domain Concepts

**Workout vs Training Day**: Database stores **multiple Workout objects per day** (one per muscle group). All share `periodNumber`/`dayNumber`, differ by `label`. Always aggregate by `(periodNumber, dayNumber)` for display.

**Periods not Weeks**: Supports flexible schedules (8, 9, 10+ day cycles). Fields: `periodsTotal`, `daysPerPeriod`, `periodNumber`, `dayNumber` (all **1-indexed**).

**Stale Snapshot**: `TrainingCycle.workouts` is snapshot at creation—use `workoutsByTrainingCycleProvider(cycleId)` for current state.

## State Management Pattern

```dart
// Provider chain: Database → DAO → Repository → Domain Provider
appDatabaseProvider → workoutDaoProvider → workoutRepositoryProvider → workoutsProvider

// Reactive streams for UI
final workoutsProvider = StreamProvider<List<Workout>>((ref) {
  return ref.watch(workoutRepositoryProvider).watchAll();
});

// Parameterized access
final workoutsByTrainingCycleProvider = StreamProvider.family<List<Workout>, String>((ref, cycleId) {
  return ref.watch(workoutRepositoryProvider).watchByTrainingCycleId(cycleId);
});
```

## Code Generation

**Run after modifying Drift tables, DAOs, or `@JsonSerializable` classes:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Template JSON Format

Templates in `assets/templates/*.json`:
```json
{
  "id": "unique_id", "name": "Template Name", "periodsTotal": 6, "daysPerPeriod": 4,
  "workouts": [{
    "periodNumber": 1, "dayNumber": 1, "dayName": "Push Day",
    "exercises": [{ "name": "Bench Press", "muscleGroup": "chest", "equipmentType": "barbell", "sets": 4, "reps": "6-10", "setType": "regular" }]
  }]
}
```
**Enums (lowercase)**: `muscleGroup`: chest, back, shoulders, biceps, triceps, quads, hamstrings, glutes, calves, traps, forearms, abs | `equipmentType`: barbell, dumbbells, cable, machine, bodyweight, smithMachine, other | `setType`: regular, myorep, myorepMatch, maxReps, endWithPartials, dropSet

## Key Files Reference

| Purpose | Location |
|---------|----------|
| All enums | `core/constants/enums.dart` (with `displayName` extensions) |
| Database tables | `data/database/tables.dart` |
| Row→Model conversion | `data/database/mappers/entity_mappers.dart` |
| Router + onboarding redirect | `presentation/navigation/app_router.dart` |
| Theme system | `core/theme/skins/` (SkinModel, SkinBuilder) |
| WiFi sync/sharing | `data/services/{wifi_sync,template_share,skin_share}_service.dart` |

## Testing

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

## Quick Reference

| Command | Purpose |
|---------|---------|
| `flutter run` | Run app |
| `dart run build_runner build --delete-conflicting-outputs` | Regenerate Drift/JSON code |
| `flutter test` | Run tests |
| `flutter run --dart-define=SENTRY_DSN=https://...` | Run with Sentry |

## Additional Documentation

- [data_structure.md](../data_structure.md) - Detailed data models, Drift schema, and provider reference
- [BUILD_PLAN.md](../BUILD_PLAN.md) - Feature roadmap, implementation plans, and development priorities
