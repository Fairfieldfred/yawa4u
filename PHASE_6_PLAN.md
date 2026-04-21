# Phase 6 — Post-multi-sport cleanup

Deferred from Phase 5.5. None of this is urgent — everything works today — but closing it out removes long-term cruft and makes future changes safer.

## Goal

Drop the legacy `workouts` table and the `WorkoutRepository` shim, migrate all strength-flow reads/writes through `SessionRepository`, and update docs to reflect the cleaner post-v6 world.

## Why it's Phase 6 instead of Phase 5.5

The original Phase 5.5 plan assumed "all code reads from sessions" by end of Phase 3. That didn't actually happen — Phase 3 added cardio UI alongside strength UI without replacing the strength code path. These screens still write through `WorkoutRepository`:

- `workout_screen.dart` (`WorkoutHomeScreen`)
- `edit_workout_screen.dart`
- `stats_screen.dart` (Overview tab)
- `cycle_list_screen.dart` (some reads)
- The controllers under `lib/domain/controllers/` for workout flows

Dropping the `workouts` table without first migrating these would break every strength user instantly. Phase 6 is the right vehicle for that rewrite.

## Scope

### 1. Migrate strength UI to `SessionRepository`

The goal is that every read / write that today hits `WorkoutRepository` goes through `SessionRepository` instead, branching on `session is StrengthSession`.

- `WorkoutHomeScreen` — use `sessionsByTrainingCycleProvider`. Filter to `sport == Sport.strength` for the current display. The per-set / per-exercise update paths (`_updateSetWeight`, `_updateSetReps`, `_deleteSet`, `_toggleSetLogged`) keep working because they still operate on `Exercise` / `ExerciseSet` which are child tables of both `workouts` (legacy) and `sessions` (via `sessionUuid`).
- `EditWorkoutScreen` — same treatment.
- `workout_home_controller.dart` + `edit_workout_controller.dart` — update to own a `Session` model; `StrengthSession.exercises` preserves the UI contract.
- `stats_screen.dart` Overview — `WorkoutStats.fromWorkouts` becomes `WorkoutStats.fromSessions` (strength-only filter) or we keep the workout-shape for back-compat during transition.

This is where the real work is. Estimate: 1 focused session for the core screens, maybe half a session to retest thoroughly.

### 2. Remove `WorkoutRepository`

Once all readers/writers are migrated:

- Delete `lib/data/repositories/workout_repository.dart`.
- Delete the `workoutRepositoryProvider` from `database_providers.dart`.
- Update `DataBackupService` constructor — no longer takes `workoutRepository`.
- Update `sync_providers.dart` accordingly.

### 3. Drop the `workouts` table (v5 → v6 migration)

In `app_database.dart`:

```dart
@override
int get schemaVersion => 6;

// Inside onUpgrade:
if (from < 6) {
  await m.drop(workouts);  // or customStatement('DROP TABLE workouts')
  // Also drop the index: idx_workouts_*
}
```

Also drop the `Workouts` class from `tables.dart` and remove it from the `@DriftDatabase(tables: [...])` list. Run build_runner.

`exercises.workout_uuid` and `exercise_feedbacks.exercise_uuid` (which already had `session_uuid` backfilled in v5) become the only FKs; the legacy column can stay for one more version to make the v5→v6 migration reversible, or be dropped in v7.

### 4. Move exercise lookups from `workoutUuid` to `sessionUuid`

Once `workouts` is dropped, every query that reads `exercises.workoutUuid` needs to read `exercises.sessionUuid` instead. The v5 backfill ensures these are equal for all existing rows, so this is a one-liner per DAO method.

### 5. Wire the cardio session template loader

`TemplateRepository` currently loads JSON templates and builds `Workout` + `Exercise` objects. After Phase 6, templates build `StrengthSession` + `CardioSession` (the latter via `CardioSessionLibraryService.instantiate` for any day with a `cardioTemplateId` field).

The JSON schema is already defined (see `assets/templates/README.md`). Two example templates already exist:

- `assets/templates/hybrid_lift_run.json` — 5-day hybrid, cardio days reference library
- `assets/templates/sprint_triathlon_prep.json` — 7-day sprint-tri prep

These load today as strength-only (cardio days are silently skipped). Phase 6 wires up the `cardioTemplateId` resolution so they fully instantiate.

### 6. Optional: unify test fixtures

Any test that constructs `Workout(...)` should prefer `StrengthSession(...)` after the shim is gone. This is mechanical.

## Order of operations

1. Screen-by-screen migration to `SessionRepository` (tests green after each).
2. Delete `WorkoutRepository`.
3. v5 → v6 migration, drop `workouts` table.
4. Wire cardio template loader into `TemplateRepository`.
5. Fold the v6 updates back into `data_structure.md` and `CLAUDE.md`.

## Risks & mitigations

- **Data loss if the migration runs without reading every strength workout first.** Mitigation: the v5 backfill already copied everything into `sessions`. A test run against a real v5 database confirms every workout has a mirror before dropping.
- **Template import breakage.** Mitigation: templates loaded as v3 continue to use the old path until v6 lands. New v6 templates can coexist.
- **Third-party tests that construct `Workout(...)` directly.** Mitigation: the `Workout` class can stay in the model directory as a `@Deprecated` alias → `StrengthSession` until v7.

## What's NOT in Phase 6

- Interval builder UX improvements (nested repeat groups, pace/power targets) → Bucket 2 of the overall roadmap.
- Strava / Garmin integrations → Bucket 3.
- Home-screen redesign / quick-log rework → Bucket 4.

Those are parallel workstreams and don't block Phase 6.
