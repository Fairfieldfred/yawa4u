# YAWA4U Data Structure — v6 (multi-sport, workouts table dropped)

Refreshed reference for the app's data models, Drift schema, and state management after Phases 1–6.

This doc supersedes the v2 description in `.claude/rules/data_structure.md` (which is protected and can't be edited in-session; fold this back in when convenient).

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
| `cardioStatsProvider` | Lifetime cardio aggregate. |
| `cardioStatsForCycleProvider(cycleId)` | Cycle-scoped cardio stats. |
| `cardioStatsBySportProvider(sport)` | Single-sport lifetime stats. |
| `recentCardioWeeksProvider(n)` | Padded weekly buckets for charts. |
| `thisWeekVolumeProvider` | Current-week total volume. |
| `thisWeekStrengthCountProvider` | Strength sessions this week. |

### Health/sync providers

| Provider | File | Purpose |
|---|---|---|
| `healthSyncServiceProvider` | `health_sync_providers.dart` | The `HealthSyncService` singleton. |
| `healthSyncStatusProvider` | `health_sync_providers.dart` | Current permission state. |
| `stravaSyncServiceProvider` | `strava_providers.dart` | Strava OAuth + sync. |

---

## Enums (v6 accurate)

### In `core/constants/sports.dart`

| Enum | Values |
|---|---|
| `Sport` | strength, run, bike, swim, other |
| `SessionSource` | userPlanned, userLogged, healthKit, healthConnect, peloton, strava, garmin, imported |
| `StrokeType` | freestyle, backstroke, breaststroke, butterfly, mixed |
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

## Common-pitfall reminders

1. **Workout vs. Training Day.** Multiple `Workout` / `StrengthSession` rows per training day (one per muscle group). Aggregate by `(periodNumber, dayNumber)` when displaying.
2. **Stale snapshots.** `TrainingCycle.workouts` and `TrainingCycle.sessions` are snapshots populated at creation. For current state, always go through providers.
3. **Strength exercises read by `workoutUuid`** (legacy column name) but also have a `sessionUuid` set by the v5 backfill (equal value). New code should prefer `sessionUuid`. The `workouts` table no longer exists — the column name is just a legacy holdover.
4. **Cardio sessions don't have exercises.** A `StrengthSession` has `exercises`, a `CardioSession` has `detail` + `intervals`. Branch in switches; don't unify the lists.
5. **CardioFeedback is separate.** Not a field on `CardioSession`. Load via `cardioFeedbackProvider(sessionId)` or `CardioFeedbackRepository`.
6. **WorkoutRepository is a facade.** It wraps `SessionRepository` with `Workout` ↔ `StrengthSession` conversion. No direct DB access. New code should prefer `SessionRepository` directly.
7. **Planned vs logged cardio.** Sessions created via draft cycle planning use `SessionSource.userPlanned` and `WorkoutStatus.incomplete`. The card shows a "Log" button to mark as completed.
