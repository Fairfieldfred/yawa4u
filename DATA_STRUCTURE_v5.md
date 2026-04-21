# YAWA4U Data Structure — v5 (multi-sport)

Refreshed reference for the app's data models, Drift schema, and state management after Phases 1–5.

This doc supersedes the v2 description in `.claude/rules/data_structure.md` (which is protected and can't be edited in-session; fold this back in when convenient).

---

## Drift Database Tables

Schema version **5**. Every table has an auto-incrementing integer `id` plus a `uuid` text field for app-level identification.

### Core (pre-multi-sport)

| Table | Model | FK | Purpose |
|---|---|---|---|
| `training_cycles` | `TrainingCycle` | — | Training program definitions. v5 added `primarySport`, `creatorUuid`, `ownerUuid`. |
| `workouts` | `Workout` | `trainingCycleUuid` → `training_cycles.uuid` | **Legacy.** Every row is mirrored into `sessions` via v5 backfill. Will be dropped in v6 once strength UI reads through `SessionRepository`. |
| `exercises` | `Exercise` | `workoutUuid` → `workouts.uuid`; **v5** `sessionUuid` → `sessions.uuid` | Strength exercise instances. |
| `exercise_sets` | `ExerciseSet` | `exerciseUuid` → `exercises.uuid` | Set data (weight, reps, etc.). |
| `exercise_feedbacks` | `ExerciseFeedback` | `exerciseUuid` (unique); **v5** `sessionUuid` | 1:1 post-exercise feedback. Strength-only. |
| `custom_exercise_definitions` | `CustomExerciseDefinition` | — | User-created exercises. |
| `user_measurements` | `UserMeasurement` | — | Body composition tracking. |
| `skins` | `SkinModel` | — | Custom themes. |

### v5 multi-sport additions

| Table | Model | FK | Purpose |
|---|---|---|---|
| `sessions` | sealed `Session` → `StrengthSession` / `CardioSession` | `trainingCycleUuid` (nullable) | Polymorphic "training action" for any sport. |
| `cycle_periods` | `CyclePeriod` | `trainingCycleUuid` | 1 row per (cycle, periodNumber). Carries `phase` (base / build / peak / taper / transition) for cardio periodization. |
| `session_cardio` | `CardioDetail` (loaded into `CardioSession.detail`) | `sessionUuid` unique (1:1) | Aggregate cardio metrics — distance, duration, HR, pace, power, elevation, swim fields. |
| `session_intervals` | `SessionInterval` | `sessionUuid` | Structured cardio steps. |
| `session_samples` | `SessionSample` | `sessionUuid` | High-resolution recorded streams (GPS, HR). Optional. |
| `sport_zones` | `SportZone` | — | User-configured HR / pace / power zones per sport. |
| `cardio_feedback` | `CardioFeedback` | `sessionUuid` unique (1:1) | Post-cardio RPE / breathing / GI / weather. |

### Coach-mode hooks (v5)

Every user-owned row has nullable `creatorUuid` and `ownerUuid` columns (set to a local-user UUID by the v5 backfill). No coach-mode features ship today; the columns exist so adding multi-user later is additive, not structural.

### Migration timeline

| From → To | Summary |
|---|---|
| v1 → v2 | `secondaryMuscleGroup` on exercises + custom definitions |
| v2 → v3 | `startTime` / `endTime` on workouts |
| v3 → v4 | `restSeconds` on exercises + custom definitions |
| v4 → v5 | Multi-sport: every table above created + backfilled; workouts → sessions mirror; cycle_periods generated |
| v5 → v6 (planned) | Drop legacy `workouts` once strength UI migrates. Drop `exercises.workoutUuid`. |

---

## Terminology convention

- **Workout** — user-facing label everywhere.
- **Session** — code-level name (sealed class + repositories + DAOs + mappers). Don't rename back to Workout.
- **Period** — repeating unit of a training cycle. Not always 7 days.
- **Step** — in-UI label for an interval inside a structured cardio session.

See `TERMINOLOGY.md` at repo root for full rationale.

---

## Session model (v5)

```dart
sealed class Session {
  String id;
  String? trainingCycleId;
  Sport sport;
  SessionSource source;           // userPlanned, userLogged, healthKit, healthConnect, …
  WorkoutStatus status;            // enum reused from v4
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

---

## Repositories (additive on v5)

| Repo | Backs |
|---|---|
| `TrainingCycleRepository` | `training_cycles` |
| `WorkoutRepository` | **Legacy strength flow.** Still the primary write path for `exercises` + `exercise_sets`. Phase 6 target for rewrite. |
| `SessionRepository` | `sessions` + children. Cardio writes go here; strength reads are possible via sealed-switch return. |
| `CyclePeriodRepository` | `cycle_periods` |
| `SportZoneRepository` | `sport_zones` |
| `CardioFeedbackRepository` | `cardio_feedback` |
| `CustomExerciseRepository`, `UserMeasurementRepository`, `ExerciseRepository` | (unchanged since v4) |

---

## Key providers (v5)

In `lib/domain/providers/session_providers.dart`:

- `sessionsProvider` — all sessions (reactive).
- `sessionsByTrainingCycleProvider(cycleId)` — reactive.
- `sessionsBySportProvider((cycleId?, sport))` — filtered by sport, optionally scoped to a cycle.
- `cardioSessionsProvider` — every non-strength session.
- `sessionsInDateRangeProvider((start, end))` — for weekly summaries / calendar dots.
- `sessionProvider(id)` — single session, children loaded (excluding samples).
- `sessionWithSamplesProvider(id)` — same plus high-resolution samples (heavy).
- `cyclePeriodsProvider(cycleId)` — reactive list of periods.
- `sportZonesProvider(sport)` — reactive zones for a sport.
- `cardioFeedbackProvider(sessionId)` — reactive feedback.

Cardio stats providers live in `stats_providers.dart`:

- `cardioStatsProvider` (lifetime)
- `cardioStatsForCycleProvider(cycleId)`
- `cardioStatsBySportProvider(sport)`
- `recentCardioWeeksProvider(n)`
- `thisWeekVolumeProvider`, `thisWeekStrengthCountProvider`

Health integration in `health_providers.dart`:

- `healthSyncServiceProvider` — the `HealthSyncService` singleton.
- `healthSyncStatusProvider` — current permission state.

---

## Backup format

`DataBackupService` exports JSON at `version: 4` as of Phase 3B. Includes:

- `trainingCycles`, `workouts`, `exercises`, `customExercises` (v3 shape).
- **v4 additions:** `cardioSessions`, `cyclePeriods`, `sportZones`, `cardioFeedbacks`.
- `customThemes` (v3).

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
3. **Strength exercises read by `workoutUuid`** (legacy) but also have a `sessionUuid` set by the v5 backfill (equal value). New code should prefer `sessionUuid`.
4. **Cardio sessions don't have exercises.** A `StrengthSession` has `exercises`, a `CardioSession` has `detail` + `intervals`. Branch in switches; don't unify the lists.
