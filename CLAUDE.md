# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Project: YAWA4U

Local-first, multi-sport (strength / run / bike / swim) training tracker. Flutter + Drift (SQLite),
Riverpod ^3 for state, go_router for navigation, Firebase for anonymous analytics, Sentry for errors.
Targets iOS, Android, macOS, Web, Windows, Linux.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # REQUIRED after editing Drift tables/DAOs or @JsonSerializable classes
flutter gen-l10n                                            # REQUIRED after editing lib/l10n/*.arb
flutter analyze                                             # must be clean before committing
flutter test                                                # all tests
flutter test test/data/repositories/session_repository_test.dart          # single file
flutter test --plain-name "creates cycle from template"                   # single test by name
bash tool/coverage.sh                                       # coverage + filtered HTML report (needs lcov)
./scripts/run.sh                                            # flutter run with SENTRY_DSN from .env
flutter run -d macos|ios|chrome                             # run on a specific platform
```

Formatter uses `page_width: 120`, `trailing_commas: preserve` (see `analysis_options.yaml`).

## Detailed reference docs (read when relevant)

- `.claude/rules/DATA_STRUCTURE_v6.md` — canonical schema, models, all providers, common pitfalls
- `.claude/rules/TERMINOLOGY.md` — Workout vs Session naming convention
- `.claude/rules/LOCALIZATION.md` — adding a language (ARB + exercise-name JSON, two surfaces)
- `.claude/rules/SETUP.md` — Firebase / Sentry configuration

## Architecture (big picture)

**Layers & provider chain.** `lib/core` → `lib/data` (database/tables → daos → mappers, models,
repositories, services) → `lib/domain` (providers, controllers) → `lib/presentation` (navigation,
screens, widgets). Data flows: `appDatabaseProvider → {dao}Provider → {repository}Provider →
domain StreamProvider → UI`. Repositories own all reads/writes and load full hierarchies
(session → exercises → sets); DAOs are used directly only for hot-path debounced writes
(e.g. weight/reps entry on the workout screen).

**Sealed Session model (schema v6).** Every training action is a row in `sessions`, surfaced as
sealed `Session` → `StrengthSession` (has `exercises`) or `CardioSession` (has `detail` +
`intervals`; `samples` opt-in). `switch (session)` is exhaustiveness-checked — adding a variant
means updating every switch site. The legacy `workouts` table was dropped in v6:
`WorkoutRepository` is now a **facade** over `SessionRepository`, translating the legacy `Workout`
shape ↔ `StrengthSession` for pre-v6 UI call sites. New code uses `SessionRepository` directly.
`CardioFeedback` is NOT a field on `CardioSession` — load via `cardioFeedbackProvider(sessionId)`.

**Navigation.** GoRouter (`lib/presentation/navigation/app_router.dart`) with an onboarding
redirect. Critical gotcha: the five home tabs (`WorkoutHomeScreen`, `CycleListScreen`,
`ExercisesHomeScreen`, `CalendarScreen`, `MoreScreen`) are an `IndexedStack` inside `HomeScreen`
at route `/` — they are **not routes**. To land on a tab: set `homeTabIndexProvider` then
`context.go('/')`. Several screens (template picker/preview, community detail) are pushed
imperatively with `Navigator.push`, so they sit as pageless routes on top of the current GoRoute
page — if you're already on `/`, `context.go('/')` will NOT dismiss them; `popUntil((r) =>
r.isFirst)` first.

**Terminology.** "Workout" is the user-facing label; `Session` is the code name — don't rename
either direction. A repeating unit of a cycle is a "Period" (not always 7 days). The user picks
their cycle term (Block/Mesocycle/…) in onboarding — read it via `trainingCycleTermProvider`,
never hardcode "Training Cycle" in UI copy.

## Domain pitfalls (top sources of bugs)

1. **Workout ≠ training day.** Multiple `Workout`/`StrengthSession` rows exist per day (one per
   muscle group), sharing `(periodNumber, dayNumber)` — always aggregate by that pair for display.
   All period/day fields are 1-indexed.
2. **Stale snapshots.** `TrainingCycle.workouts` is populated at creation time. Always read
   current state through providers (`workoutsByTrainingCycleProvider(cycleId)` etc.).
3. **Stacked cycles.** Multiple cycles can be active simultaneously; the calendar renders all of
   them. Schedule edits must loop over `currentTrainingCyclesProvider` (plural) and shift by
   **calendar date** (`ScheduleService.insertDayBeforeDate` / `removeRestDay`), not period/day —
   each cycle maps the same date to different coordinates. Using the singular
   `currentTrainingCycleProvider` only shifts the primary cycle.
4. **Exercise names are identity keys.** Built-in names from `exercises.csv` are stored in English
   in the DB and used to match history/PRs/videos. Never translate stored names or the CSV —
   translation happens at display time only via `context.localizedExerciseName(name)`.
5. **External sessions are read-only.** `SessionSource.isExternal` (healthKit, strava, …) —
   schedule shifts and edits must skip them.
6. **Planned vs logged cardio.** Draft-planning creates `SessionSource.userPlanned` +
   `WorkoutStatus.incomplete`; the card's "Log" button promotes it to completed.

## Conventions

- Theme images store **relative** paths (`themes/{id}/workout.jpg`) resolved at runtime by
  `ThemeImageService` — absolute paths break on iOS app updates (container ID changes).
- Enums live in `lib/core/constants/enums.dart` and `lib/core/constants/sports.dart`, with
  `displayName`/`badge`/localized-name extensions. Template JSON (`assets/templates/*.json`) uses
  lowercase enum values.
- Backup format is JSON `version: 4` (multi-sport); `version: 3` imports still accepted.
- Tests override `appDatabaseProvider` with `AppDatabase.forTesting(NativeDatabase.memory())` and
  `sharedPreferencesProvider` with a mock; see `test/helpers/`.
