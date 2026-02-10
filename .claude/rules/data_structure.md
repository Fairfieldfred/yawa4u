# YAWA4U Data Structure Reference

Quick reference for the app's data models, Drift database structure, and state management patterns.

---

## Drift Database Tables

The app uses **Drift** (SQLite) with a fully normalized relational schema. Each table has an auto-incrementing integer `id` primary key and a `uuid` text field for application-level identification.

| Table Name | Model Type | Foreign Key | Purpose |
|------------|-----------|-------------|---------|
| `training_cycles` | `TrainingCycle` | - | Training program definitions |
| `workouts` | `Workout` | `trainingCycleUuid` → `training_cycles.uuid` | Individual workout sessions |
| `exercises` | `Exercise` | `workoutUuid` → `workouts.uuid` | Exercise instances in workouts |
| `exercise_sets` | `ExerciseSet` | `exerciseUuid` → `exercises.uuid` | Set data (weight, reps, etc.) |
| `exercise_feedbacks` | `ExerciseFeedback` | `exerciseUuid` → `exercises.uuid` | Post-exercise feedback (1:1) |
| `custom_exercise_definitions` | `CustomExerciseDefinition` | - | User-created exercises |
| `user_measurements` | `UserMeasurement` | - | Body composition tracking |
| `skins` | `SkinModel` | - | Custom themes |

**Database Location:** `app_database.sqlite` in the app's documents directory

---

## Core Data Models

### TrainingCycle
The top-level container for a training program.

```dart
class TrainingCycle {
  String id;                              // UUID
  String name;
  int periodsTotal;                       // Number of periods (not weeks!)
  int daysPerPeriod;                      // Days per period (e.g., 8, 9, 10)
  int? recoveryPeriod;                    // Optional deload period length
  RecoveryPeriodType? recoveryPeriodType;
  TrainingCycleStatus status;
  DateTime createdDate;
  DateTime? startDate;
  DateTime? endDate;
  List<Workout> workouts;                 // ⚠️ SNAPSHOT - see warning below
}
```

### Workout
A single workout session for ONE muscle group on a specific day.

```dart
class Workout {
  String id;                              // UUID
  String trainingCycleId;                 // FK to TrainingCycle.id
  int periodNumber;                       // 1-indexed period
  int dayNumber;                          // 1-indexed day within period
  String? dayName;                        // e.g., "Push Day"
  String label;                           // Muscle group identifier
  WorkoutStatus status;
  DateTime? completedDate;
  String? notes;
  List<Exercise> exercises;               // Loaded from Exercises table
}
```

### Exercise
An exercise instance within a workout.

```dart
class Exercise {
  String id;                              // UUID
  String workoutId;                       // FK to Workout.id
  String name;
  MuscleGroup muscleGroup;
  EquipmentType equipmentType;
  List<ExerciseSet> sets;                 // Loaded from ExerciseSets table
  int orderIndex;
  double? bodyweight;
  String? notes;
  ExerciseFeedback? feedback;             // Loaded from ExerciseFeedbacks table
}
```

### ExerciseSet
Individual set data within an exercise.

```dart
class ExerciseSet {
  String id;                              // UUID
  int setNumber;
  double? weight;
  String? reps;                           // String to support "8-12" or "2 RIR"
  SetType setType;
  bool isLogged;
  String? notes;
  bool isSkipped;
}
```

---

## ⚠️ Critical Concepts

### Normalized Database - Loading Hierarchy

Unlike Hive (NoSQL), Drift uses a **normalized relational structure**. Data must be loaded hierarchically:

```
TrainingCycle → Workouts → Exercises → ExerciseSets
                                    → ExerciseFeedback
```

**Repositories handle this automatically:**
- `WorkoutRepository` injects `WorkoutDao`, `ExerciseDao`, and `ExerciseSetDao`
- `ExerciseRepository` injects `ExerciseDao` and `ExerciseSetDao`

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

| Enum | Values |
|------|--------|
| `SetType` | regular, myorep, myorepMatch, maxReps, endWithPartials, dropSet |
| `JointPain` | none, low, moderate, severe |
| `MusclePump` | low, moderate, amazing |
| `Workload` | easy, prettyGood, pushedLimits, tooMuch |
| `Soreness` | neverGotSore, healedAWhileAgo, healedJustOnTime, stillSore |
| `MuscleGroup` | chest, back, shoulders, biceps, triceps, quads, hamstrings, glutes, calves, traps, forearms, abs |
| `EquipmentType` | barbell, dumbbells, cable, machine, bodyweight, smithMachine, other |
| `TrainingCycleStatus` | draft, active, completed, archived |
| `WorkoutStatus` | incomplete, completed, skipped |
| `RecoveryPeriodType` | deload, rest |

**Note:** Enums are stored as integers in the database and converted via Drift type converters.

---

## Exercise Library Sources

### 1. CSV Library (Built-in)
- Location: `assets/exercises.csv`
- ~290 exercises loaded at startup via `CsvLoaderService`
- Format: `Name,Muscle Group,Equipment`
- Parsed into `ExerciseDefinition` (in-memory only, not Hive)

### 2. Custom Exercises (User-created)
- Stored in Drift via `CustomExerciseDefinition`
- Converts to `ExerciseDefinition` via `toExerciseDefinition()`

**Access combined library via `exerciseLibraryProvider`**

---

## State Management Patterns

### Reactive Drift via StreamProvider

```dart
// Pattern: Watch Drift stream for reactive updates
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  return repository.watchAll();
});
```

### Parameterized Access (Provider.family)

```dart
// Access single item by ID
final trainingCycleProvider = FutureProvider.family<TrainingCycle?, String>((ref, id) async {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  return repository.getById(id);
});

// Access filtered list
final workoutsByTrainingCycleProvider = StreamProvider.family<List<Workout>, String>((ref, cycleId) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.watchByTrainingCycleId(cycleId);
});
```

### Repository Pattern

Repositories handle the normalized data loading:

```dart
class WorkoutRepository {
  final WorkoutDao _workoutDao;
  final ExerciseDao _exerciseDao;
  final ExerciseSetDao _exerciseSetDao;

  // Automatically loads exercises and sets for each workout
  Future<Workout> _mapRowToWorkout(dynamic row) async {
    final exercises = await _loadExercisesForWorkout(row.uuid);
    return WorkoutMapper.fromRow(row, exercises: exercises);
  }
}
```

### DAO Layer

Each table has a corresponding DAO with standard CRUD operations:

```dart
// Example: WorkoutDao
@DriftAccessor(tables: [Workouts])
class WorkoutDao extends DatabaseAccessor<AppDatabase> {
  Stream<List<Workout>> watchAll();
  Future<List<Workout>> getAll();
  Future<Workout?> getByUuid(String uuid);
  Future<void> insertWorkout(WorkoutsCompanion workout);
  Future<void> updateByUuid(String uuid, WorkoutsCompanion workout);
  Future<void> deleteByUuid(String uuid);
}
```

---

## Database Architecture

### File Structure

```
lib/data/database/
├── app_database.dart       # Main database class with @DriftDatabase
├── app_database.g.dart     # Generated code
├── tables.dart             # All table definitions
├── converters.dart         # Type converters (enums, dates)
├── daos/
│   ├── training_cycle_dao.dart
│   ├── workout_dao.dart
│   ├── exercise_dao.dart
│   ├── exercise_set_dao.dart
│   ├── exercise_feedback_dao.dart
│   ├── custom_exercise_dao.dart
│   ├── user_measurement_dao.dart
│   └── skin_dao.dart
└── mappers/
    └── entity_mappers.dart  # Convert between Drift rows and domain models
```

### Code Generation

After modifying database tables or DAOs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Affected locations:**
- `data/database/app_database.dart` → generates `app_database.g.dart`
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
| All exercises (library) | `exerciseLibraryProvider` |
| Custom exercises | `customExerciseRepositoryProvider` |
| Current theme | `activeSkinProvider` |
