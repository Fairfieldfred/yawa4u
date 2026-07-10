# YAWA4U Data Structure — v6 (multi-sport, workouts table dropped)

Canonical reference for the app's data models, Drift schema, and state management after Phases 1–6.

---

## Drift Database Tables

Schema version **6**. Every table has an auto-incrementing integer `id` plus a `uuid` text field for app-level identification.

### Core tables

| Table | Model | FK | Purpose |
|---|---|---|---|
| `training_cycles` | `TrainingCycle` | — | Training program definitions. Has `primarySport`, `creatorUuid`, `ownerUuid`. |
| `sessions` | sealed `Session` → `StrengthSession` / `CardioSession` | `trainingCycleUuid` (nullable) | **Canonical source of truth.** Polymorphic "training action" for any sport. |
| `exercises` | `Exercise` | `workoutUuid` (legacy column name — holds StrengthSession UUID); `sessionUuid` → `sessions.uuid` | Strength exercise instances. |
| `exercise_sets` | `ExerciseSet` | `exerciseUuid` → `exercises.uuid` | Set data (weight, reps, etc.). |
| `exercise_feedbacks` | `ExerciseFeedback` | `exerciseUuid` (unique); `sessionUuid` | 1:1 post-exercise feedback. Strength-only. |
| `custom_exercise_definitions` | `CustomExerciseDefinition` | — | User-created exercises. |
| `user_measurements` | `UserMeasurement` | — | Body composition tracking. |
| `skins` | `SkinModel` | — | Custom themes. |

### Multi-sport tables (added v5)

| Table | Model | FK | Purpose |
|---|---|---|---|
| `cycle_periods` | `CyclePeriod` | `trainingCycleUuid` | 1 row per (cycle, periodNumber). Carries `phase` (base / build / peak / taper / transition) for cardio periodization. |
| `session_cardio` | `CardioDetail` (loaded into `CardioSession.detail`) | `sessionUuid` unique (1:1) | Aggregate cardio metrics — distance, duration, HR, pace, power, elevation, swim fields. Has planned vs actual pairs. |
| `session_intervals` | `SessionInterval` | `sessionUuid` | Structured cardio steps with target/actual pairs. |
| `session_samples` | `SessionSample` | `sessionUuid` | High-resolution recorded streams (GPS, HR). Optional — not loaded by default. |
| `sport_zones` | `SportZone` | — | User-configured HR / pace / power zones per sport. |
| `cardio_feedback` | `CardioFeedback` | `sessionUuid` unique (1:1) | Post-cardio RPE / breathing / GI / weather. Loaded separately via `CardioFeedbackRepository`, **not** a field on `CardioSession`. |

### Dropped tables

| Table | Dropped in | Reason |
|---|---|---|
| `workouts` | v6 | Every row was copied into `sessions` by the v5 backfill. `WorkoutRepository` is now a facade over `SessionRepository`. |

### Coach-mode hooks

Every user-owned row has nullable `creatorUuid` and `ownerUuid` columns (set to a local-user UUID by the v5 backfill). No coach-mode features ship today; the columns exist so adding multi-user later is additive, not structural.

### Migration timeline

| From → To | Summary |
|---|---|
| v1 → v2 | `secondaryMuscleGroup` on exercises + custom definitions |
| v2 → v3 | `startTime` / `endTime` on workouts |
| v3 → v4 | `restSeconds` on exercises + custom definitions |
| v4 → v5 | Multi-sport: all new tables created + backfilled; workouts → sessions mirror; cycle_periods generated |
| v5 → v6 | **Dropped `workouts` table.** Indexes dropped first, then `DROP TABLE IF EXISTS workouts`. `WorkoutRepository` became a facade over `SessionRepository`. Column rename of `exercises.workoutUuid` deferred (SQLite column renames are expensive). |

---

## Terminology convention

- **Workout** — user-facing label everywhere.
- **Session** — code-level name (sealed class + repositories + DAOs + mappers). Don't rename back to Workout.
- **Period** — repeating unit of a training cycle. Not always 7 days.
- **Step** — in-UI label for an interval inside a structured cardio session.

See `TERMINOLOGY.md` at repo root for full rationale.

---

## Session model (v6)

```dart
sealed class Session {
  String id;
  String? trainingCycleId;
  Sport sport;
  SessionSource source;           // userPlanned, userLogged, healthKit, healthConnect, …
  WorkoutStatus status;            // incomplete, completed, skipped
  int? periodNumber, dayNumber;    // nullable — ad-hoc sessions don't have a slot
  String? dayName, label, notes, externalId;
  DateTime? scheduledDate, completedDate, startTime, endTime;
  String? creatorUuid, ownerUuid;  // coach-mode hooks
}

class StrengthSession extends Session {
  List<Exercise> exercises;        // loaded by SessionRepository
}

class CardioSession extends Session {
  CardioDetail? detail;            // session_cardio row (nullable for pure plan)
  List<SessionInterval> intervals; // session_intervals rows
  List<SessionSample>? samples;    // session_samples — only loaded on explicit request
}
```

Because `Session` is **sealed**, every `switch (session)` is exhaustiveness-checked at compile time. When adding new sport variants, every switch site must be updated.

**Note:** `CardioFeedback` is **not** a field on `CardioSession`. It is loaded separately via `CardioFeedbackRepository` / `cardioFeedbackProvider(sessionId)`.

### Planned vs Logged cardio sessions

The `CardioSessionScreen` supports two modes:
- **Plan mode** (`planned: true`): creates with `source: SessionSource.userPlanned`, `status: WorkoutStatus.incomplete`, no `completedDate`. `CardioDetail` populates `plannedDistanceM` / `plannedDurationSec`.
- **Log mode** (default): creates with `source: SessionSource.userLogged`, `status: WorkoutStatus.completed`, sets `completedDate`. `CardioDetail` populates `actualDistanceM` / `actualDurationSec`.

When editing a planned session, the form prefills from planned values (falling back: `actualDistanceM ?? plannedDistanceM`). Saving promotes the session to completed.

---

## Key models

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
  double? averageCadence;
  double? averagePowerWatts;
  double? normalizedPowerWatts;
  double? averageSpeedMps;
  double? averagePaceSecPerMeter;
  // Swim-specific
  double? poolLengthM;
  StrokeType? strokeType;
  int? lapCount;
  int? swolf;
  // Subjective
  int? perceivedExertion; // 1..10
  String? notes;

  bool get hasActuals; // checks for any non-null actual value
}
```

### SessionInterval

Structured cardio step with target/actual pairs. Intervals can nest — a `repeatGroup` holds child intervals via `parentIntervalId`.

```dart
class SessionInterval {
  String id;
  String sessionId;
  int orderIndex;
  IntervalIntent intent;           // warmup, work, recovery, cooldown, rest, repeatGroup
  IntervalTargetKind targetKind;   // durationSec, distanceM, hrZone, paceZone, powerZone, freeform

  // Target values
  int? targetDurationSec;
  double? targetDistanceM;
  int? targetHrZone;
  int? targetPaceZone;
  int? targetPowerZone;
  double? targetValueMin, targetValueMax;
  String? targetFreeform;

  // Actual (executed) values
  int? actualDurationSec;
  double? actualDistanceM;
  int? actualAverageHr;
  double? actualAveragePaceSecPerMeter;
  double? actualAveragePowerWatts;

  // Repeat-group support
  int? repeatCount;
  String? parentIntervalId;

  String? notes;
}
```

### CardioFeedback

Separate 1:1 model loaded via repository, **not** a field on `CardioSession`.

```dart
class CardioFeedback {
  int? rpe;          // 1..10
  int? breathing;    // 1..5 (1 = very laboured, 5 = barely winded)
  int? giComfort;    // 1..5 (1 = awful, 5 = perfect)
  String? weather;
  String? notes;
  DateTime? timestamp;
  String? creatorUuid;
  String? ownerUuid;
}
```

### CyclePeriod

```dart
class CyclePeriod {
  String id;
  String trainingCycleId;
  int periodNumber;           // 1-indexed
  TrainingPhase? phase;       // base, build, peak, taper, transition
  String? notes;
  String? creatorUuid;
  String? ownerUuid;
}
```

---

## Repositories (v6)

| Repo | Backs | Notes |
|---|---|---|
| `SessionRepository` | `sessions` + all children | **Canonical.** Handles both strength and cardio creates/reads/writes. |
| `WorkoutRepository` | **Facade over `SessionRepository`** | Translates legacy `Workout` shape ↔ `StrengthSession`. Still used by 20+ strength UI call sites. No direct DB access. |
| `TrainingCycleRepository` | `training_cycles` | Cycle CRUD, status filtering, duplication. |
| `CyclePeriodRepository` | `cycle_periods` | Per-period metadata. |
| `SportZoneRepository` | `sport_zones` | HR/pace/power zones per sport. |
| `CardioFeedbackRepository` | `cardio_feedback` | Post-cardio feedback. |
| `ExerciseRepository` | `exercises` | Exercise CRUD, muscle/equipment filtering. |
| `CustomExerciseRepository` | `custom_exercise_definitions` | User-created exercise definitions. |
| `UserMeasurementRepository` | `user_measurements` | Body measurements, BMI history. |
| `TemplateRepository` | in-memory | Training cycle + cardio session templates. |
| `CommunityRepository` | Firestore (`community_templates`, `community_skins`) | Firestore-backed community library. Browse, download, upload templates and skins. Delegates I/O to `CommunityService`. |

---

## Key providers (v6)

### Session providers (`session_providers.dart`)

| Provider | Type | Purpose |
|---|---|---|
| `sessionsProvider` | `StreamProvider` | All sessions (reactive). |
| `sessionsByTrainingCycleProvider(cycleId)` | `StreamProvider.autoDispose.family` | Sessions for a cycle. |
| `sessionsBySportProvider((cycleId?, sport))` | `StreamProvider` | Filtered by sport, optionally scoped to a cycle. |
| `cardioSessionsProvider` | `StreamProvider` | Every non-strength session. |
| `sessionsInDateRangeProvider((start, end))` | `StreamProvider` | For weekly summaries / calendar dots. |
| `todaysSessionsProvider` | `StreamProvider` | Today's sessions (auto-computed date range). |
| `sessionProvider(id)` | `FutureProvider.family` | Single session, children loaded (excluding samples). |
| `sessionWithSamplesProvider(id)` | `FutureProvider.family` | Same plus high-resolution samples (heavy). |
| `cycleSessionDistributionProvider(cycleId)` | `Provider.autoDispose.family` | `Map<Sport, int>` — session count per sport in a cycle. Used by `SportDistributionRibbon`. |

### Related providers

| Provider | File | Purpose |
|---|---|---|
| `cyclePeriodsProvider(cycleId)` | `session_providers.dart` | Reactive list of periods. |
| `sportZonesProvider(sport)` | `session_providers.dart` | Reactive zones for a sport. |
| `cardioFeedbackProvider(sessionId)` | `session_providers.dart` | Reactive feedback. |

### Stats providers (`stats_providers.dart`)

| Provider | Purpose |
|---|---|
| `cycleStatsProvider(cycleId)` | Strength cycle statistics (per-cycle). |
| `lifetimeStatsProvider` | Lifetime strength aggregate. |
| `cycleWorkoutsProvider(cycleId)` | Workouts list for a cycle (used by stats). |
| `cardioStatsProvider` | Lifetime cardio aggregate. |
| `cardioStatsForCycleProvider(cycleId)` | Cycle-scoped cardio stats. |
| `cardioStatsBySportProvider(sport)` | Single-sport lifetime stats. |
| `recentCardioWeeksProvider(n)` | Padded weekly buckets for charts. |
| `thisWeekVolumeProvider` | Current-week total volume. |
| `thisWeekStrengthCountProvider` | Strength sessions this week. |

### Health/sync providers

| Provider | File | Purpose |
|---|---|---|
| `healthSyncServiceProvider` | `health_providers.dart` | The `HealthSyncService` singleton. |
| `healthSyncStatusProvider` | `health_providers.dart` | Current permission state. |
| `stravaIntegrationServiceProvider` | `health_providers.dart` | Strava OAuth + sync. |
| `stravaSyncStatusProvider` | `health_providers.dart` | Strava sync state. |

### Training Cycle providers (`training_cycle_providers.dart`)

| Provider | Type | Purpose |
|---|---|---|
| `trainingCyclesProvider` | `StreamProvider` | All training cycles. |
| `currentTrainingCyclesProvider` | `Provider` | All active (current status) cycles — supports stacking. |
| `currentTrainingCycleProvider` | `Provider` | Primary active cycle (first from `currentTrainingCyclesProvider`). |
| `draftTrainingCyclesProvider` | `Provider` | Draft cycles. |
| `completedTrainingCyclesProvider` | `Provider` | Completed cycles. |
| `trainingCycleProvider(id)` | `Provider.family` | Single cycle by ID. |
| `trainingCycleStatsProvider` | `Provider` | Cycle statistics. |

### Workout providers (`workout_providers.dart`)

Backed by the `WorkoutRepository` facade (which funnels through `SessionRepository`). Returns the legacy `Workout` shape so existing strength-only UIs keep working.

| Provider | Type | Purpose |
|---|---|---|
| `workoutsProvider` | `StreamProvider` | All strength sessions as `Workout`s. |
| `workoutsByTrainingCycleProvider(cycleId)` | `StreamProvider.family` | Strength workouts for a cycle. |
| `workoutsByTrainingCycleListProvider(cycleId)` | `Provider.family` | Synchronous list access — filters to `StrengthSession`. |
| `workoutsByPeriodProvider` | `FutureProvider.family` | Workouts for a period. |
| `workoutProvider(id)` | `Provider.family` | Single workout by ID. |
| `completedWorkoutsProvider` | `Provider` | Completed workouts. |
| `todayWorkoutsProvider` | `FutureProvider` | Today's workouts. |
| `upcomingWorkoutsProvider` | `FutureProvider` | Upcoming workouts. |
| `workoutStatsProvider` | `Provider` | Lifetime workout statistics. |
| `workoutStatsForTrainingCycleProvider(cycleId)` | `Provider.family` | Per-cycle workout statistics. |
| `showExerciseHistoryProvider` | `NotifierProvider` | Toggle exercise history display. |

### Exercise providers (`exercise_providers.dart`)

| Provider | Type | Purpose |
|---|---|---|
| `exerciseDefinitionsProvider` | `Provider` | CSV library definitions. |
| `customExerciseDefinitionsProvider` | `StreamProvider` | User-created definitions. |
| `allExerciseDefinitionsProvider` | `Provider` | Combined CSV + custom definitions. |
| `exercisesByWorkoutProvider(id)` | `FutureProvider.family` | Exercises for a workout. |
| `exerciseHistoryServiceProvider` | `Provider` | History service access. |
| `previousPerformanceProvider` | `FutureProvider.family` | Previous performance data. |

### Template providers (`template_providers.dart`)

| Provider | Type | Purpose |
|---|---|---|
| `templateRepositoryProvider` | `Provider` | Template repository access. |
| `availableTemplatesProvider` | `FutureProvider` | All available templates. |
| `selectedTemplateProvider` | `NotifierProvider` | Currently selected template. |

### Additional provider files

| File | Purpose |
|---|---|
| `calendar_providers.dart` | Calendar data mapping, undo state for schedule changes, sport-day aggregation. `calendarMonthDataProvider` merges **all** active (stacked) cycles per date. `CalendarUndoState` holds a **list** of per-cycle `(cycleId, ScheduleSnapshot)` entries so a multi-cycle edit undoes in one step. |
| `drift_providers.dart` | Low-level Drift stream providers. |
| *(removed)* | `navigation_providers.dart` was deleted — tabs are StatefulShellRoute branches; navigate with `context.go('/cycles')` etc. |
| `onboarding_providers.dart` | Onboarding flow state, selected sports, per-sport unit preferences, training cycle term. |
| `skin_share_providers.dart` | Skin/theme sharing state. |
| `sync_providers.dart` | WiFi sync service and status. |
| `template_share_providers.dart` | Template sharing state. |
| `theme_provider.dart` | Theme mode (light/dark/system), `themeModeProvider`, `isDarkModeProvider`. |
| `cardio_library_providers.dart` | Cardio session template library by sport. |
| `measurement_providers.dart` | User body measurement tracking. |
| `rest_timer_provider.dart` | Rest timer between sets management. |
| `use_case_providers.dart` | Use case dependency providers (finish/skip/reset workout, add set, start/end cycle). |
| `auth_providers.dart` | Firebase auth state — `firebaseAuthServiceProvider`, `authStateProvider`, `currentUserProvider`, `isEmailVerifiedProvider`, `canUploadProvider`. |
| `community_providers.dart` | Community library browsing/upload — sort, filter, pagination for templates and skins. |
| `database_providers.dart` | Database and repository dependency injection providers. |

---

## Enums (v6 accurate)

### In `core/constants/sports.dart`

| Enum | Values |
|---|---|
| `Sport` | strength, run, bike, swim, other |
| `SessionSource` | userPlanned, userLogged, healthKit, healthConnect, peloton, strava, garmin, imported |
| `StrokeType` | freestyle, backstroke, breaststroke, butterfly, mixed, drill |
| `IntervalIntent` | warmup, work, recovery, cooldown, rest, repeatGroup |
| `IntervalTargetKind` | durationSec, distanceM, hrZone, paceZone, powerZone, freeform |
| `ZoneMetric` | hr, pace, power |
| `UnitSystem` | metric, imperial |

`SessionSource` has `.isExternal` extension: returns `true` for all except `userPlanned` and `userLogged`.

### In `core/constants/enums.dart`

| Enum | Values |
|---|---|
| `TrainingPhase` | base, build, peak, taper, transition |
| `SetType` | regular, myorep, myorepMatch, maxReps, endWithPartials, dropSet |
| `JointPain` | none, low, moderate, severe |
| `MusclePump` | low, moderate, amazing |
| `Workload` | easy, prettyGood, pushedLimits, tooMuch |
| `Soreness` | neverGotSore, healedAWhileAgo, healedJustOnTime, stillSore |
| `Gender` | male, female |
| `TrainingCycleStatus` | draft, current, completed |
| `WorkoutStatus` | incomplete, completed, skipped |
| `RecoveryPeriodType` | deload, taper, recovery |

---

## Backup format

`DataBackupService` exports JSON at `version: 4`. Includes:

- `trainingCycles`, `workouts`, `exercises`, `customExercises` (v3 shape).
- **v4 additions:** `cardioSessions`, `cyclePeriods`, `sportZones`, `cardioFeedbacks`.
- Structured intervals rolled into each `CardioSession`'s `intervals` field.
- Samples intentionally excluded (too heavy; re-fetched on-demand via import).
- `customThemes`.

`version: 3` imports are accepted and produce a backup with no cardio content — fully back-compat.

---

## Onboarding prefs

`OnboardingService` is backed by SharedPreferences. v5 additions:

- `perSportUnits` — `Map<Sport, UnitSystem>` per-sport unit override.
- `selectedSports` — list of sports the user opted into during onboarding.
- Helpers: `unitsFor(sport)`, `setUnitsFor(sport, units)`, `hasSport(sport)`.

---

## Additional model definitions

### Workout (legacy adapter shape)

The historical strength-training shape. Still used by every UI that existed before Phase 6 because the facade in `WorkoutRepository` translates `StrengthSession` ↔ `Workout` at the boundary.

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

Top-level container for a training program. Multi-sport capable.

```dart
class TrainingCycle {
  String id;
  String name;
  int periodsTotal;
  int daysPerPeriod;                      // Default varies by primarySport
  int recoveryPeriod;
  RecoveryPeriodType recoveryPeriodType;  // Private backing field with deload fallback
  TrainingCycleStatus status;
  Gender? gender;
  Sport? primarySport;                    // UI hint only
  String? creatorUuid;
  String? ownerUuid;
  DateTime createdDate;
  DateTime? startDate;
  DateTime? endDate;
  List<Workout> workouts;                 // ⚠️ SNAPSHOT — see pitfalls
  Map<String, int>? muscleGroupPriorities;
  String? templateName;
  String? notes;
}
```

### Exercise

An exercise instance within a strength session.

```dart
class Exercise {
  String id;
  String workoutId;                       // Holds the StrengthSession UUID (legacy column name)
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

### SportZone

User-configured training zones per sport. Typically 5 zones per sport.

```dart
class SportZone {
  String id;
  Sport sport;
  int zoneNumber;          // 1..5
  double minValue;
  double maxValue;
  String unit;             // "bpm", "sec_per_km", "sec_per_mi", "watts"
  String? ownerUuid;
  DateTime createdAt;

  bool contains(double value); // value ∈ [min, max)
}
```

### SessionSample

Time-series datapoint from an imported activity (typically 1 Hz). Not loaded by default — pass `includeSamples: true` to `SessionRepository.getById`.

```dart
class SessionSample {
  String sessionId;
  int offsetSec;                          // Seconds from session start
  double? lat;
  double? lng;
  double? altitudeM;
  int? hr;
  double? cadence;
  double? powerW;
  double? speedMps;
  double? strokeRate;
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

### Stats models

```dart
// lib/data/models/stats_data.dart
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

// lib/data/models/cardio_stats.dart
class CardioStats {
  Map<Sport, SportAggregate> perSport;
  List<WeeklyVolumeBucket> weeklyBuckets;
  // fromSessions() factory folds a List<Session> into aggregates.
  // recentWeeks(int n) returns padded weekly buckets for charts.
}
```

### Template models

`lib/data/models/training_cycle_template.dart` and `lib/data/models/cardio_session_template.dart`. Templates can contain both strength workouts and cardio sessions so a template describes a mixed-sport block end-to-end.

---

## Exercise Library Sources

### CSV Library (built-in)

Location: `exercises.csv` (project root, declared in `pubspec.yaml`). ~353 exercises loaded at startup via `CsvLoaderService`. Format: `Name,Muscle Group,Equipment`. Parsed into `ExerciseDefinition` (in-memory only).

### Custom Exercises (user-created)

Stored in Drift via `CustomExerciseDefinition`. Converts to `ExerciseDefinition` via `toExerciseDefinition()`.

**Access combined library via `allExerciseDefinitionsProvider`.**

### Cardio Session Library

`lib/data/services/cardio_session_library_service.dart` loads a catalog of stock cardio templates from `assets/cardio_sessions/*.json` at startup. Used by the cardio session creator's "From template" flow.

---

## Services

| Service | Location | Purpose |
|---|---|---|
| `AnalyticsService` | `data/services/` | Firebase analytics event tracking |
| `CsvLoaderService` | `data/services/` | Load exercise library from CSV |
| `CardioSessionLibraryService` | `data/services/` | Load cardio session templates from assets |
| `DataBackupService` | `data/services/` | JSON backup/restore (v4 schema — multi-sport) |
| `DatabaseService` | `data/services/` | Drift database initialization and lifecycle |
| `ExerciseHistoryService` | `data/services/` | Previous exercise performances |
| `HealthSyncService` | `data/services/` | Apple Health / Health Connect import via `health` package |
| `StravaIntegrationService` | `data/services/` | OAuth + sync for Strava activities |
| `OnboardingService` | `data/services/` | Onboarding flow state + per-sport unit preferences |
| `ScheduleService` | `data/services/` | Session scheduling, calendar shift/move, rest-day insert/remove. Date-based methods (`insertDayBeforeDate`, `removeRestDay`) shift both strength workouts and cardio sessions (`_shiftCardioByDate`, skipping external imports). `ScheduleSnapshot` carries `workoutSnapshots` + `cardioSnapshots` for undo |
| `SkinShareService` | `data/services/` | Share custom themes between devices |
| `TemplateShareService` | `data/services/` | Share training templates between devices |
| `ThemeImageService` | `data/services/` | Theme image management for custom skins |
| `WifiSyncService` | `data/services/` | Device-to-device sync over local network |
| `CommunityService` | `data/services/` | Low-level Firestore + Storage I/O for community templates and skins |
| `FirebaseAuthService` | `data/services/` | Firebase Auth wrapper — anonymous sign-in at app init, email link-up for uploads |

---

## Database Architecture

### File structure

```
lib/data/database/
├── database.dart           # Barrel export
├── app_database.dart       # @DriftDatabase, schema v6, migration strategy
├── app_database.g.dart     # Generated code
├── tables.dart             # All table definitions
├── converters.dart         # Type converters (enums, dates, JSON)
├── migrations/
│   └── v5_backfill.dart    # Copies legacy workouts rows into sessions on v4→v5 upgrade
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
    ├── mappers.dart             # Barrel export
    ├── entity_mappers.dart      # TrainingCycle, Exercise, ExerciseSet, ExerciseFeedback
    ├── session_mappers.dart     # Session, CardioDetail, Interval, Sample, Zone, Feedback, CyclePeriod
    └── secondary_mappers.dart   # CustomExercise, UserMeasurement
```

`WorkoutMapper` was removed in Phase 6d. `workout_dao.dart` exists as an empty stub (not exported).

### Code generation

After modifying database tables or DAOs:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## State management patterns

### Reactive Drift via StreamProvider

```dart
final trainingCyclesProvider = StreamProvider<List<TrainingCycle>>((ref) {
  final repository = ref.watch(trainingCycleRepositoryProvider);
  return repository.watchAll();
});
```

### Parameterized access (Provider.family)

```dart
final sessionsByTrainingCycleProvider =
    StreamProvider.autoDispose.family<List<Session>, String>((ref, cycleId) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.watchByTrainingCycleId(cycleId);
});
```

### Repository pattern

`SessionRepository` is the current source of truth; `WorkoutRepository` is a thin facade over it.

```dart
class SessionRepository {
  Future<Session?> getById(String id, {bool includeSamples = false});
  Stream<List<Session>> watchAll();
  Stream<List<Session>> watchByTrainingCycleId(String trainingCycleId);
  Stream<List<Session>> watchBySport(Sport sport);
  Stream<List<Session>> watchCardio();
  Stream<List<Session>> watchByDateRange(DateTime start, DateTime end);
  Future<Session?> getByExternalId(String externalId);

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

### DAO layer

Each table has a corresponding DAO. Use them directly only when you need a single-row update that bypasses the hierarchy-load cost (e.g., the debounced weight/reps writes on `workout_screen`).

---

## Quick reference: finding data

| To find... | Use provider... |
|---|---|
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
| Sport zones | `sportZonesProvider(sport)` |

---

## Common-pitfall reminders

1. **Workout vs. Training Day.** Multiple `Workout` / `StrengthSession` rows per training day (one per muscle group). Aggregate by `(periodNumber, dayNumber)` when displaying.
2. **Stale snapshots.** `TrainingCycle.workouts` and `TrainingCycle.sessions` are snapshots populated at creation. For current state, always go through providers.
3. **Strength exercises read by `workoutUuid`** (legacy column name) but also have a `sessionUuid` set by the v5 backfill (equal value). New code should prefer `sessionUuid`. The `workouts` table no longer exists — the column name is just a legacy holdover.
4. **Cardio sessions don't have exercises.** A `StrengthSession` has `exercises`, a `CardioSession` has `detail` + `intervals`. Branch in switches; don't unify the lists.
5. **CardioFeedback is separate.** Not a field on `CardioSession`. Load via `cardioFeedbackProvider(sessionId)` or `CardioFeedbackRepository`.
6. **WorkoutRepository is a facade.** It wraps `SessionRepository` with `Workout` ↔ `StrengthSession` conversion. No direct DB access. New code should prefer `SessionRepository` directly.
7. **Planned vs logged cardio.** Sessions created via draft cycle planning use `SessionSource.userPlanned` and `WorkoutStatus.incomplete`. The card shows a "Log" button to mark as completed.
8. **Calendar schedule edits are multi-cycle and date-based.** The calendar renders **all** active (stacked) cycles, so any schedule edit (rest-day insert/remove) must loop over `currentTrainingCyclesProvider` (plural) — not `currentTrainingCycleProvider` (the primary only) — and shift by **calendar date**, because each cycle maps the same date to a different `(periodNumber, dayNumber)`. Use the date-based `ScheduleService.insertDayBeforeDate` / `removeRestDay`. They shift strength **and** cardio (`_shiftCardioByDate`), changing only `scheduledDate` and skipping external imports (`session.isReadOnly`). Undo (`CalendarUndoState`) stores one snapshot per affected cycle. ⚠️ The drag-drop handlers `moveExerciseToDate` / `moveCardioToDate` still use the singular primary-cycle provider — same latent bug if a secondary cycle's item becomes draggable.
