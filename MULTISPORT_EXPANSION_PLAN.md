# YAWA4U Multi-Sport Expansion — Completion Record

Extending YAWA4U from a strength-training app into a full multi-sport training app covering lifting, running, cycling, and swimming.

Original plan: 2026-04-17. All phases completed by 2026-04-23.

**Status: COMPLETE** — all phases implemented, schema at v6, `workouts` table dropped.

---

## Architecture summary

### Data model

Unified polymorphic `Session` (sealed class) with `StrengthSession` and `CardioSession` variants. Exhaustive `switch` at compile time. Every training action — strength or cardio, planned or performed, user-logged or imported — is a row in `sessions`.

```
Session (sealed)
├── StrengthSession → exercises → exercise_sets, exercise_feedbacks
└── CardioSession   → session_cardio (1:1), session_intervals, session_samples (opt-in)
                    └── cardio_feedback (loaded separately via repository)
```

### Key decisions (locked)

1. **"Workout" = user-facing, "Session" = code-level.** See `TERMINOLOGY.md`.
2. **Every cycle is mixed-capable.** `primarySport` is a nullable hint, not a restriction.
3. **`WorkoutRepository` is a facade** over `SessionRepository` (v6). New code uses `SessionRepository` directly.
4. **Per-sport units** — run in miles, bike in km, swim in meters. Stored as `Map<Sport, UnitSystem>` in `OnboardingService`.
5. **Coach-mode schema hooks** (`creatorUuid`/`ownerUuid`) shipped in v5. No coach-mode features yet — additive when ready.
6. **Cardio periodization** — `TrainingPhase` enum (base/build/peak/taper/transition) on `CyclePeriod`, distinct from strength's `RecoveryPeriodType`.
7. **Watch companion** — out of scope (`watch_build_plan.md` parked).

---

## Phases completed

### Phase 1 — Foundation

Schema v4 → v5 migration. Created tables: `sessions`, `session_cardio`, `session_intervals`, `session_samples`, `sport_zones`, `cardio_feedback`, `cycle_periods`. Added `primarySport`, `creatorUuid`, `ownerUuid` to `training_cycles`. Backfilled every `workouts` row into `sessions` with `sport = strength`. Added `sessionUuid` FK to `exercises` and `exercise_feedbacks`.

### Phase 2 — Models, repos, providers

Sealed `Session` class with `StrengthSession`/`CardioSession`. `SessionRepository` as canonical source of truth. `WorkoutRepository` reimplemented as facade. Provider layer: `sessionsProvider`, `sessionsByTrainingCycleProvider`, `sessionsBySportProvider`, `cardioSessionsProvider`, `sessionsInDateRangeProvider`, `todaysSessionsProvider`, `cycleSessionDistributionProvider`.

### Phase 3 — Cardio logging UI

Screens: `cardio_session_screen.dart`, `interval_builder_screen.dart`, `sport_picker_sheet.dart`, `cardio_template_picker.dart`. Widgets: `cardio_session_card.dart`, `sport_grid.dart`, `sport_badge.dart`, `sport_distribution_ribbon.dart`, `weekly_summary_card.dart`, `quick_log_action.dart`, `distance_input.dart`, `duration_input.dart`, `hr_input.dart`. Cycle creator gained primary sport picker with sport-aware `daysPerPeriod` defaults. Calendar migrated to `sessionsInDateRangeProvider` with `CalendarSportDots`. Exercises screen extended to show cardio sessions alongside strength exercises.

### Phase 4 — Analytics & stats

Stats screen gained Cardio tab alongside Overview. `CardioStats` model with `fromSessions()` factory. Providers: `cardioStatsProvider`, `cardioStatsForCycleProvider`, `cardioStatsBySportProvider`, `recentCardioWeeksProvider`, `thisWeekVolumeProvider`, `thisWeekStrengthCountProvider`. Cycle selector lifted above TabBar so all tabs respect it.

### Phase 5 — Integrations

HealthKit + Health Connect via `health` package (v13.1.4). `HealthSyncService` with `requestPermissions()`, `importSinceLastSync()`, dedup by `externalId`. Strava OAuth via `flutter_web_auth_2` + `StravaIntegrationService`. Integrations screen at `/settings/integrations`. Zones screen at `/settings/zones` for HR/pace/power zones per sport.

### Phase 5.5 → v6 — Cleanup

Dropped `workouts` table (v5 → v6 migration). `WorkoutRepository` became a facade — no direct DB access. `CardioSessionLibraryService` loads cardio templates from assets. Backup format at version 4 (multi-sport, excludes samples). Templates support mixed-sport cycles with `primarySport` and `cardioTemplateId`.

### Onboarding

4-screen flow: Profile → Sports → Equipment → Terminology. `onboarding_sports_screen.dart` asks "Which sports do you train?" with multi-select. Per-sport unit preferences seeded from selection. Sport-aware `daysPerPeriod` defaults via `defaultDaysPerPeriodForSport()` in `session_defaults.dart`.

### UX polish (post-Phase 6)

Home screen redesigned: `CustomScrollView` with interleaved strength/cardio cards + pinned `SportGrid` footer. `QuickLogAction` added to all non-Workout tabs. `SportDistributionRibbon` on cycle list tiles. Planned vs logged cardio sessions distinguished via `SessionSource.userPlanned` / `WorkoutStatus.incomplete`. See `DESIGN_OPPORTUNITIES.md` and `UX_REVIEW.md` for details.

---

## Enums (as implemented)

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

### In `core/constants/enums.dart`

| Enum | Values |
|---|---|
| `TrainingPhase` | base, build, peak, taper, transition |

`SessionSource` has `.isExternal` extension: `true` for all except `userPlanned` and `userLogged`.

---

## Files added during expansion

### Screens (`lib/presentation/screens/`)

| File | Purpose |
|---|---|
| `cardio/cardio_session_screen.dart` | Log/plan/edit a cardio session |
| `cardio/interval_builder_screen.dart` | Build structured intervals |
| `cardio/sport_picker_sheet.dart` | Modal sport chooser |
| `cardio/cardio_template_picker.dart` | Pick from cardio session library |
| `settings/integrations_screen.dart` | HealthKit / Strava connect |
| `settings/zones_screen.dart` | HR/pace/power zone configuration |
| `onboarding/onboarding_sports_screen.dart` | Sport preference during onboarding |

### Widgets (`lib/presentation/widgets/cardio/`)

| File | Purpose |
|---|---|
| `cardio_session_card.dart` | Session card for workout scroll |
| `sport_grid.dart` | 2x2 quick-add grid |
| `sport_badge.dart` | Compact sport indicator pill |
| `sport_distribution_ribbon.dart` | Proportional sport bar on cycle tiles |
| `weekly_summary_card.dart` | Cross-sport weekly totals |
| `quick_log_action.dart` | AppBar action for non-Workout tabs |
| `distance_input.dart` | Distance entry with unit toggle |
| `duration_input.dart` | Duration picker |
| `hr_input.dart` | Heart rate entry |

### Data layer

| File | Purpose |
|---|---|
| `data/models/session.dart` | Sealed Session class |
| `data/models/cardio_detail.dart` | Cardio aggregate metrics |
| `data/models/session_interval.dart` | Structured interval model |
| `data/models/session_sample.dart` | Time-series sample model |
| `data/models/cardio_feedback.dart` | Post-cardio feedback |
| `data/models/cycle_period.dart` | Period metadata |
| `data/models/sport_zone.dart` | Training zones |
| `data/models/cardio_stats.dart` | Cardio analytics model |
| `data/repositories/session_repository.dart` | Canonical session CRUD |
| `data/repositories/cycle_period_repository.dart` | Period metadata |
| `data/repositories/sport_zone_repository.dart` | Zone CRUD |
| `data/repositories/cardio_feedback_repository.dart` | Feedback CRUD |
| `data/services/health_sync_service.dart` | HealthKit / Health Connect |
| `data/services/strava_integration_service.dart` | Strava OAuth + sync |
| `data/services/cardio_session_library_service.dart` | Template catalog |
| `data/database/daos/session_dao.dart` | Session DAO |
| `data/database/daos/session_cardio_dao.dart` | Cardio detail DAO |
| `data/database/daos/session_interval_dao.dart` | Interval DAO |
| `data/database/daos/session_sample_dao.dart` | Sample DAO |
| `data/database/daos/cardio_feedback_dao.dart` | Feedback DAO |
| `data/database/daos/cycle_period_dao.dart` | Period DAO |
| `data/database/daos/sport_zone_dao.dart` | Zone DAO |
| `data/database/mappers/session_mappers.dart` | DB ↔ model conversion |
| `domain/providers/session_providers.dart` | Session provider layer |
| `core/constants/sports.dart` | Sport enum + extensions |
| `core/utils/session_defaults.dart` | Sport-aware defaults |

---

## Risks resolved

1. **Stale snapshot trap** — enforced via providers everywhere. `TrainingCycle.workouts` / `.sessions` documented as snapshots.
2. **Muscle-group assumptions** — cardio cards branch on `sport` instead of `muscleGroup`. Calendar uses sport colors for cardio dots.
3. **Feedback model** — separate `cardio_feedback` table (RPE, breathing, GI, weather) distinct from strength's joint pain / pump / workload.
4. **Peloton** — covered via HealthKit bridge. Documented on integrations screen.
5. **Health Connect availability** — `health` plugin handles graceful fallback.
6. **GPS sample storage** — samples opt-in only (`includeSamples: true`). Not loaded by default.
7. **Coach-mode hooks** — `creatorUuid`/`ownerUuid` on all rows. No migration needed when coach features ship.

---

## Reference docs

| Doc | Purpose |
|---|---|
| `DATA_STRUCTURE_v5.md` | Current v6 schema, models, providers |
| `TERMINOLOGY.md` | Naming conventions (Workout vs Session, Period vs Week) |
| `DESIGN_OPPORTUNITIES.md` | UX redesign completion record (Sections A/B/C) |
| `UX_REVIEW.md` | UX review with completion status per item |
| `.claude/rules/data_structure.md` | CLAUDE.md-embedded data reference (needs sync with v6) |
