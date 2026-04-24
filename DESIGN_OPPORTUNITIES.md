# Design-first opportunities — status tracker

Three larger UX bets flagged at the end of `UX_REVIEW.md` under "Beyond fixes". All three are now **implemented**.

Author: Claude, 2026-04-22. Updated 2026-04-23 with completion status.

---

## A. Home screen redesign — "today's plan" — COMPLETE

**Implemented 2026-04-23.**

The Workout tab is now a unified vertical scroll of session cards (strength + cardio as siblings), with a pinned sport-grid footer for adding sessions.

### What shipped

- **`CardioSessionCard`** widget (`lib/presentation/widgets/cardio/cardio_session_card.dart`) — three state branches: planned, completed user-logged, completed imported. Swim-specific field swap for pool metrics. Shares outer card shape with strength exercise cards.
- **`SportGrid`** widget (`lib/presentation/widgets/cardio/sport_grid.dart`) — pinned footer with 4 sport boxes (Lift, Run, Bike, Swim). Tapping Lift auto-creates a StrengthSession if none exists for the day. Cardio boxes route to `/cardio-session/new?sport=<sport>&planned=true` with cycle/period/day params.
- **`CustomScrollView` rewrite** of `WorkoutHomeScreen` — replaced the `PageView`-based day view with a `CustomScrollView` whose slivers are day navigation chrome, a `SliverList` of interleaved session cards, and a `SliverFillRemaining` footer holding `SportGrid`.
- **`todaysSessionsProvider`** — date-scoped (not cycle-filtered) so imports appear alongside cycle-attached sessions.
- **Card ordering** — performed order (completed first, then in-progress, then planned). Move-up/down affordances retained.
- **Empty-day state** — the 2x2 grid IS the empty state (no separate illustration).
- **Calendar migration** — `calendar_screen.dart` uses `sessionsInDateRangeProvider` so day buckets include imports. `CalendarSportDots` renders colored dots per sport on both desktop and mobile calendars.
- **Exercises screen extension** — `exercises_screen.dart` shows cardio sessions alongside strength exercises in the day view, ordered performed-then-planned.
- **Planned vs logged distinction** — cardio sessions created during draft cycle planning use `SessionSource.userPlanned` and `WorkoutStatus.incomplete`. The card shows a "Log" button. Saving promotes to completed. `CardioSessionScreen` supports a `planned` parameter.

### Files added/modified

| File | Change |
|------|--------|
| `lib/presentation/widgets/cardio/cardio_session_card.dart` | New — full cardio card |
| `lib/presentation/widgets/cardio/sport_grid.dart` | New — 2x2 sport grid |
| `lib/presentation/screens/workout/workout_screen.dart` | Rewritten — CustomScrollView |
| `lib/domain/providers/session_providers.dart` | Added `todaysSessionsProvider` |
| `lib/presentation/screens/calendar/calendar_screen.dart` | Migrated to date-scoped provider |
| `lib/presentation/widgets/calendar/calendar_sport_dots.dart` | Sport dots on mobile calendar |
| `lib/presentation/screens/exercises/exercises_screen.dart` | Cardio sessions in day view |
| `lib/presentation/screens/cardio/cardio_session_screen.dart` | Added `planned` mode |
| `lib/presentation/navigation/app_router.dart` | Parse `planned` query param |

---

## B. Persistent quick-log affordance — COMPLETE

**Implemented 2026-04-23.**

Every top-level tab (except Workout, which has the SportGrid) has a `QuickLogAction` in its AppBar.

### What shipped

- **`QuickLogAction`** widget (`lib/presentation/widgets/cardio/quick_log_action.dart`) — `IconButton` with `add_circle_outline` icon, tooltip "Log session". Opens `SportPickerSheet` with cardio-only choices (strength needs workout context). Routes to `/cardio-session/new?sport=<name>` for an ad-hoc session.
- Added to: `cycle_list_screen.dart`, `stats_screen.dart`, `exercises_screen.dart` (both AppBars), `calendar_screen.dart`.
- "Log cardio session" tile removed from More screen (redundant).

---

## C. Cycle view — sport distribution ribbon — COMPLETE

**Implemented 2026-04-23.**

Cycle list tiles show a proportional sport distribution bar instead of leading with muscle-group badges.

### What shipped

- **`SportDistributionRibbon`** widget (`lib/presentation/widgets/cardio/sport_distribution_ribbon.dart`) — thin horizontal bar with proportional segments colored by `Sport.color`, plus a compact legend ("3 Strength, 2 Run"). Empty maps render `SizedBox.shrink()`. Single-sport case renders a solid bar.
- **`cycleSessionDistributionProvider`** (`lib/domain/providers/session_providers.dart`) — derived from `sessionsByTrainingCycleProvider`, folds sessions into `Map<Sport, int>`.
- **`_SportRibbon`** ConsumerWidget in `cycle_list_screen.dart` — watches the provider and renders the ribbon between the cycle header and info row.
- Muscle-group priority editor remains inside the cycle detail/creator (unchanged).

---

## Remaining polish (not design-first)

These items from the original doc don't need design thinking — they're mechanical improvements.

| Item | Source | Status |
|------|--------|--------|
| Contrast tokens (alpha 0.5 → 0.7) | UX Review P2 #11 | Open |
| Touch targets < 48x48 | UX Review P2 #12 | Open |
| Skeleton loaders | UX Review P2 #13 | Open |
| Drag-to-reorder intervals | P2 #14 | Done (ReorderableListView) |
| App icon picker labels | UX Review P2 #15 | Open |
| Mobile calendar sport dots | P2 #16 | Done |
| WeeklySummaryCard placements | P2 #17 | Done (cycle list + stats) |
| Empty state consolidation | UX Review P1 #9 | Open |
