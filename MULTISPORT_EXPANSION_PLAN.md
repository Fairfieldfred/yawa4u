# YAWA4U Multi-Sport Expansion Plan

Extending YAWA4U from a strength-training app into a full multi-sport training app covering lifting, running, cycling, and swimming — TrainingPeaks-style planning plus Garmin/Strava-style recording.

Author: planning draft for Fred
Date: 2026-04-17
Status: DRAFT — plan only, no code changes yet

---

## 0. TL;DR

- **Data model:** Unified polymorphic "Session" concept. Existing lifting Workouts become one session type alongside Run, Bike, Swim. Planned structure and performed structure share the same tables. Children (exercises/sets vs. intervals vs. recorded samples) hang off the session via typed child tables.
- **Database:** One Drift migration (v4 → v5) that keeps every existing lifting row working. Adds `sessions`, `session_intervals`, `session_samples`, `cardio_routes` tables plus Sport/ActivityType enums. No destructive changes.
- **UX:** Session Type becomes a first-class choice when adding a workout. Each sport gets its own logging surface (interval editor for cardio, existing exercise card for lifting). Calendar, stats, and templates all become sport-aware.
- **Integrations v1:** Apple HealthKit + Android Health Connect, both read + write. **Peloton's real-world path is HealthKit/Health Connect** — Peloton has no public API, but paired Peloton rides/runs flow to Apple Health automatically, so that option already covers your Peloton request.
- **Analytics v1:** Duration, distance, elevation, avg/max HR, pace/speed, HR zones (5-zone model), pace zones (for run), splits, weekly volume by sport. No TSS/CTL/ATL in v1.
- **Timeline:** Five phases, roughly 9–11 weeks of focused work. (Previously six — Watch companion phase is dropped per Fred's decision; not revisiting that based on prior experience.)
- **Coach-mode is on the roadmap but not implemented in v1.** Schema hooks (`creatorUuid` / `ownerUuid` on user-owned rows) ship in v5 so adding multi-user support later is additive, not structural. No coach-mode UI, services, or import/export in this plan.
- **Cardio periodization gets a first-class enum** (`TrainingPhase`: base, build, peak, taper, transition) attached to each Period of a cycle via a new `cycle_periods` table — distinct from the existing `RecoveryPeriodType` (deload/taper/recovery) which stays as-is for strength.
- **Units are per-sport** (run miles + bike km + swim meters is a normal preference). Stored as `Map<Sport, UnitSystem>` in `OnboardingService`; the old global `useMetric` stays as a read-only computed fallback.
- **`daysPerPeriod` defaults are sport-aware** — picking a primary sport on cycle creation prefills 4 (strength) / 5 (run, bike) / 3 (swim) / 7 (mixed). User can still override.
- **Every cycle is mixed-capable.** A "just lifting" cycle is a cycle that happens to contain only strength sessions; there's no dedicated strength-only mode. `primarySport` is a nullable hint that drives defaults, not a restriction — users can drop a run into a strength cycle whenever they want.
- **Risk highlights:** stale in-context models vs. new providers, muscle-group-centric concepts (priorities, soreness) don't map cleanly to cardio, and the data_structure.md doc is already stale (claims schema v2 — actual is v4).

---

## 1. Current State Snapshot

Verified against source (not just the docs, several of which are stale):

- **Schema version: 4** — verified in `lib/data/database/app_database.dart:43`. `data_structure.md` says v2, so that doc needs a refresh as part of this work.
- **Migration pattern:** chained `if (from < X)` inside `onUpgrade`, one column-add per migration step. Very clean — v5 will follow the same shape.
- **Tables today:** `training_cycles`, `workouts`, `exercises`, `exercise_sets`, `exercise_feedbacks`, `custom_exercise_definitions`, `user_measurements`, `skins`. All normalized with UUID-based app identity.
- **Models:** Immutable with `copyWith` and helper mutators (`addExercise`, `updateSet`). Full `toJson`/`fromJson` on every user-facing model.
- **Providers:** Clean chain — `appDatabaseProvider` → DAO providers → repository providers → `StreamProvider` for reactive lists, `Provider.family`/`FutureProvider.family` for parameterized access.
- **Router:** `lib/presentation/navigation/app_router.dart`. All routes are flat (not shell routes). Bottom nav handled inside `HomeScreen`'s `IndexedStack` with 5 tabs: Workout, Training Cycles, Exercises, Calendar, More.
- **Onboarding:** 3 screens collecting profile (height/weight/DEXA/icon), equipment, terminology.
- **Cardio-adjacent things already present:**
  - `Workout.startTime`/`endTime` (added v3) → `duration` getter already exists.
  - `UserMeasurement` (height/weight/body fat/lean mass) — gives a free baseline for cardio resting metrics.
  - `RestTimerWidget` — good UI reference for duration-based controls.
  - **No heart rate, distance, pace, elevation, GPS, or swim fields anywhere.** No HealthKit/Health Connect entitlements.
- **Dependencies:** Drift 2.22, Riverpod 3.0, go_router 17, Firebase Analytics 4.2, Sentry 9.8, fl_chart 1.1, table_calendar 3.2. All modern enough to carry this expansion.

---

## 2. The Data Model Question — Recommended Design

This is the most important decision and it's worth spelling out carefully. You chose the **unified polymorphic** option, so here's what that actually looks like.

### 2.1 Core concept: `Session`

Rename the user-facing idea of "Workout" → "Session". One Session row represents one training action of any kind.

```
Session (new top-level table; replaces role of `workouts` table long-term)
├── sport: Sport (enum: strength, run, bike, swim, other)
├── source: SessionSource (enum: userPlanned, userLogged, healthKit, healthConnect,
│                                  peloton, strava, garmin, imported)
├── planned vs. performed flags (single row holds both, via nullable fields)
├── base fields: scheduledDate, startTime, endTime, status, notes, label, dayName,
│                periodNumber, dayNumber, trainingCycleUuid (FK, nullable),
│                externalId (nullable — e.g. HealthKit UUID), externalSource
└── strength subrow: existing Exercises/ExerciseSets (unchanged semantics) — OR —
    cardio subrow: CardioDetail with distance, elevationGain, elevationLoss,
                   averageHr, maxHr, averageCadence, averagePowerWatts (bike),
                   strokes / swolfScore (swim), pool length (swim),
                   averagePaceSecPerKm (run/swim), averageSpeedKph (bike),
                   and structured intervals via SessionIntervals table.
```

### 2.2 Table layout (v5 schema)

```
sessions                      -- new, replaces user-facing "workout"
├── id (int PK), uuid (unique), trainingCycleUuid (FK nullable)
├── sport (int enum), source (int enum)
├── periodNumber, dayNumber, dayName, label, status
├── scheduledDate, startTime, endTime, notes
├── externalId (text nullable), externalSource (text nullable)
├── creatorUuid (text nullable, default = local user) -- coach-mode hook
├── ownerUuid   (text nullable, default = local user) -- coach-mode hook

cycle_periods                 -- new; 1 row per (trainingCycle, periodNumber)
├── id, uuid, trainingCycleUuid (FK), periodNumber
├── phase (enum: base, build, peak, taper, transition) -- NEW cardio periodization
├── notes (text nullable)                              -- coach comments later live here
├── creatorUuid, ownerUuid (nullable, coach-mode hooks)
   -- Strength-only existing cycles get phase = null + RecoveryPeriodType as today.
   -- Cycles with cardio sessions get a phase per period.

session_cardio                -- 0..1 per session when sport != strength
├── sessionUuid (FK unique), plannedDistanceM, actualDistanceM
├── plannedDurationSec, actualDurationSec
├── elevationGainM, elevationLossM
├── averageHr, maxHr, averageCadence
├── averagePowerWatts, normalizedPowerWatts
├── averageSpeedMps, averagePaceSecPerMeter
├── poolLengthM (swim), strokeType (swim), lapCount, swolf
├── perceivedExertion (1–10), notes

session_intervals             -- structured workout steps (planned + completed)
├── id, uuid, sessionUuid (FK), orderIndex
├── intentType (enum: warmup, work, recovery, cooldown, repeat, rest)
├── targetKind (enum: durationSec, distanceM, hrZone, paceZone, powerZone, freeform)
├── target* fields (nullable; only one populated based on targetKind)
├── actualDurationSec, actualDistanceM, actualAverageHr, actualAveragePace,
│    actualAveragePower
├── repeatCount (nullable; non-null for repeat groups), parentIntervalUuid (tree)

session_samples               -- high-resolution recorded streams (optional)
├── id, sessionUuid (FK), offsetSec, lat, lng, altitudeM, hr, cadence, powerW,
│    speedMps, strokeRate
   -- NOTE: can be heavy. Only persisted when user explicitly imports high-res data.
   -- Default path: store only aggregates in session_cardio, skip samples.

sport_zones                   -- user's configured HR/pace/power zones per sport
├── id, sport (enum), zoneNumber (1..5), minValue, maxValue, unit
├── ownerUuid (text nullable)  -- coach-mode: a coach can author zones for an athlete
├── createdAt
```

### 2.3 What happens to existing tables?

**Pragmatic choice: keep them, don't delete.**

- `training_cycles` gains a nullable `primarySport` column (int enum). Existing rows backfill to `Sport.strength`. This is a UI hint only — never a restriction on what sessions the cycle can contain.
- `workouts` stays in the DB but is migrated: every existing `workouts` row is copied into `sessions` with `sport = strength`. The old `workouts` table is kept read-only as a compatibility shim during phase 3 and removed in phase 5.5.
- `exercises` and `exercise_sets` keep their existing structure — they only apply to strength sessions. They'll gain a new `sessionUuid` FK alongside the existing `workoutUuid`. During migration, both are populated. Once consumers are updated, `workoutUuid` becomes ignored and eventually dropped in a later migration.
- `exercise_feedbacks` similarly gains a `sessionUuid`. The existing feedback (joint pain, pump, workload, soreness) stays strength-only. A new `cardio_feedback` table can carry RPE, GI issues, etc. for running/biking/swimming.

### 2.4 Why this shape and not "one giant table with all fields"

- Keeps strength lifting semantics exactly as-is → zero regressions in the flagship feature.
- Cardio fields (distance/pace/power) are never nullable-padded on strength rows.
- Structured intervals (4 × 800m @ Z4 / 400m recovery) map cleanly to `session_intervals` with a self-join for repeat groups — the same shape your WorkoutTemplate already uses for sets.
- Planned vs. performed live in the same row. That matches your current Workout model (which holds both intent and completion state). It also matches TrainingPeaks' mental model: a session has "planned metrics" and "actual metrics" and a `complete()` transition.

### 2.5 Dart model hierarchy

```dart
abstract class Session { /* base fields + sport + source + status */ }

class StrengthSession extends Session {
  List<Exercise> exercises;  // reuse existing Exercise model
}

class CardioSession extends Session {
  CardioDetail detail;            // aggregates (distance, HR, pace)
  List<SessionInterval> plan;     // structured steps (nullable for ad-hoc)
  List<SessionSample>? samples;   // optional high-res streams
}

sealed class Session { … }  // if we go sealed (Dart 3) — enables exhaustive switch
```

Recommend using **sealed classes** (Dart 3) so that every `switch (session)` in UI code forces handling of all sport types. Catches missed cases at compile time.

---

## 3. Key Architectural Decisions

1. **Rename "Workout" → "Session" user-facing and model-facing, but keep the URL path `/workouts/...` as a redirect for backward compatibility.** The internal `workouts` table name stays during the transition to keep the migration simple; it just gets re-labeled in UI.
2. **Training cycles remain the top-level container.** Every sport goes inside a cycle. This is exactly TrainingPeaks' model: one plan, multiple sport sessions per week.
3. **Every training cycle is mixed-capable.** A cycle can hold any combination of sports — pure strength, pure running, pure cycling, or a triathlon plan with all four. There is no "strength-only mode" and no "cardio-only mode"; a cycle that contains only strength sessions *is* a lifting cycle. `primarySport` on `training_cycles` is a **nullable hint** used only to prefill `daysPerPeriod`, set the initial sport on the cycle-creator screen, and pick a default skin/color — it does not restrict what the user can add. Users can always drop a run into a strength cycle or a lift day into a running block. Existing cycles migrate with `primarySport = strength`.
4. **"Multiple Workouts per day" stays.** Today you have multiple Workout rows per (period, day) keyed by muscle group. Now you'll also have them keyed by sport. The grouping rule becomes: aggregate by `(periodNumber, dayNumber)`, then sub-group by `sport`.
5. **Calendar treats each session as a tile.** Today the calendar shows training days with muscle-group dots. It'll add sport icons (dumbbell / runner / bike / swimmer) as additional dots, and sort strength sessions into a "Strength" header, cardio sessions under individual headers per activity.
6. **Heart-rate + pace zones are per-user, per-sport.** Stored in `sport_zones` table, entered in onboarding (optional) or a new settings screen. Defaults derived from age (Karvonen) if user skips.
7. **Analytics are sport-aware aggregates.** Stats screen becomes a tab-switch: Overview (cross-sport volume), Strength (existing charts unchanged), Run, Bike, Swim.
8. **Imported sessions are read-only by default.** If the user pulled a ride from HealthKit, the samples and aggregates are locked; only notes/RPE/feedback can be edited. Protects against accidental overwrites on next sync.
9. **No Watch companion work in this expansion.** Per Fred's explicit call: the existing `watch_build_plan.md` effort is parked; the phone-side multi-sport work does not touch it and does not depend on it.
10. **Coach-mode schema hooks ship now, coach-mode features ship later.** Every new table that represents user-owned state (`sessions`, `sport_zones`, `cardio_feedback`, `training_cycles` if modified) gets nullable `creatorUuid` and `ownerUuid` columns from day one, defaulting both to the local user. The column pair is free on a single-user DB and means coach-mode can light up without another breaking migration.
11. **Cardio periodization is a first-class Period concept, not a global cycle setting.** A 16-week run plan goes Base → Base → Build → Build → Peak → Taper, period-by-period. Implemented as a new `cycle_periods` table rather than shoving another field into `training_cycles`, because Period is also where coach-mode will eventually hang per-period notes, compliance, and coaching comments.

---

## 4. Phased Roadmap

Five phases, ~9–11 weeks. No watch work. Phase numbering keeps the original "Phase 5" for HealthKit since that phrase already shows up in later sections; the old Phase 6 is now Phase 5.5 (cleanup).

### Phase 1 — Foundation (≈2 weeks)

Goal: data model compiles and migrates cleanly. No user-visible changes yet.

- Add `Sport`, `SessionSource`, `IntervalIntent`, `IntervalTargetKind`, `StrokeType`, **`TrainingPhase`** enums to `lib/core/constants/enums.dart` with `displayName`/`icon`/`color` extensions.
- Add tables: `sessions`, `session_cardio`, `session_intervals`, `session_samples`, `sport_zones`, `cardio_feedback`, **`cycle_periods`**.
- Add `sessionUuid` FK column (nullable) to `exercises` and `exercise_feedbacks`.
- Add `creatorUuid` and `ownerUuid` text columns (nullable, default = local user's UUID) to `training_cycles`, `sessions`, `cycle_periods`, `sport_zones`, `cardio_feedback`. **These are coach-mode hooks — no behavior yet, just future-proofing.**
- Add `primarySport` nullable int column to `training_cycles` (enum-backed — UI hint only, never a restriction).
- Write migration v4 → v5:
  - Create all new tables.
  - For every row in `workouts`, insert a corresponding `sessions` row with `sport = strength` and copy fields over.
  - For every existing `training_cycle`, set `primarySport = Sport.strength` and generate `cycle_periods` rows (one per period, phase = null for now).
  - Backfill `sessionUuid` on all existing `exercises` and `exercise_feedbacks`.
  - Backfill `ownerUuid` / `creatorUuid` on all existing rows to a generated local-user UUID stored in SharedPreferences.
  - Backfill indexes (mirror the existing `beforeOpen` pattern).
- Update mappers in `lib/data/database/mappers/`:
  - Keep existing `WorkoutMapper` alive (it'll read from `sessions` via a view, or from `workouts` with shim).
  - Add `SessionMapper`, `CardioMapper`, `SessionIntervalMapper`.
- Add DAOs: `SessionDao`, `SessionCardioDao`, `SessionIntervalDao`, `SessionSampleDao`, `SportZoneDao`.
- Add type converters for new enums (follow the existing `MuscleGroupConverter` pattern in `converters.dart`).
- Run `dart run build_runner build --delete-conflicting-outputs` and confirm a fresh install + an upgrade from v4 both produce an intact DB.
- **Verification:** run the app on a fresh install → v5. Run on a device with an existing v4 DB → confirm all existing training cycles, workouts, exercises still load correctly and every old Workout has a matching new Session row.

### Phase 2 — Models, repos, providers (≈1.5 weeks)

Goal: Dart API is unified around `Session`. Old code still works through adapters.

- Create `lib/data/models/session.dart` — sealed class with `StrengthSession` and `CardioSession` variants. Each variant has `copyWith`, `toJson`, `fromJson`.
- Keep `workout.dart` as a thin adapter that delegates to `StrengthSession`. Don't delete it; just re-implement. Every existing caller keeps compiling.
- Add `lib/data/models/session_interval.dart`, `cardio_detail.dart`, `sport_zone.dart`, `cardio_feedback.dart`.
- Update `TrainingCycle` model: change `workouts: List<Workout>` → `sessions: List<Session>` plus a backward-compat getter `workouts` that returns strength-only (avoids breaking `Workout.workouts` call sites until they're migrated).
- Repositories:
  - Keep `WorkoutRepository` but re-implement in terms of `SessionRepository`. It becomes a compatibility layer.
  - Add `SessionRepository` with `watchAll()`, `watchByTrainingCycleId()`, `watchBySport(sport)`, `watchByDateRange()`.
  - Add `SportZoneRepository` for zone CRUD.
- Providers: add new provider file `session_providers.dart` mirroring the current `workout_providers.dart`. Keep workout providers alive as forwarding re-exports. New providers:
  - `sessionsByTrainingCycleProvider(cycleId)`
  - `sessionsBySportProvider((cycleId: id, sport: Sport.run))`
  - `cardioSessionsInRangeProvider((start, end))`
  - `sportZonesProvider(sport)`
- Add a small migration guide (CLAUDE.md update) telling future work to use `Session` / `SessionRepository`, with `Workout` flagged `@Deprecated` pointing at `StrengthSession`.
- **Verification:** unit tests for the sealed-class switch exhaustiveness, mapper round-trip tests, repository tests against an in-memory DB (pattern already used in the codebase).

### Phase 3 — Cardio logging UI (≈3 weeks)

Goal: user can plan and log a run/bike/swim from the existing home screen.

- **Cycle creator**: add a "Primary sport" row at the top with 4 chips (Strength / Run / Bike / Swim) plus a "Skip / Mixed" option. This selection only prefills `daysPerPeriod`, sets which sport is pre-selected on the add-session sheet, and defaults the cycle's accent color — it never restricts what sessions can be added. A user who picks "Strength" can still add a run day. Existing cycles with `primarySport = strength` (set by the v5 backfill) behave exactly as today until the user decides to add cardio.
- **Add-session sheet**: replaces today's "add workout" affordance. A 4-way sport chooser at the top defaulting to the cycle's `primarySport` (if any), falling back to the last-used sport for that cycle. Users can freely mix sports inside any cycle.
- New screens under `lib/presentation/screens/cardio/`:
  - `cardio_session_screen.dart` — the "log this session" UI. For completed imports: shows all aggregates read-only plus optional notes. For manual/ad-hoc: a simple form (distance, duration, HR, perceived exertion). For planned structured work: runs the interval editor.
  - `interval_builder_screen.dart` — drag-to-reorder, nest-into-repeat, target picker (duration vs distance vs HR zone vs pace zone). Mirrors the existing exercise-list UI in style.
  - `cardio_summary_card.dart` — reusable widget for calendar, stats, history.
- Sport-specific input widgets under `lib/presentation/widgets/cardio/`:
  - `pace_input.dart` — mm:ss per km / mile toggle honoring `useMetric` from OnboardingService.
  - `distance_input.dart` — km / mi toggle, supports "laps" for pool swims.
  - `hr_zone_badge.dart` — colored chip.
  - `elevation_profile_chart.dart` — fl_chart line series; degrades to flat line when elevation is missing.
- Update `WorkoutListController` / `EditWorkoutScreen` to branch on `session.sport`. Strength → existing UI untouched. Cardio → new cardio screen.
- Calendar: update `DesktopCalendarDayCell` and its mobile counterpart to render sport-specific dots/icons. Legend dialog gains sport entries.
- Router changes: add `/sessions/:sessionId/cardio` and `/sessions/:sessionId/cardio/intervals` routes under the existing training-cycle path. Keep `/workouts/...` aliases for compatibility.
- **Verification:** manual test matrix — plan + log each of {strength, run, bike, swim}, edit, delete, reschedule, mark skipped, view in completed cycle. Watch the calendar reflect changes. Confirm stats screen still loads (even if cardio isn't shown yet).

### Phase 4 — Analytics & stats (≈1.5 weeks)

Goal: Standard cardio analytics alongside existing strength stats.

- Extend `WorkoutStats` (rename to `SessionStats`). Add:
  - Weekly volume per sport (hours + distance).
  - Best efforts (longest run, fastest 5K equivalent pace, heaviest lift — keep existing).
  - HR time-in-zone per sport per week.
  - Pace distribution (run).
  - Avg speed and elevation per ride (bike).
  - Stroke count / SWOLF trend (swim).
- Stats screen: convert single vertical scroll into a horizontal tab switcher: Overview | Strength | Run | Bike | Swim.
- Charts: use fl_chart for everything (already in deps). Add a simple zone-bar widget (stacked horizontal bars colored Z1..Z5). No TSS/CTL — explicitly out of scope for v1.
- Weekly summary widget on home → shows "This week: 3 runs (21 km), 2 lifts (18 sets), 1 swim (1.2 km)".
- **Verification:** seed an in-memory DB with a mix of sessions across 4 weeks and snapshot-test each chart; eyeball with a staging dataset.

### Phase 5 — Integrations: HealthKit / Health Connect / Peloton (≈2–3 weeks)

Goal: autofill from the phone's health store. One-way read in v1, optional write.

**Why this single phase covers Peloton:** Peloton has no official public API. When a user pairs Peloton to Apple Health (iOS) or Google Fit/Health Connect (Android), completed Peloton rides/runs/treads appear there as HKWorkout / ExerciseSession. So a properly-scoped HealthKit/Health Connect integration *is* the Peloton integration. Call this out in the UI: "Connect Peloton via Apple Health / Health Connect".

- Add dependencies: `health: ^11.x` (unified plugin for HealthKit and Health Connect) or roll separate native channels. `health` is lighter-weight for v1; native channels give more control if you need power/cadence streams later. Recommend `health` for v1.
- iOS:
  - Add `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` to `ios/Runner/Info.plist`.
  - Enable HealthKit capability in Xcode and re-sign. `watchOS` target is a separate conversation (phase 6).
- Android:
  - Add Health Connect dependency via the plugin; add `com.google.android.apps.healthdata` provider queries to `AndroidManifest.xml`.
  - Add read permissions for activity type, distance, heart rate, elevation, speed, power (where available), active energy.
- New service: `lib/data/services/health_sync_service.dart`:
  - `Future<void> requestPermissions()` — called from a new Settings screen.
  - `Future<List<ImportedSession>> importSinceLastSync()` — reads workouts from the last sync cursor, maps to `CardioSession` (strength workouts from Health stay out of scope unless user opts in), writes via `SessionRepository`. Deduplicates by `externalId`.
  - `Future<void> writeSession(Session s)` — pushes user-logged sessions back to Health for continuity with the rest of their ecosystem. Optional toggle.
  - Every import stamps `source` (healthKit or healthConnect) and `externalId` (HKWorkout UUID / HC record ID) so re-imports are idempotent.
- UI: new screen `/settings/integrations` with status cards (Health, Peloton-via-Health, future Strava). A manual "Sync now" button plus background sync on app foreground.
- Analytics events: `healthSyncStarted`, `healthSyncCompleted` (with count), `healthSyncFailed` (with error category, no PII).
- **Verification:** test matrix — enable on iOS, ride a Peloton (or mock by manually adding an HKWorkout), open YAWA4U, confirm the ride appears in calendar with correct duration/distance/avg HR. Same test on Android with Health Connect. Disable, re-enable, confirm no duplicates. Offline test — sync while airplane mode → queue → retry.

### Phase 5.5 — Cleanup & polish (≈1 week)

Watch companion explicitly out of scope (Fred's call). `watch_build_plan.md` stays parked; the cardio expansion does not touch it.

- Drop `workouts` table in a v5 → v6 migration now that all code reads from `sessions`. Also drop the compatibility shim in `WorkoutRepository`.
- Update `data_structure.md`, `BUILD_PLAN.md`, and CLAUDE.md to reflect v6 schema, the Session model, `cycle_periods`, and the coach-mode hooks.
- Add a sport filter to the exercise library and a parallel "cardio session library" concept — prebuilt interval workouts (8 × 400m, 2 × 20' threshold bike, CSS swim test, etc.). Ship 10–15 in `assets/cardio_sessions/*.json`.
- Update 3 existing templates to include at least one cardio day. Add 2 new mixed-sport templates (e.g. "Hybrid: 3 lifts + 2 runs", "Sprint tri prep"). Templates now include a per-period `phase` field.
- Update backup JSON version to 4 (was 3) and add sport/cardio/period fields to the export/import round-trip. Test full export → wipe → import.
- Update WiFi sync (`wifi_sync_service.dart`) payload to include new tables.

---

## 5. Enum & Constants Changes (concrete)

In `lib/core/constants/enums.dart`, add:

```dart
enum Sport { strength, run, bike, swim, other }
// displayName, icon (IconData), color, unitSystemDefaults
// isCardio getter → sport != strength

enum SessionSource {
  userPlanned, userLogged,
  healthKit, healthConnect,
  peloton,    // reserved for future direct-API support
  strava, garmin,
  imported,   // generic fallback
}

enum IntervalIntent { warmup, work, recovery, cooldown, rest, repeatGroup }

enum IntervalTargetKind {
  durationSec, distanceM,
  hrZone, paceZone, powerZone,
  freeform,
}

enum StrokeType { freestyle, backstroke, breaststroke, butterfly, mixed, drill }

enum PerceivedExertion {
  veryEasy, easy, moderate, hard, veryHard, allOut,
}
// 1-6 scale; optional — can use int 1-10 instead for RPE

enum TrainingPhase { base, build, peak, taper, transition }
// First-class cardio periodization. Lives on CyclePeriod rows, not on TrainingCycle.
// Strength-only cycles leave phase = null and continue to use RecoveryPeriodType.
// displayName, color (green/yellow/orange/blue/grey), abbreviation ("B","Bu","P","T","Tr")
```

New file `lib/core/constants/sports.dart` mirroring `muscle_groups.dart` / `equipment_types.dart`:

- `SportIcons` map (IconData per sport)
- `SportColors` (add to theme extensions)
- `Sports.parse(String)`

`AppConstants` gains:

- `assetCardioSessionsPath = 'assets/cardio_sessions/'`
- Analytics event names: `eventSportSessionCreated`, `eventCardioSessionCompleted`, `eventHealthSyncCompleted`, `eventIntervalTargetHit`, etc.
- Unit conversion helpers (`kmToMiles`, `msToPace`, etc.) — consider a new `lib/core/utils/cardio_conversions.dart` instead of bloating `AppConstants`.

---

## 6. Dependencies to Add

| Purpose | Package | Notes |
|---|---|---|
| Unified HealthKit + Health Connect | `health` (pub.dev) | Lowest-friction start. Upgrade to native channels later if needed. |
| CSV streaming for cardio libraries | (reuse existing `csv` package) | No change. |
| GPX/TCX parsing (optional, import recorded files) | `gpx` or handwritten XML parser | Only if you later add "Import .fit / .gpx file" feature. Phase 6+. |
| (Optional) FIT file parsing | None mature in Dart yet | Skip in v1. Most people have Health Connect coverage anyway. |

No replacements needed for existing packages.

---

## 7. Screen & Navigation Changes

New screens:

- `lib/presentation/screens/cardio/cardio_session_screen.dart`
- `lib/presentation/screens/cardio/interval_builder_screen.dart`
- `lib/presentation/screens/cardio/sport_picker_sheet.dart`
- `lib/presentation/screens/settings/integrations_screen.dart` (HealthKit / Health Connect connect + sync)
- `lib/presentation/screens/settings/zones_screen.dart` (configure HR/pace zones)

New widgets:

- `presentation/widgets/cardio/` — `pace_input.dart`, `distance_input.dart`, `hr_zone_badge.dart`, `elevation_profile_chart.dart`, `interval_card.dart`, `cardio_summary_card.dart`, `sport_badge.dart`.

Updated screens:

- `home_screen.dart` — weekly summary widget, sport-aware empty states.
- `cycle_list_screen.dart` — show cycle `primarySport` badge and mixed-sport indicator.
- `cycle_create_screen.dart` / `plan_a_cycle_screen.dart` — pick primary sport; allow multi-sport checkbox.
- `edit_workout_screen.dart` — branch on session.sport; rename to `edit_session_screen.dart` during phase 3.
- `calendar_screen.dart` — sport dots/icons, sport filter dropdown, new empty-state copy.
- `stats_screen.dart` — sport tabs as described in phase 4.
- `settings_screen.dart` — add "Integrations" and "Zones" rows.
- `onboarding_equipment_screen.dart` — extend to ask about cardio equipment (treadmill, bike trainer, pool access) — these feed defaults but don't gate anything.

Updated routes in `app_router.dart`:

```dart
static const String sessionCardio = '/trainingCycles/:trainingCycleId/sessions/:sessionId/cardio';
static const String sessionIntervals = '/trainingCycles/:trainingCycleId/sessions/:sessionId/intervals';
static const String integrations = '/settings/integrations';
static const String zones = '/settings/zones';
```

Keep all existing `/workouts/...` routes as aliases → map to the new session screen via a redirect clause. Smooth URL upgrade.

---

## 8. Templates & Asset Library

**Existing `assets/templates/*.json`:** 7 strength-only templates. Format already supports nested JSON but is strength-centric (`muscleGroup`, `equipmentType`, `setType`). Extend the schema:

```json
{
  "id": "triathlon_base_16w",
  "name": "Triathlon Base Builder",
  "description": "16-week aerobic base build for sprint/oly tri",
  "primarySport": "run",
  "periodsTotal": 16,
  "daysPerPeriod": 7,
  "sessions": [                           // renamed from "workouts" — but tolerate both
    {
      "periodNumber": 1, "dayNumber": 1, "sport": "run", "dayName": "Easy run",
      "cardio": {
        "targetDurationSec": 1800,
        "intervals": [
          { "intent": "warmup", "targetKind": "durationSec", "targetDurationSec": 600 },
          { "intent": "work",   "targetKind": "hrZone", "targetHrZone": 2, "targetDurationSec": 1200 },
          { "intent": "cooldown","targetKind": "durationSec", "targetDurationSec": 300 }
        ]
      }
    },
    {
      "periodNumber": 1, "dayNumber": 2, "sport": "strength",
      "exercises": [ /* existing schema */ ]
    }
  ]
}
```

Also add a sibling directory `assets/cardio_sessions/` for single-session reusable workouts (8x400m, CSS test, FTP test, etc.) — these get pulled into the "Add session from library" flow.

**`exercises.csv`:** unchanged. Strength-only.

---

## 9. Onboarding Changes

Keep the 3-screen flow but augment:

- Profile screen: add resting HR and max HR fields (optional). If missing, default `maxHR = 208 - 0.7 * age` (Tanaka formula) once we know age. Age isn't currently collected; add date-of-birth as an optional field.
- Equipment screen: split into "Strength equipment" (existing) and a new "Cardio equipment" section (treadmill, outdoor-only, bike trainer, road bike, TT bike, pool access, open water).
- Terminology screen: no change.
- After onboarding: skip the "generate zones" step if user added max HR; otherwise skip silently and let them configure later in Settings → Zones.

### 9.1 Per-Sport Unit Preferences

Real endurance athletes routinely mix units (run in miles, ride in km, swim in meters). Instead of one global `useMetric`, we let the user set units per sport.

**Storage:** extend `OnboardingService` with a `Map<Sport, UnitSystem>` stored in SharedPreferences as a JSON string. Add:

```dart
enum UnitSystem { imperial, metric }

// OnboardingService additions
UnitSystem unitsFor(Sport sport);          // reads prefs, falls back to sport defaults
Future<void> setUnitsFor(Sport sport, UnitSystem units);

// Sport-aware defaults used if user hasn't set a preference
static const _defaultUnits = {
  Sport.strength: UnitSystem.imperial,   // inherits existing useMetric = false behavior
  Sport.run:      UnitSystem.imperial,   // miles + mm:ss/mi — US default
  Sport.bike:     UnitSystem.metric,     // km + km/h — cycling world default
  Sport.swim:     UnitSystem.metric,     // meters + /100m — universal in swimming
};
```

**UI surfacing:** add a "Units" row to Settings showing a compact list (one row per sport with its current unit). Also expose at the top of Onboarding Profile via a "Customize per sport" disclosure. For backward compatibility, the existing global `useMetric` flag becomes a read-only computed getter (`true` iff all sports are metric) — kept to avoid breaking existing callers like the BMI display.

**Migration:** no DB migration needed. When the app first boots on v5, read the existing `useMetric` pref and write out per-sport preferences derived from it (all-metric or all-imperial), then the user can adjust later.

### 9.2 Per-Sport `daysPerPeriod` Defaults

When the user picks a primary sport on the cycle creation screen, `daysPerPeriod` prefills to a sport-tailored default. They can still override it within the existing `minDaysPerPeriod`/`maxDaysPerPeriod` bounds.

| Primary sport | Default `daysPerPeriod` | Rationale |
|---|---|---|
| Strength | 4 | Matches current behavior — typical hypertrophy split |
| Run | 5 | Most run plans use 5 days (easy/quality/long/recovery/cross) |
| Bike | 5 | Time-crunched cyclists commonly train 5x/wk |
| Swim | 3 | Pool access + recovery dictates a lower baseline |
| Mixed (tri/hybrid) | 7 | Multi-sport = more sessions; some double days |

**Implementation:** a small pure function `defaultDaysPerPeriodForSport(Sport? primary) → int` in `lib/core/utils/session_defaults.dart`. Called by the cycle creation screen when the sport picker changes and the user hasn't manually touched the days field. Zero schema impact — these are UI defaults only.

---

## 10. Analytics (Firebase) Changes

Add to `AnalyticsService` (with constants in `AppConstants`):

- `logSessionCreated(sport, source, isPlanned, hasStructure)`
- `logSessionCompleted(sport, source, durationSec, distanceM?, avgHr?)`
- `logSessionSkipped(sport)`
- `logHealthSyncCompleted(imported, failed)`
- `logHealthSyncFailed(errorCategory)`
- `logZonesConfigured(sport, method: 'manual' | 'fromMaxHr')`
- `logIntervalTargetHit(sport, targetKind, hit: bool)` — for in-session feedback; only if phase-3 scope allows

Deprecate (keep for now, remove in phase 6): muscle-group-specific events if they conflict with cardio. Don't drop any existing event until verified unused.

Continue to never send PII.

---

## 11. Watch Companion — Explicitly Out of Scope

Per Fred's decision, the WatchOS companion work in `watch_build_plan.md` stays parked. The multi-sport expansion makes no changes to the watch Method Channels, the Swift `WorkoutCommunicationManager`, or the `yawa4u Watch App/` target. If the watch companion is ever revived later, the Session / CardioSession / SessionInterval models and the coach-mode `ownerUuid` hook will already be in place, so a future watch expansion becomes a Swift-side contract extension rather than a Dart refactor.

---

## 12. Data Backup & WiFi Sync

- `DataBackupService`: bump `version: 3` → `version: 4`. Add `sessions`, `session_cardio`, `session_intervals`, `sport_zones`, `cycle_periods`, `cardio_feedback`. Back-compat importer: on version 3 import, every workout becomes a strength session, every cycle gets periods with `phase = null`, and `ownerUuid` is set to the local user. Future coach-mode imports will bring their own `ownerUuid` set.
- `WifiSyncService`: include the new tables in the transfer payload. Keep the existing contract structure. Bump a minor compatibility version so old clients refuse to sync with new clients gracefully.

---

## 13. Risks, Gotchas & Unknowns

1. **Stale snapshot trap applies doubly.** `TrainingCycle.workouts` is already a snapshot warning in your docs. Same warning applies to `TrainingCycle.sessions`. Enforce the "always use providers" rule in the new code from day one.
2. **Muscle-group UI assumptions are deeply baked in.** The calendar color-codes by muscle group, exercise library filters by muscle group, cycle priorities are a `Map<MuscleGroup, int>`. Cardio sessions need graceful fallbacks everywhere these are used. Expect to find 20–30 spots that need a `session.sport == strength ? muscleGroup : sportColor(sport)` branch.
3. **Feedback model is strength-centric.** Joint pain / muscle pump / workload / soreness don't map to cardio well. Solution: separate `cardio_feedback` table with RPE, breathing effort, GI issues, weather (optional).
4. **Peloton:** reiterating — no public API. If the user disconnects Peloton from Apple Health, your import goes dark. Surface this clearly on the Integrations screen.
5. **Health Connect on Android is young.** Not every Android device has it installed. Need a graceful fallback: detect `Health Connect not available` and show a "Install Health Connect" nudge. The `health` plugin handles a lot of this but test on multiple Android versions.
6. **`data_structure.md` is stale.** Claims schema v2; actual is v4. Needs to be rewritten as part of Phase 6. Other docs (BUILD_PLAN.md) may be similarly stale — worth auditing.
7. **Riverpod 3.0** — already on the bleeding edge. Double-check `Notifier`/`NotifierProvider` shapes used in new controllers match v3 API, not v2. Not a blocker, just a `flutter pub upgrade` subtlety.
8. **GPS sample storage cost.** A 2-hour bike ride is ~7,200 samples if stored every second. At 8 fields × 32 bytes ≈ 2 MB per ride. Cap samples table size (keep last 50 sessions, or downsample to 1-per-10s for sessions older than 30 days) and expose it as a setting.
9. **Coach-mode schema hooks must go in from day one.** If you skip `creatorUuid`/`ownerUuid` on the v5 migration and add them in v6 when coach mode starts, you're back to a breaking migration — every existing row needs a backfill and every repo call needs auditing. Paying the cost now (a few nullable columns) saves doing it under pressure later.

---

## 14. Open Questions for Fred

All major questions resolved. Scope is locked.

Resolved:
- **Data model:** unified polymorphic (Session) — settled.
- **v1 integrations:** HealthKit + Health Connect (Peloton rides via Apple Health) — settled.
- **Analytics depth:** standard (zones, splits, weekly volume; no TSS/CTL) — settled.
- **Cardio periodization:** first-class `TrainingPhase` enum on `cycle_periods` — settled.
- **Coach-mode:** on the roadmap, **not implemented in v1**. Schema hooks (`creatorUuid`, `ownerUuid`) still ship in v5 so a later implementation is additive. No coach-mode UI, services, or import/export work in this plan. — settled.
- **Watch companion:** out of scope. `watch_build_plan.md` parked — settled.
- **Per-sport units:** yes. Each user picks metric/imperial per sport (so someone can run in miles and ride in km, which is a real endurance-world preference). — settled.
- **Per-sport `daysPerPeriod` defaults:** yes. When the user picks a primary sport on the cycle creation screen, `daysPerPeriod` prefills to a sport-specific default instead of a single global one. — settled.

- **Cycle model:** always mixed-capable. Every cycle can hold any combination of sports; a "just lifting" cycle is simply a cycle that happens to contain only strength sessions. `primarySport` on `training_cycles` is kept as a nullable **hint** (used to prefill `daysPerPeriod` defaults and drive initial UI) rather than a restriction. Users can always add a run to a strength-only cycle, or a lift day to a running block. — settled.

All open questions are resolved. Ready for implementation.

---

## 15. Verification Strategy

For each phase, before marking it done:

- Unit tests for new mappers and model round-trips.
- Repository tests against `AppDatabase.forTesting(NativeDatabase.memory())` — pattern already used.
- Widget smoke tests for each new screen with `ProviderScope(overrides: [...])`.
- Manual test: upgrade an existing production-like DB from v4 → v5 using a snapshot DB file; confirm no data loss.
- End-to-end: plan a mixed-sport cycle, log a strength session, log a run, import a ride from Health, view stats. Run this full flow before shipping to TestFlight / internal track.

Plus the standing rules from your repo:

- `dart run build_runner build --delete-conflicting-outputs` after any table/model change.
- `flutter analyze` must be clean.
- `flutter test` must pass.

---

## 16. Rough Effort Estimate

| Phase | Work | Duration |
|---|---|---|
| 1 | DB schema + migration (incl. `cycle_periods`, coach-mode hooks) | 2w |
| 2 | Models, repos, providers | 1.5w |
| 3 | Cardio logging UI | 3w |
| 4 | Analytics & stats | 1.5w |
| 5 | HealthKit / Health Connect / Peloton | 2–3w |
| 5.5 | Cleanup, templates, docs | 1w |
| **Total** | | **~11–12 weeks** |

Parallelizable: Phase 4 can start mid-Phase 3. Phase 5 can start late-Phase 3 once the Session model is wired end-to-end. Phase 5.5 is sequential.

Watch companion work explicitly excluded.

---

## 17. First Three Commits (concrete starting point)

When you green-light this plan, the very first piece of code to write:

1. **Add enums only.** New file `lib/core/constants/sports.dart` + additions to `enums.dart` (Sport, SessionSource, IntervalIntent, IntervalTargetKind, StrokeType, **TrainingPhase**). Build runner not yet needed. Confirm project compiles. Commit.
2. **Add empty tables + coach-mode columns + `primarySport`.** Stub out `sessions`, `session_cardio`, `session_intervals`, `session_samples`, `sport_zones`, `cardio_feedback`, **`cycle_periods`** in `tables.dart` with bare columns. Add `creatorUuid`/`ownerUuid` nullable text columns to `training_cycles` and each new table. Add `primarySport` nullable int column to `training_cycles`. Bump `schemaVersion` to 5 with a migration that calls `m.createAll()` for the new tables, `m.addColumn()` for the new columns on existing tables, and does no backfill yet. Run build runner, confirm migration runs cleanly against an existing DB. Commit.
3. **Add backfill migration.** In the v5 migration: generate a local-user UUID (stored in SharedPreferences), populate `creatorUuid`/`ownerUuid` on all existing rows, set `primarySport = Sport.strength` on all existing training cycles, copy every `workouts` row into `sessions` (sport = strength), generate `cycle_periods` rows for every existing cycle (phase = null), and backfill `sessionUuid` on `exercises` and `exercise_feedbacks`. Run build runner. Confirm test DB has every old workout represented as a new session, every cycle has periods + primary sport set, and every row has ownership. Commit.

After those three commits, the project is in a healthy state to continue with Phase 2.
