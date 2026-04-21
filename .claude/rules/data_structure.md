# YAWA4U Data Structure Reference

Quick reference for the app's data models, Drift database structure, and state management patterns. Reflects the v6 schema (Phase 6d — legacy `workouts` table dropped; `sessions` is the canonical source of truth for both strength and cardio).

---

## Drift Database Tables

The app uses **Drift** (SQLite) with a fully normalized relational schema (schema version **6**). Each table has an auto-incrementing integer `id` primary key and a `uuid` text field for application-level identification.

| Table Name | Model Type | Foreign Key | Purpose |
|------------|-----------|-------------|---------|
| `training_cycles` | `TrainingCycle` | - | Training program definitions (multi-sport capable) |
| `sessions` | `Session` (sealed: `StrengthSession` / `CardioSession`) | `trainingCycleUuid` → `training_cycles.uuid` (nullable) | Polymorphic unit of training — one row per strength workout OR cardio session |
| `session_cardio` | `CardioDetail` | `sessionUuid` → `sessions.uuid` (1:1) | Cardio-specific fields (distance, pace, HR, power, swim details) |
| `session_intervals` | `SessionInterval` | `sessionUuid` → `sessions.uuid` | Structured cardio intervals with optional nesting (repeats) |
| `session_samples` | `SessionSample` | `sessionUuid` → `sessions.uuid` | Per-second time-series data from imported activities |
| `cardio_feedback` | `CardioFeedback` | `sessionUuid` → `sessions.uuid` (1:1) | Post-session feedback (RPE, enjoyment, notes) |
| `cycle_periods` | `CyclePeriod` | `trainingCycleUuid` → `training_cycles.uuid` | Per-period metadata (phase, notes) for multi-period cycles |
| `sport_zones` | `SportZone` | - | User's HR / pace / power zones per sport |
| `exercises` | `Exercise` | `workoutUuid` (holds the strength session UUID) | Exercise instances within a strength session |
| `exercise_sets` | `ExerciseSet` | `exerciseUuid` → `exercises.uuid` | Set data (weight, reps, etc.) |
| `exercise_feedbacks` | `ExerciseFeedback` | `exerciseUuid` → `exercises.uuid` (1:1) | Post-exercise feedback |
| `custom_exercise_definitions` | `CustomExerciseDefinition` | - | User-created exercises |
| `user_measurements` | `UserMeasurement` | - | Body composition tracking |
| `skins` | `SkinModel` | - | Custom themes |

**Note on `exercises.workout_uuid`**: the column keeps its legacy name but now holds the strength session's UUID. Column rename is deferred to a later migration (SQLite column renames are expensive).

**Database Location:** `yawa4u.sqlite` in the app's documents directory

**Migration History:**
- v1 → v2: Added `secondaryMuscleGroup` column to `exercises` and `custom_exercise_definitions`.
- v2 → v3: Added `startTime` / `endTime` columns to `workouts` (written as raw SQL since v6 — the `workouts` Dart symbol was removed).
- v3 → v4: Added `restSeconds` column to `exercises` and `custom_exercise_definitions`.
- v4 → v5: Multi-sport expansion. Added `primarySport`, `creatorUuid`, `ownerUuid` to `training_cycles`; added `sessionUuid` to `exercises` and `exercise_feedbacks`; created `sessions`, `cycle_periods`, `session_cardio`, `session_intervals`, `session_samples`, `sport_zones`, `cardio_feedback`. Backfilled every existing `workouts` row into `sessions` with `Sport.strength` via `AppDatabaseV5Backfill`.
- v5 → v6: Dropped the `workouts` table. `WorkoutRepository` is now a facade over `SessionRepository`, so nothing in the running app reads or writes the legacy table.

---

## Core Data Models

### Session (sealed — v5+)

The polymorphic unit of training. A sealed class with two concrete variants: `StrengthSession` and `CardioSession`. Every strength workout and every cardio activity (planned, logged, or imported) is a row in the `sessions` table.

```dart
sealed class Session {
  String id;                              // UUID (also session_uuid on children)
  String? trainingCycleId;                // Null for ad-hoc sessions
  Sport sport;                            // Discriminator: strength, run, bike, swim, other
  SessionSource source;                   // userLogged, healthKit, strava, import
  WorkoutStatus status;
  int? periodNumber;
  int? dayNumber;
  String? dayName;
  String? label;
  DateTime? scheduledDate;
  DateTime? completedDate;
  DateTime? startTime;
  DateTime? endTime;
  String? notes;
  String? externalId;                     // For de-duping imports ("strava-12345")
  String? creatorUuid;
  String? ownerUuid;
}

class StrengthSession extends Session {
  List<Exercise> exercises;               // Loaded from `exercises` table
}

class CardioSession extends Session {
  CardioDetail? detail;                   // 1:1 from `session_cardio`
  List<SessionInterval> intervals;        // From `session_intervals`
  List<SessionSample>? samples;           // From `session_samples` (opt-in load)
  CardioFeedback? feedback;               // 1:1 from `cardio_feedback`
}
```

Pattern-match with `switch (session) { case StrengthSession s: ...; case CardioSession c: ... }`.

### Workout (legacy adapter shape)

The historical strength-training shape. Still used by every UI that existed before Phase 6 because the facade in `WorkoutRepository` translates `StrengthSession` ↔ `Workout` at the boundary. The class exists one more major version to avoid a blast-radius rewrite.

```dart
class Workout {
  String id;                              // UUID (== StrengthSession.id)
  String trainingCycleId;                 // FK to TrainingCycle.id (empty string if orphaned)
  int periodNumber;
  int dayNumber;
  String? dayName;
  String? label;
  WorkoutStatus status;
  DateTime? scheduledDate;
  DateTime? completedDate;
  DateTime? startTime;
  DateTime? endTime;
  String? notes;
  List<Exercise> exercises;
}
```

### TrainingCycle

The top-level container for a training program. Multi-sport capable — a single cycle can contain strength and cardio sessions.

```dart
class TrainingCycle {
  String id;                              // UUID
  String name;
  int periodsTotal;
  int daysPerPeriod;                      // Default varies by primarySport
  int recoveryPeriod;
  RecoveryPeriodType recoveryPeriodType;
  TrainingCycleStatus status;
  Gender? gender;
  Sport? primarySport;                    // UI hint only — cycle can still contain any sport
  String? creatorUuid;                    // v5 — device-local user UUID
  String? ownerUuid;                      // v5 — for future cross-device sharing
  DateTime createdDate;
  DateTime? startDate;
  DateTime? endDate;
  List<Workout> workouts;                 // ⚠️ SNAPSHOT — see warning below
  Map<String, int>? muscleGroupPriorities;
  String? templateName;
  String? notes;
}
```

### Exercise

An exercise instance within a strength session.

```dart
class Exercise {
  String id;                              // UUID
  String workoutId;                       // Holds the StrengthSession UUID (column name kept legacy)
  String name;
  MuscleGroup muscleGroup;
  MuscleGroup? secondaryMuscleGroup;
  EquipmentType equipmentType;
  List<ExerciseSet> sets;
  int orderIndex;
  double? bodyweight;
  String? notes;
  ExerciseFeedback? feedback;
  DateTime? lastPerformed;
  String? videoUrl;
  bool isNotePinned;
  int? restSeconds;
}
```

### ExerciseSet

```dart
class ExerciseSet {
  String id;
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

```dart
class ExerciseFeedback {
  JointPain? jointPain;
  MusclePump? musclePump;
  Workload? workload;
  Soreness? soreness;
  Map<String, Soreness>? muscleGroupSoreness;
  DateTime? timestamp;
}
```

### CardioDetail

```dart
class CardioDetail {
  double? plannedDistanceM;
  double? actualDistanceM;
  int? plannedDurationSec;
  int? actualDurationSec;
  double? elevationGainM;
  double? elevationLossM;
  int? averageHr;
  int? maxHr;
  int? averageCadence;
  int? averagePowerWatts;
  int? normalizedPowerWatts;
  double? averageSpeedMps;
  double? averagePaceSecPerMeter;
  // Swim-specific
  int? poolLengthM;
  StrokeType? strokeType;
  int? lapCount;
  int? swolf;
  // Subjective
  int? perceivedExertion;                 // 1-10 RPE
  String? notes;
}
```

### SessionInterval

Structured cardio interval. Intervals can nest — a "repeat 5×" group holds child intervals.

```dart
class SessionInterval {
  String id;
  String sessionId;
  int orderIndex;
  IntervalKind kind;                      // work, rest, warmup, cooldown, repeat
  String? label;
  String? parentIntervalId;               // Non-null for nested (repeat) children
  int? repeatCount;                       // For `repeat` kind
  int? durationSec;
  double? distanceM;
  ZoneTarget? paceTarget;
  ZoneTarget? powerTarget;
  ZoneTarget? hrTarget;
  int? actualDurationSec;
  double? actualDistanceM;
  int? actualAverageHr;
  int? actualAveragePowerWatts;
}
```

### SessionSample

Time-series datapoint from an imported activity (typically 1 Hz). Not loaded by default — pass `includeSamples: true` to `SessionRepository.getById` when you need them.

```dart
class SessionSample {
  String id;
  String sessionId;
  int offsetSec;                          // Seconds from session start
  int? hr;
  int? powerWatts;
  double? speedMps;
  int? cadence;
  double? elevationM;
}
```

### CardioFeedback

```dart
class CardioFeedback {
  int? rpe;                               // 1-10 perceived exertion
  int? enjoyment;                         // 1-5
  String? notes;
  DateTime? timestamp;
}
```

### CyclePeriod

```dart
class CyclePeriod {
  String id;
  String trainingCycleId;
  int periodNumber;
  CyclePhase? phase;                      // accumulation / intensification / deload / peak / taper
  String? notes;
  String? creatorUuid;
  String? ownerUuid;
}
```

### SportZone

User-configured training zones per sport.

```dart
class SportZone {
  String id;
  Sport sport;
  ZoneMetric metric;                      // hr, pace, power
  List<ZoneBoundary> boundaries;
  DateTime? updatedAt;
}
```

### CustomExerciseDefinition

```dart
class CustomExerciseDefinition {
  String id;
  String name;
  MuscleGroup muscleGroup;
  MuscleGroup? secondaryMuscleGroup;
  EquipmentType equipmentType;
  String? videoUrl;
  int? restSeconds;
  DateTime createdAt;
}
```

### UserMeasurement

```dart
class UserMeasurement {
  String id;
  double heightCm;
  double weightKg;
  DateTime timestamp;
  String? notes;
  double? bodyFatPercent;
  double? leanMassKg;

  double get bmi;
  double? get calculatedLeanMassKg;
  double? get fatMassKg;
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

`lib/data/models/training_cycle_template.dart` and `lib/data/models/cardio_session_template.dart`. Templates can contain both strength workouts and cardio sessions so a template describes a mixed-sport block end-to-end.

### Stats Models

`lib/data/models/stats_data.dart` (strength) and `lib/data/models/cardio_stats.dart` (cardio).

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
}

class CardioStats {
  Map<Sport, SportAggregate> perSport;
  List<WeeklyVolumeBucket> weeklyBuckets;
  // fromSessions() factory folds a List<Session> into aggregates.
  // recentWeeks(int n) returns padded weekly buckets for charts.
}
```

---

## ⚠️ Critical Concepts

### Sessions are the source of truth

As of v6, `sessions` is the canonical table for every unit of training. `WorkoutRepository` still exists as a facade that translates between the legacy `Workout` shape and `StrengthSession` — it delegates every read and write to `SessionRepository`. New code should prefer `SessionRepository` directly; existing call sites can migrate at their leisure because the facade preserves the old API.

```dart
// ✅ Preferred for new code
final sessions = await ref.read(sessionRepositoryProvider).watchAll().first;
for (final s in sessions) {
  switch (s) {
    case StrengthSession():
      // ...
    case CardioSession():
      // ...
  }
}

// ✅ Still works — WorkoutRepository is a thin facade
final workouts = await ref.read(workoutRepositoryProvider).getAll();
```

### Loading hierarchy

```
TrainingCycle ─┬─ Sessions (polymorphic)
               │    ├─ StrengthSession ─ Exercises ─ ExerciseSets
               │    │                             └─ ExerciseFeedback
               │    └─ CardioSession  ─ CardioDetail
               │                     └─ Intervals
               │                     └─ Samples (opt-in)
               │                     └─ CardioFeedback
               └─ CyclePeriods
```

`SessionRepository._hydrate` dispatches on `session.sport` and loads only the children appropriate for that variant. Samples are intentionally off by default — a 2-hour ride at 1 Hz has ~7,200 sample rows.

### Sessions per training day

A training day can hold multiple sessions — e.g., a strength session plus a bike session on the same day, or multiple strength sessions split by muscle group. Sessions sharing a training day have the same `(periodNumber, dayNumber)` and are disambiguated by `sport` + `label`.

**Always aggregate sessions by `(periodNumber, dayNumber)` when presenting a day to the user.**

### Periods vs. Weeks

The app uses "periods" instead of "weeks" to support flexible training schedules. `periodsTotal`, `daysPerPeriod`, `periodNumber`, `dayNumber` are all 1-indexed. `daysPerPeriod` varies by primary sport (strength defaults to 4, endurance sports default to 7).

### TrainingCycle.workouts is a SNAPSHOT

`TrainingCycle.workouts` is populated at creation and may become stale. Always use the provider for current state:

```dart
// ✅ Correct — always current
final workouts = ref.watch(workoutsByTrainingCycleProvider(cycleId));

// ❌ Avoid — may be stale
final workouts = trainingCycle.workouts;
```

---

## Enums

| Enum | Values | Location |
|------|--------|----------|
| `Sport` | strength, run, bike, swim, other | `core/constants/sports.dart` |
| `SessionSource` | userLogged, healthKit, strava, import | `core/constants/sports.dart` |
| `StrokeType` | freestyle, backstroke, breaststroke, butterfly, mixed | `core/constants/sports.dart` |
| `IntervalKind` | work, rest, warmup, cooldown, repeat | `core/constants/sports.dart` |
| `ZoneMetric` | hr, pace, power | `core/constants/sports.dart` |
| `CyclePhase` | accumulation, intensification, deload, peak, taper | `core/constants/sports.dart` |
| `UnitSystem` | metric, imperial | `core/constants/sports.dart` |
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

Enums are stored as integers in the database and converted via Drift type converters.

---

## Exercise Library Sources

### CSV Library (built-in)

Location: `exercises.csv` (root assets). ~290 exercises loaded at startup via `CsvLoaderService`. Format: `Name,Muscle Group,Equipment`. Parsed into `ExerciseDefinition` (in-memory only).

### Custom Exercises (user-created)

Stored in Drift via `CustomExerciseDefinition`. Converts to `ExerciseDefinition` via `toExerciseDefinition()`.

**Access combined library via `allExerciseDefinitionsProvider`.**

### Cardio Session Library

`lib/data/services/cardio_session_library_service.dart` loads a catalog of stock cardio templates (e.g. "5k tempo run," "sweet spot bike intervals") from assets at startup. Used by the cardio session creator's "From template" flow.

---

## State Management Patterns

### Reactive Drift via StreamProvider

```dart
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  return repository.watchAll();
});
```

### Parameterized Access (Provider.family)

```dart
final sessionsByTrainingCycleProvider =
    StreamProvider.autoDispose.family<List<Session>, String>((ref, cycleId) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.watchByTrainingCycleId(cycleId);
});
```

### Repository Pattern

`SessionRepository` is the current source of truth; `WorkoutRepository` is a thin facade over it.

```dart
class SessionRepository {
  final SessionDao _sessionDao;
  final ExerciseDao _exerciseDao;
  final ExerciseSetDao _exerciseSetDao;
  final SessionCardioDao _cardioDao;
  final SessionIntervalDao _intervalDao;
  final SessionSampleDao _sampleDao;
  final CardioFeedbackDao _feedbackDao;

  Future<Session?> getById(String id, {bool includeSamples = false});
  Stream<List<Session>> watchAll();
  Stream<List<Session>> watchByTrainingCycleId(String trainingCycleId);
  Stream<List<Session>> watchBySport(Sport sport);
  Stream<List<Session>> watchCardio();
  Stream<List<Session>> watchByDateRange(DateTime start, DateTime end);
  Future<Session?> getByExternalId(String externalId);  // De-dupe imports

  Future<void> createStrength(StrengthSession session);
  Future<void> updateStrength(StrengthSession session);
  Future<void> deleteStrength(String sessionId);

  Future<void> createCardio(CardioSession session);
  Future<void> updateCardio(CardioSession session);

  Future<void> markAsCompleted(String id);
  Future<void> markAsSkipped(String id);
  Future<void> delete(String id);
}
```

### DAO Layer

Each table has a corresponding DAO. Use them directly only when you need a single-row update that bypasses the hierarchy-load cost (e.g., the debounced weight/reps writes on `workout_screen`).

---

## Repositories

| Repository | Location | Purpose |
|-----------|----------|---------|
| `TrainingCycleRepository` | `data/repositories/` | Cycle CRUD, status filtering, duplication |
| `SessionRepository` | `data/repositories/` | Canonical read/write for strength + cardio sessions |
| `WorkoutRepository` | `data/repositories/` | Facade over `SessionRepository` exposing the legacy Workout-shaped API |
| `ExerciseRepository` | `data/repositories/` | Exercise CRUD, muscle/equipment filtering |
| `CustomExerciseRepository` | `data/repositories/` | User-created exercise definitions |
| `CyclePeriodRepository` | `data/repositories/` | Per-period metadata for a cycle |
| `SportZoneRepository` | `data/repositories/` | HR/pace/power zones per sport |
| `CardioFeedbackRepository` | `data/repositories/` | Post-cardio feedback |
| `UserMeasurementRepository` | `data/repositories/` | Body measurements, BMI history |
| `TemplateRepository` | `data/repositories/` | Training cycle + cardio session templates |

---

## Services

| Service | Location | Purpose |
|---------|----------|---------|
| `AnalyticsService` | `data/services/` | Firebase analytics event tracking |
| `CsvLoaderService` | `data/services/` | Load exercise library from CSV |
| `CardioSessionLibraryService` | `data/services/` | Load cardio session templates from assets |
| `DataBackupService` | `data/services/` | JSON backup/restore (v4 schema — multi-sport) |
| `DatabaseService` | `data/services/` | Drift database initialization and lifecycle |
| `ExerciseHistoryService` | `data/services/` | Previous exercise performances |
| `HealthSyncService` | `data/services/` | Apple Health / Health Connect import via `health` package |
| `StravaIntegrationService` | `data/services/` | OAuth + sync for Strava activities |
| `OnboardingService` | `data/services/` | Onboarding flow state + per-sport unit preferences |
| `ScheduleService` | `data/services/` | Session scheduling, calendar shift/move |
| `SkinShareService` | `data/services/` | Share custom themes between devices |
| `TemplateShareService` | `data/services/` | Share training templates between devices |
| `ThemeImageService` | `data/services/` | Theme image management for custom skins |
| `WifiSyncService` | `data/services/` | Device-to-device sync over local network |

---

## Database Architecture

### File Structure

```
lib/data/database/
├── app_database.dart       # @DriftDatabase, schema v6, migration strategy
├── app_database.g.dart     # Generated code
├── tables.dart             # All table definitions
├── converters.dart         # Type converters (enums, dates, JSON)
├── migrations/
│   └── v5_backfill.dart    # Copies legacy `workouts` rows into `sessions` on v4→v5 upgrade
├── daos/
│   ├── daos.dart           # Barrel export
│   ├── training_cycle_dao.dart
│   ├── session_dao.dart
│   ├── session_cardio_dao.dart
│   ├── session_interval_dao.dart
│   ├── session_sample_dao.dart
│   ├── cardio_feedback_dao.dart
│   ├── cycle_period_dao.dart
│   ├── sport_zone_dao.dart
│   ├── exercise_dao.dart
│   ├── exercise_set_dao.dart
│   ├── exercise_feedback_dao.dart
│   ├── custom_exercise_dao.dart
│   ├── user_measurement_dao.dart
│   └── skin_dao.dart
└── mappers/
    ├── entity_mappers.dart      # TrainingCycle, Exercise, ExerciseSet, ExerciseFeedback mappers
    ├── session_mappers.dart     # Session, CardioDetail, Interval, Sample, Zone, Feedback, CyclePeriod
    └── secondary_mappers.dart   # CustomExercise, UserMeasurement mappers
```

`WorkoutDao` and `WorkoutMapper` were removed in Phase 6d along with the `workouts` table.

### Code Generation

After modifying database tables or DAOs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Drift generates `app_database.g.dart` and each DAO's `.g.dart` file. Run with `--delete-conflicting-outputs` after schema changes so orphaned generated files are cleaned up.

---

## Providers Reference

### Core Providers (`database_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `databaseServiceProvider` | `Provider<DatabaseService>` | Database service singleton |
| `appDatabaseProvider` | `Provider<AppDatabase>` | Drift database instance |
| `trainingCycleDaoProvider` | `Provider<TrainingCycleDao>` | DAO access |
| `sessionDaoProvider` | `Provider<SessionDao>` | DAO access (v5+) |
| `sessionCardioDaoProvider` | `Provider<SessionCardioDao>` | DAO access |
| `sessionIntervalDaoProvider` | `Provider<SessionIntervalDao>` | DAO access |
| `sessionSampleDaoProvider` | `Provider<SessionSampleDao>` | DAO access |
| `cardioFeedbackDaoProvider` | `Provider<CardioFeedbackDao>` | DAO access |
| `cyclePeriodDaoProvider` | `Provider<CyclePeriodDao>` | DAO access |
| `sportZoneDaoProvider` | `Provider<SportZoneDao>` | DAO access |
| `exerciseDaoProvider` | `Provider<ExerciseDao>` | DAO access |
| `exerciseSetDaoProvider` | `Provider<ExerciseSetDao>` | DAO access |
| `exerciseFeedbackDaoProvider` | `Provider<ExerciseFeedbackDao>` | DAO access |
| `customExerciseDaoProvider` | `Provider<CustomExerciseDao>` | DAO access |
| `userMeasurementDaoProvider` | `Provider<UserMeasurementDao>` | DAO access |
| `skinDaoProvider` | `Provider<SkinDao>` | DAO access |
| `trainingCycleRepositoryProvider` | `Provider` | Repository access |
| `sessionRepositoryProvider` | `Provider` | Repository access (canonical) |
| `workoutRepositoryProvider` | `Provider` | Facade over SessionRepository |
| `exerciseRepositoryProvider` | `Provider` | Repository access |
| `customExerciseRepositoryProvider` | `Provider` | Repository access |
| `cyclePeriodRepositoryProvider` | `Provider` | Repository access |
| `sportZoneRepositoryProvider` | `Provider` | Repository access |
| `cardioFeedbackRepositoryProvider` | `Provider` | Repository access |
| `userMeasurementRepositoryProvider` | `Provider` | Repository access |

**Removed in Phase 6d:** `workoutDaoProvider` — the underlying table is gone; use `sessionDaoProvider` for equivalent queries filtered by `Sport.strength`.

### Training Cycle Providers (`training_cycle_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `trainingCyclesProvider` | `StreamProvider` | All training cycles |
| `currentTrainingCycleProvider` | `Provider` | Active (current status) cycle |
| `draftTrainingCyclesProvider` | `Provider` | Draft cycles |
| `completedTrainingCyclesProvider` | `Provider` | Completed cycles |
| `trainingCycleProvider(id)` | `Provider.family` | Single cycle by ID |
| `trainingCycleStatsProvider` | `Provider` | Cycle statistics |

### Session Providers (`session_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `sessionsProvider` | `StreamProvider<List<Session>>` | All sessions (strength + cardio) |
| `sessionsByTrainingCycleProvider(cycleId)` | `StreamProvider.autoDispose.family` | Sessions for a cycle |
| `sessionsBySportProvider(sport)` | `StreamProvider.family` | Sessions filtered to a sport |
| `cardioSessionsProvider` | `StreamProvider` | Cardio sessions only |
| `sessionsInDateRangeProvider(start, end)` | `StreamProvider.family` | Sessions within a date range |

### Workout Providers (`workout_providers.dart`)

Backed by the `WorkoutRepository` facade (which funnels through `SessionRepository`). These providers return the legacy `Workout` shape so existing strength-only UIs keep working.

| Provider | Type | Purpose |
|----------|------|---------|
| `workoutsProvider` | `StreamProvider` | All strength sessions as `Workout`s |
| `workoutsByTrainingCycleProvider(cycleId)` | `StreamProvider.family` | Strength workouts for a cycle |
| `workoutsByTrainingCycleListProvider(cycleId)` | `Provider.family` | Synchronous list access — reads from `sessionsByTrainingCycleProvider` and filters to `StrengthSession` |
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
| `cycleStatsProvider(cycleId)` | `FutureProvider.family` | Strength stats for one cycle |
| `lifetimeStatsProvider` | `FutureProvider` | All-time strength stats |
| `cycleWorkoutsProvider(cycleId)` | `FutureProvider.family` | Workouts for stats rendering |
| `cardioStatsProvider` | `Provider<CardioStats>` | Lifetime cardio aggregate |
| `cardioStatsForCycleProvider(cycleId)` | `Provider.autoDispose.family` | Cardio stats scoped to a cycle |
| `cardioStatsBySportProvider(sport)` | `Provider.autoDispose.family` | Cardio stats scoped to one sport |
| `recentCardioWeeksProvider(weeks)` | `Provider.autoDispose.family` | Padded weekly buckets for charts |
| `thisWeekVolumeProvider` | `Provider<WeeklyVolumeBucket>` | Current-week total volume |
| `thisWeekStrengthCountProvider` | `Provider<int>` | Current-week strength session count |

### Template Providers (`template_providers.dart`)

| Provider | Type | Purpose |
|----------|------|---------|
| `templateRepositoryProvider` | `Provider` | Template repository access |
| `availableTemplatesProvider` | `FutureProvider` | All available templates |
| `selectedTemplateProvider` | `NotifierProvider` | Currently selected template |

### Additional Provider Files

| File | Purpose |
|------|---------|
| `calendar_providers.dart` | Calendar data mapping, undo state for schedule changes, sport-day aggregation |
| `drift_providers.dart` | Low-level Drift stream providers |
| `navigation_providers.dart` | Bottom nav state, GoRouter instance, home tab index |
| `onboarding_providers.dart` | Onboarding flow state, selected sports, per-sport unit preferences |
| `skin_share_providers.dart` | Skin/theme sharing state |
| `sync_providers.dart` | WiFi sync service and status |
| `template_share_providers.dart` | Template sharing state |
| `theme_provider.dart` | Theme mode (light/dark/system), `themeModeProvider`, `isDarkModeProvider` |
| `health_sync_providers.dart` | HealthKit / Health Connect import state |
| `strava_providers.dart` | Strava OAuth and sync state |
| `zone_providers.dart` | Sport zones per metric per sport |

---

## Quick Reference: Finding Data

| To find... | Use provider... |
|------------|-----------------|
| All training cycles | `trainingCyclesProvider` |
| Single training cycle | `trainingCycleProvider(id)` |
| Current training cycle | `currentTrainingCycleProvider` |
| All sessions (any sport) | `sessionsProvider` |
| Sessions for a cycle | `sessionsByTrainingCycleProvider(cycleId)` |
| Cardio sessions only | `cardioSessionsProvider` |
| Strength workouts for a cycle (legacy shape) | `workoutsByTrainingCycleProvider(cycleId)` |
| Single workout | `workoutProvider(id)` |
| Sessions for a day | Filter `sessionsByTrainingCycleProvider` by `(periodNumber, dayNumber)` |
| Lifetime cardio stats | `cardioStatsProvider` |
| This week's volume | `thisWeekVolumeProvider` |
| Strength sessions this week | `thisWeekStrengthCountProvider` |
| All exercises (library) | `allExerciseDefinitionsProvider` |
| Custom exercises | `customExerciseDefinitionsProvider` |
| Current theme | `activeSkinProvider` |
| Strength cycle statistics | `cycleStatsProvider(cycleId)` |
| Cardio stats for a cycle | `cardioStatsForCycleProvider(cycleId)` |
| Available templates | `availableTemplatesProvider` |
| Sport zones | `sportZoneRepositoryProvider` (or a derived provider) |
