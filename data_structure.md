# YAWA4U Data Structure Reference

Quick reference for the app's data models, Hive database structure, and state management patterns.

---

## Hive Database Boxes

| Box Name | Model Type | TypeId | Purpose |
|----------|-----------|--------|---------|
| `trainingCycles` | `TrainingCycle` | 104 | Training program definitions |
| `workouts` | `Workout` | 103 | Individual workout sessions |
| `exercises` | `Exercise` | 2 | Exercise instances in workouts |
| `exerciseSets` | `ExerciseSet` | 0 | Set data (weight, reps, etc.) |
| `exerciseFeedback` | `ExerciseFeedback` | 1 | Post-exercise feedback |
| `customExercises` | `CustomExerciseDefinition` | 22 | User-created exercises |
| `skins` | `SkinModel` | 20 | Custom themes |
| `templates` | `Template` | 105 | Workout templates |

---

## Core Data Models

### TrainingCycle (TypeId: 104)
The top-level container for a training program.

```dart
@HiveType(typeId: 104)
class TrainingCycle {
  @HiveField(0) String id;
  @HiveField(1) String name;
  @HiveField(2) int periodsTotal;        // Number of periods (not weeks!)
  @HiveField(3) int daysPerPeriod;       // Days per period (e.g., 8, 9, 10)
  @HiveField(4) int? recoveryPeriod;     // Optional deload period length
  @HiveField(5) RecoveryPeriodType? recoveryPeriodType;
  @HiveField(6) TrainingCycleStatus status;
  @HiveField(7) DateTime createdDate;
  @HiveField(8) DateTime? startDate;
  @HiveField(9) DateTime? endDate;
  @HiveField(10) List<Workout> workouts; // ⚠️ SNAPSHOT - see warning below
}
```

### Workout (TypeId: 103)
A single workout session for ONE muscle group on a specific day.

```dart
@HiveType(typeId: 103)
class Workout {
  @HiveField(0) String id;
  @HiveField(1) String trainingCycleId;
  @HiveField(2) int periodNumber;        // 1-indexed period
  @HiveField(3) int dayNumber;           // 1-indexed day within period
  @HiveField(4) String? dayName;         // e.g., "Push Day"
  @HiveField(5) String label;            // Muscle group identifier
  @HiveField(6) WorkoutStatus status;
  @HiveField(7) DateTime? completedDate;
  @HiveField(8) String? notes;
  @HiveField(9) List<Exercise> exercises;
}
```

### Exercise (TypeId: 2)
An exercise instance within a workout.

```dart
@HiveType(typeId: 2)
class Exercise {
  @HiveField(0) String id;
  @HiveField(1) String workoutId;
  @HiveField(2) String name;
  @HiveField(3) MuscleGroup muscleGroup;
  @HiveField(4) EquipmentType equipmentType;
  @HiveField(5) List<ExerciseSet> sets;
  @HiveField(6) int orderIndex;
  @HiveField(7) double? bodyweight;
  @HiveField(8) String? notes;
  @HiveField(9) ExerciseFeedback? feedback;
}
```

### ExerciseSet (TypeId: 0)
Individual set data within an exercise.

```dart
@HiveType(typeId: 0)
class ExerciseSet {
  @HiveField(0) String id;
  @HiveField(1) int setNumber;
  @HiveField(2) double? weight;
  @HiveField(3) String? reps;            // String to support "8-12" or "2 RIR"
  @HiveField(4) SetType setType;
  @HiveField(5) bool isLogged;
  @HiveField(6) String? notes;
  @HiveField(7) double? previousWeight;
  @HiveField(8) String? previousReps;
}
```

---

## ⚠️ Critical Concepts

### Workout vs Training Day

**The database stores MULTIPLE `Workout` objects per training day** (one per muscle group).

All workouts for the same day share:
- Same `periodNumber`
- Same `dayNumber`
- Same `dayName`

They differ by `label` (muscle group identifier).

**Example:** A "Push Day" might have 3 Workout objects:
- Workout 1: `label: "Chest"`, `dayNumber: 1`
- Workout 2: `label: "Shoulders"`, `dayNumber: 1`
- Workout 3: `label: "Triceps"`, `dayNumber: 1`

**Always aggregate workouts by `(periodNumber, dayNumber)` when displaying a day's workout to users.**

### Periods vs Weeks

The app uses **"periods"** instead of "weeks" to support flexible training schedules:

| Field | Purpose |
|-------|---------|
| `periodsTotal` | Total number of periods in the cycle |
| `daysPerPeriod` | Training days per period (can be 8, 9, 10+) |
| `periodNumber` | Which period (1-indexed) |
| `dayNumber` | Which day within the period (1-indexed) |

### TrainingCycle.workouts is a SNAPSHOT

`TrainingCycle.workouts` is populated at creation time and may become stale.

**Always use the provider for current workout state:**
```dart
// ✅ Correct - always current
final workouts = ref.watch(workoutsByTrainingCycleProvider(cycleId));

// ❌ Avoid - may be stale
final workouts = trainingCycle.workouts;
```

---

## Enums (All in `core/constants/enums.dart`)

| Enum | TypeId | Values |
|------|--------|--------|
| `SetType` | 10 | regular, myorep, myorepMatch, maxReps, endWithPartials |
| `JointPain` | 11 | none, low, moderate, severe |
| `MusclePump` | 12 | low, moderate, amazing |
| `Workload` | 13 | easy, prettyGood, pushedLimits, tooMuch |
| `Soreness` | 14 | neverGotSore, healedAWhileAgo, healedJustOnTime, stillSore |
| `MuscleGroup` | 15 | chest, back, shoulders, biceps, triceps, quads, hamstrings, glutes, calves, traps, forearms, abs |
| `EquipmentType` | 16 | barbell, dumbbells, cable, machine, bodyweight, smithMachine, other |
| `TrainingCycleStatus` | 17 | draft, active, completed, archived |
| `WorkoutStatus` | 18 | incomplete, completed, skipped |
| `RecoveryPeriodType` | 19 | deload, rest |

---

## Exercise Library Sources

### 1. CSV Library (Built-in)
- Location: `assets/exercises.csv`
- ~290 exercises loaded at startup via `CsvLoaderService`
- Format: `Name,Muscle Group,Equipment`
- Parsed into `ExerciseDefinition` (in-memory only, not Hive)

### 2. Custom Exercises (User-created)
- Stored in Hive via `CustomExerciseDefinition` (TypeId: 22)
- Converts to `ExerciseDefinition` via `toExerciseDefinition()`

**Access combined library via `exerciseRepositoryProvider`**

---

## State Management Patterns

### Reactive Hive via StreamProvider

```dart
// Pattern: Yield initial data, then watch box for changes
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) async* {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  yield repository.getAllSorted();
  await for (final _ in repository.box.watch()) {
    yield repository.getAllSorted();
  }
});
```

### Parameterized Access (Provider.family)

```dart
// Access single item by ID
final trainingCycleProvider = Provider.family<TrainingCycle?, String>((ref, id) {
  final cycles = ref.watch(trainingCyclesProvider).valueOrNull ?? [];
  return cycles.firstWhereOrNull((c) => c.id == id);
});

// Access filtered list
final workoutsByTrainingCycleProvider = Provider.family<List<Workout>, String>((ref, cycleId) {
  final workouts = ref.watch(workoutsProvider).valueOrNull ?? [];
  return workouts.where((w) => w.trainingCycleId == cycleId).toList();
});
```

### Repository Pattern

All repositories expose `box` for reactive watching:

```dart
class WorkoutRepository {
  final Box<Workout> _box;
  Box<Workout> get box => _box;  // Required for StreamProvider
  
  // CRUD methods...
}
```

---

## Code Generation

After modifying any file with `part '*.g.dart'`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Affected locations:**
- `data/models/*.dart` - Hive adapters
- `core/constants/enums.dart` - Enum adapters
- `core/theme/skins/skin_model.dart` - JSON serialization

---

## Quick Reference: Finding Data

| To find... | Use provider... |
|------------|-----------------|
| All training cycles | `trainingCyclesProvider` |
| Single training cycle | `trainingCycleProvider(id)` |
| Active training cycle | `activeTrainingCycleProvider` |
| Workouts for a cycle | `workoutsByTrainingCycleProvider(cycleId)` |
| Single workout | `workoutProvider(id)` |
| Workouts for a day | Filter by `(periodNumber, dayNumber)` |
| All exercises (library) | `exerciseRepositoryProvider` |
| Custom exercises | `customExerciseRepositoryProvider` |
| Current theme | `activeSkinProvider` |
