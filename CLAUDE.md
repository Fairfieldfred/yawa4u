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
redirect. The five home tabs (`WorkoutHomeScreen`, `CycleListScreen`, `ExercisesHomeScreen`,
`CalendarScreen`, `MoreScreen`) are `StatefulShellRoute.indexedStack` branches at `/`, `/cycles`,
`/exercises`, `/calendar`, `/more` — each tab is deep-linkable and `context.go('/cycles')` both
selects the tab and dismisses any routes pushed on top (`homeTabIndexProvider` was removed).
The template picker is a route (`/templates`); the template preview and community detail screens
are still pushed imperatively (pageless) but sit above real route pages, so `context.go(...)`
dismisses them.

**Terminology.** "Workout" is the user-facing label; `Session` is the code name — don't rename
either direction. A repeating unit of a cycle is a "Period" (not always 7 days). The user picks
their cycle term (Block/Mesocycle/…) in onboarding — read it via `trainingCycleTermProvider`,
never hardcode "Training Cycle" in UI copy.

**Community & auth (the only cloud subsystem).** Everything else is local-first (Drift/SQLite).
The community library is the exception: `CommunityService` does raw Firestore/Storage I/O against
`community_templates` / `community_skins`, wrapped by `CommunityRepository`. `main.dart` calls
`FirebaseAuthService().ensureSignedIn()` at startup to sign in **anonymously** (browsing/downloading
needs no account); uploading is gated behind `canUploadProvider` → `isEmailVerifiedProvider`, so a
user must link+verify an email first. Downloading a community template saves it locally *and*
creates a draft cycle (see `community_template_detail_screen.dart`).

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
   `WorkoutStatus.incomplete`; the card's "Log" button promotes it to completed. Promoting an
   existing plan asks for confirmation; the cardio form shows an explicit Plan/Log mode indicator.
7. **`ExerciseSet.copyWith(weight: null)` is a no-op.** Like most copyWith implementations,
   null means "keep". To clear a weight pass `clearWeight: true` (`Workout`/`CardioSession`
   have the same pattern via `clearScheduledDate`).
8. **Rest timer is wall-clock driven.** `restTimerProvider` persists an end-timestamp to
   SharedPreferences and re-derives remaining time on every tick/rebuild — never count ticks.
   It schedules an OS notification (`NotificationService`) at the deadline and fires a haptic at
   zero. Tests inject `restTimerClockProvider`, `restTimerHapticProvider`, and
   `notificationServiceProvider` fakes.

## Conventions

- Theme images store **relative** paths (`themes/{id}/workout.jpg`) resolved at runtime by
  `ThemeImageService` — absolute paths break on iOS app updates (container ID changes).
- Enums live in `lib/core/constants/enums.dart` and `lib/core/constants/sports.dart`, with
  `displayName`/`badge`/localized-name extensions. Template JSON (`assets/templates/*.json`) uses
  lowercase enum values.
- Backup format is JSON `version: 4` (multi-sport); `version: 3` imports still accepted. Users
  can export/restore a backup file from the Sync screen (`DataBackupService.exportToFile`).
- Snackbars go through `context.showSnackBar` / `showSuccessSnackBar` / `showErrorSnackBar`
  (`lib/core/extensions/context_extensions.dart`) unless they need a `SnackBarAction` (e.g. Undo) —
  those stay raw `ScaffoldMessenger`. `ContextExtensions` deliberately has NO push/pop helpers;
  navigation is go_router's `context.go`/`context.push` (or `Navigator.of(context)` for dialogs).
- Destructive/movable actions are undoable or confirmed: schedule edits and Reset workout capture
  snapshots (`ScheduleSnapshot`, incl. exercise placements) surfaced as 6s Undo snackbars.
- Text scale is clamped app-wide to 0.8–1.6 in the `MaterialApp` builder; icon-only buttons carry
  `tooltip:` (which doubles as the semantics label).
- Tests override `appDatabaseProvider` with `AppDatabase.forTesting(NativeDatabase.memory())` and
  `sharedPreferencesProvider` with a mock; see `test/helpers/`. Robot journey tests live in
  `test/journeys/` with robots in `test/robots/` and harnesses in `test/harness/`.

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **yawa4u** (325976 symbols, 1479712 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> If any GitNexus tool warns the index is stale, run `npx gitnexus analyze` in terminal first.

## Always Do

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `gitnexus_impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `gitnexus_detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `gitnexus_query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `gitnexus_context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `gitnexus_impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `gitnexus_rename` which understands the call graph.
- NEVER commit changes without running `gitnexus_detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/yawa4u/context` | Codebase overview, check index freshness |
| `gitnexus://repo/yawa4u/clusters` | All functional areas |
| `gitnexus://repo/yawa4u/processes` | All execution flows |
| `gitnexus://repo/yawa4u/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
