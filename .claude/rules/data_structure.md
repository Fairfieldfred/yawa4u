# YAWA4U Data Structure Reference

Quick reference for the app's data models, Drift database structure, and state management patterns.

---

## Drift Database Tables

The app uses **Drift** (SQLite) with a fully normalized relational schema (schema version **2**). Each table has an auto-incrementing integer `id` primary key and a `uuid` text field for application-level identification.

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

**Database Location:** `yawa4u.sqlite` in the app's documents directory

**Migration History:**
- v1 → v2: Added `secondaryMuscleGroup` column to `exercises` and `custom_exercise_definitions` tables

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
  int recoveryPeriod;                     // Recovery period length
  RecoveryPeriodType recoveryPeriodType;
  TrainingCycleStatus status;
  Gender? gender;                         // Template gender filter
  DateTime createdDate;
  DateTime? startDate;
  DateTime? endDate;
  List<Workout> workouts;                 // ⚠️ SNAPSHOT - see warning below
  Map<String, int>? muscleGroupPriorities;
  String? templateName;                   // Source template name
  String? notes;
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
  String? label;                          // Muscle group identifier
  WorkoutStatus status;
  DateTime? scheduledDate;                // Calendar date for this workout
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
  MuscleGroup? secondaryMuscleGroup;      // Optional secondary target
  EquipmentType equipmentType;
  List<ExerciseSet> sets;                 // Loaded from ExerciseSets table
  int orderIndex;
  double? bodyweight;
  String? notes;
  ExerciseFeedback? feedback;             // Loaded from ExerciseFeedbacks table
  DateTime? lastPerformed;                // Last time this exercise was done
  String? videoUrl;                       // YouTube video URL
  bool isNotePinned;                      // Pin note to exercise card
}
```

### ExerciseSet
Individual set data within an exercise.

```dart
class ExerciseSet {
  String id;                              // UUID
  int setNumber;
  double? weight;
  String reps;                            // String to support "8-12" or "2 RIR"
  SetType setType;
  bool isLogged;
  String? notes;
  bool isSkipped;
}
```

### ExerciseFeedback
Post-exercise feedback (1:1 relationship with Exercise).

```dart
class ExerciseFeedback {
  JointPain? jointPain;
  MusclePump? musclePump;
  Workload? workload;
  Soreness? soreness;                     // Overall soreness
  Map<String, Soreness>? muscleGroupSoreness; // Per-muscle-group soreness
  DateTime? timestamp;
}
```

### CustomExerciseDefinition
User-created exercise stored in the database.

```dart
class CustomExerciseDefinition {
  String id;                              // UUID
  String name;
  MuscleGroup muscleGroup;
  MuscleGroup? secondaryMuscleGroup;      // Optional secondary target
  EquipmentType equipmentType;
  String? videoUrl;                       // YouTube video URL
  DateTime createdAt;
}
```

### UserMeasurement
Body composition tracking with computed fields.

```dart
class UserMeasurement {
  String id;                              // UUID
  double heightCm;
  double weightKg;
  DateTime timestamp;
  String? notes;
  double? bodyFatPercent;                 // DEXA scan body fat %
  double? leanMassKg;                     // DEXA scan lean mass

  // Computed getters:
  double get bmi;                         // BMI from height/weight
  double? get calculatedLeanMassKg;       // From leanMassKg or bodyFatPercent
  double? get fatMassKg;                  // From bodyFatPercent
}
```

### ExerciseDefinition
In-memory model from CSV library or custom exercise conversion.

```dart
class ExerciseDefinition {
  String name;
  MuscleGroup muscleGroup;
  MuscleGroup? secondaryMuscleGroup;
  EquipmentType equipmentType;
  String? videoUrl;
}
```

### Template Models
All in `lib/data/models/training_cycle_template.dart`:

```dart
class TrainingCycleTemplate {
  String id;
  String name;
  String description;
  int periodsTotal;
  int daysPerPeriod;
  int? recoveryPeriod;
  List<WorkoutTemplate> workouts;
}

class WorkoutTemplate {
  int periodNumber;
  int dayNumber;
  String? dayName;
  List<ExerciseTemplate> exercises;
}

class ExerciseTemplate {
  String name;
  String muscleGroup;                     // String (not enum)
  String equipmentType;                   // String (not enum)
  int sets;
  String reps;
  String setType;
  String? notes;
}
```

### Stats Models
In `lib/data/models/stats_data.dart`:

```dart
class WorkoutStats {
  int totalWorkouts;
  int completedWorkouts;
  int skippedWorkouts;
  double completionRate;
  Map<MuscleGroup, int> setsByMuscleGroup;
  Map<String, int> exerciseFrequency;
  List<VolumeDataPoint> volumeProgression;
  Map<String, double> personalRecords;
  int totalSets;
  // Methods: topExercises(), topRecords(), fromWorkouts() factory
}

class VolumeDataPoint {
  int periodNumber;
  int dayNumber;
  double totalVolume;
  DateTime? date;
  // label property for chart display (e.g., "P1D3")
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

## Enums (All in `core/constants/enums.dart` unless noted)

| Enum | Values | Location |
|------|--------|----------|
| `SetType` | regular, myorep, myorepMatch, maxReps, endWithPartials, dropSet | `enums.dart` |
| `JointPain` | none, low, moderate, severe | `enums.dart` |
| `MusclePump` | low, moderate, amazing | `enums.dart` |
| `Workload` | easy, prettyGood, pushedLimits, tooMuch | `enums.dart` |
| `Soreness` | neverGotSore, healedAWhileAgo, healedJustOnTime, stillSore | `enums.dart` |
| `Gender` | male, female | `enums.dart` |
| `TrainingCycleStatus` | draft, current, completed | `enums.dart` |
| `WorkoutStatus` | incomplete, completed, skipped | `enums.dart` |
| `RecoveryPeriodType` | deload, taper, recovery | `enums.dart` |
| `MuscleGroup` | chest, triceps, shoulders, back, biceps, quads, hamstrings, glutes, calves, traps, forearms, abs, fullBody, adductors, core, grip, obliques, legs, hips | `muscle_groups.dart` |
| `EquipmentType` | barbell, bodyweightLoadable, bodyweightOnly, cable, dumbbell, freemotion, kettlebell, machine, machineAssistance, smithMachine, bandAssistance | `equipment_types.dart` |

**Note:** Enums are stored as integers in the database and converted via Drift type converters.

---

## Exercise Library Sources

### 1. CSV Library (Built-in)
- Location: `exercises.csv` (root assets)
- ~290 exercises loaded at startup via `CsvLoaderService`
- Format: `Name,Muscle Group,Equipment`
- Parsed into `ExerciseDefinition` (in-memory only)

### 2. Custom Exercises (User-created)
- Stored in Drift via `CustomExerciseDefinition`
- Converts to `ExerciseDefinition` via `toExerciseDefinition()`

**Access combined library via `allExerciseDefinitionsProvider`**

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

## Repositories

| Repository | Location | Purpose |
|-----------|----------|---------|
| `TrainingCycleRepository` | `data/repositories/` | CRUD, status filtering, duplication, search |
| `WorkoutRepository` | `data/repositories/` | Hierarchy loading (workouts→exercises→sets), filtering |
| `ExerciseRepository` | `data/repositories/` | Exercise CRUD, muscle group/equipment filtering |
| `CustomExerciseRepository` | `data/repositories/` | User-created exercise definitions with stream watching |
| `UserMeasurementRepository` | `data/repositories/` | Body measurements, BMI history, date range queries |
| `TemplateRepository` | `data/repositories/` | Training cycle templates from assets, saving/loading |

---

## Services

| Service | Location | Purpose |
|---------|----------|---------|
| `AnalyticsService` | `data/services/` | Firebase analytics event tracking |
| `CsvLoaderService` | `data/services/` | Load exercise library from CSV |
| `DataBackupService` | `data/services/` | JSON backup/restore (export/import) |
| `DatabaseService` | `data/services/` | Drift database initialization and lifecycle |
| `ExerciseHistoryService` | `data/services/` | Track previous exercise performances |
| `OnboardingService` | `data/services/` | User onboarding flow management |
| `ScheduleService` | `data/services/` | Workout scheduling and calendar shift/move |
| `SkinShareService` | `data/services/` | Share custom themes between devices |
| `TemplateShareService` | `data/services/` | Share training templates between devices |
| `ThemeImageService` | `data/services/` | Theme image management for custom skins |
| `WifiSyncService` | `data/services/` | Device-to-device sync over local network |

---

## Database Architecture

### File Structure

```
lib/data/database/
├── app_database.dart       # Main database class with @DriftDatabase (schema v2)
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
    ├── entity_mappers.dart      # TrainingCycle, Workout, Exercise, ExerciseSet, ExerciseFeedback mappers
    └── secondary_mappers.dart   # CustomExercise, UserMeasurement mappers
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

## Providers Reference

### Core Providers (`database_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `databaseServiceProvider` | `Provider<DatabaseService>` | Database service singleton |
| `appDatabaseProvider` | `Provider<AppDatabase>` | Drift database instance |
| `trainingCycleDaoProvider` | `Provider<TrainingCycleDao>` | DAO access |
| `workoutDaoProvider` | `Provider<WorkoutDao>` | DAO access |
| `exerciseDaoProvider` | `Provider<ExerciseDao>` | DAO access |
| `exerciseSetDaoProvider` | `Provider<ExerciseSetDao>` | DAO access |
| `exerciseFeedbackDaoProvider` | `Provider<ExerciseFeedbackDao>` | DAO access |
| `customExerciseDaoProvider` | `Provider<CustomExerciseDao>` | DAO access |
| `userMeasurementDaoProvider` | `Provider<UserMeasurementDao>` | DAO access |
| `skinDaoProvider` | `Provider<SkinDao>` | DAO access |
| `trainingCycleRepositoryProvider` | `Provider` | Repository access |
| `workoutRepositoryProvider` | `Provider` | Repository access |
| `exerciseRepositoryProvider` | `Provider` | Repository access |
| `customExerciseRepositoryProvider` | `Provider` | Repository access |
| `userMeasurementRepositoryProvider` | `Provider` | Repository access |

### Training Cycle Providers (`training_cycle_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `trainingCyclesProvider` | `StreamProvider` | All training cycles |
| `currentTrainingCycleProvider` | `Provider` | Active (current status) cycle |
| `draftTrainingCyclesProvider` | `Provider` | Draft cycles |
| `completedTrainingCyclesProvider` | `Provider` | Completed cycles |
| `trainingCycleProvider(id)` | `Provider.family` | Single cycle by ID |
| `trainingCycleStatsProvider` | `Provider` | Cycle statistics |

### Workout Providers (`workout_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `workoutsProvider` | `StreamProvider` | All workouts |
| `workoutsByTrainingCycleProvider(cycleId)` | `StreamProvider.family` | Workouts for a cycle |
| `workoutsByTrainingCycleListProvider(cycleId)` | `Provider.family` | Synchronous list access |
| `workoutsByPeriodProvider` | `FutureProvider.family` | Workouts for a period |
| `workoutProvider(id)` | `Provider.family` | Single workout by ID |
| `completedWorkoutsProvider` | `Provider` | Completed workouts |
| `todayWorkoutsProvider` | `FutureProvider` | Today's workouts |
| `upcomingWorkoutsProvider` | `FutureProvider` | Upcoming workouts |
| `showExerciseHistoryProvider` | `NotifierProvider` | Toggle exercise history display |

### Exercise Providers (`exercise_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `exerciseDefinitionsProvider` | `Provider` | CSV library definitions |
| `customExerciseDefinitionsProvider` | `StreamProvider` | User-created definitions |
| `allExerciseDefinitionsProvider` | `Provider` | Combined CSV + custom definitions |
| `exercisesByWorkoutProvider(id)` | `FutureProvider.family` | Exercises for a workout |
| `exerciseHistoryServiceProvider` | `Provider` | History service access |
| `previousPerformanceProvider` | `FutureProvider.family` | Previous performance data |

### Stats Providers (`stats_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `cycleStatsProvider(cycleId)` | `FutureProvider.family` | Stats for one cycle |
| `lifetimeStatsProvider` | `FutureProvider` | All-time stats |
| `cycleWorkoutsProvider(cycleId)` | `FutureProvider.family` | Workouts for stats |

### Template Providers (`template_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `templateRepositoryProvider` | `Provider` | Template repository access |
| `availableTemplatesProvider` | `FutureProvider` | All available templates |
| `selectedTemplateProvider` | `NotifierProvider` | Currently selected template |

### Additional Provider Files

| File | Purpose |
|------|---------|
| `calendar_providers.dart` | Calendar data mapping, undo state for schedule changes |
| `drift_providers.dart` | Low-level Drift stream providers |
| `navigation_providers.dart` | Bottom nav state, GoRouter instance |
| `onboarding_providers.dart` | Onboarding flow state |
| `skin_share_providers.dart` | Skin/theme sharing state |
| `sync_providers.dart` | WiFi sync service and status |
| `template_share_providers.dart` | Template sharing state |
| `theme_provider.dart` | Theme mode (light/dark/system), `themeModeProvider`, `isDarkModeProvider` |

---

## Quick Reference: Finding Data

| To find... | Use provider... |
|------------|-----------------|
| All training cycles | `trainingCyclesProvider` |
| Single training cycle | `trainingCycleProvider(id)` |
| Current training cycle | `currentTrainingCycleProvider` |
| Workouts for a cycle | `workoutsByTrainingCycleProvider(cycleId)` |
| Single workout | `workoutProvider(id)` |
| Workouts for a day | Filter by `(periodNumber, dayNumber)` |
| All exercises (library) | `allExerciseDefinitionsProvider` |
| Custom exercises | `customExerciseDefinitionsProvider` |
| Current theme | `activeSkinProvider` |
| Cycle statistics | `cycleStatsProvider(cycleId)` |
| Available templates | `availableTemplatesProvider` |
