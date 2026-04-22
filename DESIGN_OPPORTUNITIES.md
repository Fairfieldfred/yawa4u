# Design-first opportunities — planning doc

Three larger UX bets flagged at the end of `UX_REVIEW.md` under "Beyond fixes". Each is design-first because the right answer isn't obvious from the code and because getting it wrong forces a second rewrite. This doc is the design pass — it's meant to be read, argued with, and converged on before any code is written.

Author: Claude, 2026-04-22. Grounded in a read of the post-Phase-6 codebase.

---

## A. Home screen redesign — "today's plan"

**Status:** decisions locked in 2026-04-23 based on Fred's direction. Approach is a single unified vertical scroll of session cards (strength + cardio as siblings), with a pinned sport-grid footer for adding sessions. No "stack of distinct cards" (earlier A2 proposal), no weekly-summary inline (deferred to its own placement later). Cardio cards mirror the visual rhythm of existing strength exercise cards.

### The problem

The Workout tab is still shaped by the strength-only world that predates the multi-sport expansion. You land on it, and it answers one question: "what's my next lifting workout inside the active cycle?" That was fine when strength was the only sport. Post-v5, a user who installs YAWA4U to track runs and occasionally lift gets a screen that can't represent their training — cardio is reachable only via a button in the AppBar.

The reframe: make the Workout tab a "today" surface where every session the user might act on — strength or cardio, planned or completed, user-logged or imported — is a sibling card in one vertical scroll. Below the scroll, a pinned 2×2 grid of sport boxes makes adding a new session a single tap.

### Current state

`WorkoutHomeScreen` in `lib/presentation/screens/workout/workout_screen.dart` is 2,258 lines. Its body is a `PageView` over a day sequence computed from the active cycle; each page renders `ExerciseCardWidget`s for that day's strength exercises. Cardio is surfaced only through the AppBar's quick-log button.

The data infrastructure is in place. `sessionsByTrainingCycleProvider(cycleId)` emits all sessions polymorphically; `sessionsInDateRangeProvider` scopes by date. `ExerciseCardWidget` exists; a `CardioSessionCardWidget` does not yet. `SportPickerSheet` exists as a modal; an inline grid widget does not.

### Locked-in design

**Card list.** Today's sessions render as a vertical scroll of cards. Each `StrengthSession`'s exercises render as the current `ExerciseCardWidget`, one card per exercise. Each `CardioSession` renders as a new `CardioSessionCard` with matching outer shape (rounded-12 radius, same padding, same shadow) so the scroll reads as siblings. Cardio card internals diverge because the data diverges — see below.

**Card order.** Sorted by performed order (completed-first using `completedDate`, then in-progress, then planned by `scheduledDate`/creation order). Users can reorder via the existing move-up / move-down affordances that strength already exposes; drag-to-reorder is the P2 #14 item from the UX review and extends naturally to cardio cards when it lands.

**Sport grid.** Pinned at the bottom of the scroll as a floating footer with a "ADD SESSION" header strip and four icon-labelled boxes: Lift, Run, Bike, Swim. Tapping:

- **Lift** → existing Add Exercise flow (`AddExerciseScreen`). If the current training day has no `StrengthSession` yet, the grid creates one before navigating so the exercise has a parent to attach to.
- **Run / Bike / Swim** → `/cardio-session/new?sport=<sport>` with current `trainingCycleId`, `periodNumber`, `dayNumber` pre-filled.

**Empty day.** When the current day has zero sessions, the 2×2 grid becomes the full screen content (bigger tap targets, centered), replacing the empty-state illustration that's there now. Adding a session converts the day to populated state and the grid returns to its pinned footer form.

### Card structure

Same outer card (rounded-12, 16px padding, shadow-2) across types. Same header slot (icon tag + title + ⋮ menu). Same two-slot footer (primary action left, secondary action right). Internals vary.

**Strength exercise card** (existing, for reference):

```
┌──────────────────────────────────────────────┐
│ 💪 Chest · Bench Press                 ⋮    │
├──────────────────────────────────────────────┤
│ Set 1   225 lb × 8      ✓ logged            │
│ Set 2   225 lb × 8      ✓ logged            │
│ Set 3   225 lb × 6      ○                   │
│ [+ Add set]                                 │
├──────────────────────────────────────────────┤
│ 📝 Notes        😊 Feedback                  │
└──────────────────────────────────────────────┘
```

**Cardio card — planned / not yet done:**

```
┌──────────────────────────────────────────────┐
│ 🏃 Run · Tempo run                     ⋮    │
├──────────────────────────────────────────────┤
│ TARGET                                       │
│ 5.0 km · 30 min · Zone 3                    │
│                                              │
│ ⏱ 4 intervals                          ▼    │
├──────────────────────────────────────────────┤
│ [ Log session ]             📝 Notes         │
└──────────────────────────────────────────────┘
```

Fields shown: sport icon + session label, target line (distance / duration / zone target if any), interval count with expand chevron. Primary button: "Log session" (opens `/cardio-session/:id` in edit mode with plan fields pre-filled).

**Cardio card — completed, imported (Strava / Apple Health):**

```
┌──────────────────────────────────────────────┐
│ 🏃 Run · Morning loop                  ⋮    │
│   🟠 Strava                                  │
├──────────────────────────────────────────────┤
│ 5.2 km       31:14       6:00 /km           │
│ ▲ 45 m       avg 155 bpm     max 172        │
├──────────────────────────────────────────────┤
│ ✓ Completed              [ Add feedback ]    │
└──────────────────────────────────────────────┘
```

Fields: sport icon + activity name, source badge (tucked under title for imports only), hero metrics row (distance / duration / pace or speed), secondary metrics row (elevation / HR). Primary: status, secondary: feedback.

**Cardio card — swim variant:**

```
┌──────────────────────────────────────────────┐
│ 🏊 Swim · Technique day                ⋮    │
├──────────────────────────────────────────────┤
│ 1,200 m · 30 laps                25 m pool  │
│ 28:30        SWOLF 32        Freestyle      │
├──────────────────────────────────────────────┤
│ ✓ Completed              [ Add feedback ]    │
└──────────────────────────────────────────────┘
```

Swim substitutes pool-specific fields (`poolLengthM`, `lapCount`, `swolf`, `strokeType`) for the run/bike pace/elevation fields.

**Sport grid (pinned footer or empty-day full content):**

```
┌──────────────────────────────────────────────┐
│ ADD SESSION                                  │
├──────────────────────────────────────────────┤
│  ┌──────────┐    ┌──────────┐               │
│  │    🏋️    │    │    🏃    │               │
│  │   Lift   │    │   Run    │               │
│  └──────────┘    └──────────┘               │
│  ┌──────────┐    ┌──────────┐               │
│  │    🚴    │    │    🏊    │               │
│  │   Bike   │    │   Swim   │               │
│  └──────────┘    └──────────┘               │
└──────────────────────────────────────────────┘
```

2×2 grid, each box ≥ 88×88px for comfortable tap targets. In empty-day mode, scales up to fill available space below the AppBar.

### Risks

PageView text-field focus behaviour is delicate — the debounce-flush work in Phase 6/Session 1 proves it. Replacing the PageView with a `CustomScrollView` + slivers needs careful keyboard-dismiss and scroll-position handling, otherwise mid-workout taps bounce between nested scrolls. Worth mocking up on device before committing.

The pinned sport-grid footer competes with the iOS keyboard for screen space. When a text field (weight / reps / cardio actual) is focused, the grid should hide behind the keyboard rather than push content up. `Scaffold.resizeToAvoidBottomInset: false` on the Workout tab plus an explicit `MediaQuery.viewInsets` check in the grid widget handles this.

Cardio card heights vary by data availability — a bare user-logged session has less to show than a Strava import with HR + power + elevation. Constrain visual height via a 3-line-max body; overflow metrics go behind the ⋮ menu "Details" item.

### Implementable chunks

1. Add `todaysSessionsProvider` — derived from `sessionsInDateRangeProvider(todayStart, todayEnd)`, **no cycle filter** so imports are included.
2. Build `CardioSessionCard` widget with three state branches (planned / completed user-logged / completed imported) and the swim-specific field swap.
3. Build `SportGrid` widget — stateless 2×2 with callback for each box; handles the "Lift" branch's auto-create-StrengthSession-if-missing logic by reading/writing through `SessionRepository`.
4. Replace the `PageView`-based day view with a `CustomScrollView` whose slivers are: the existing day navigation chrome, a `SliverList` of session cards (strength + cardio interleaved by performed order), and a pinned `SliverFillRemaining` footer holding `SportGrid`.
5. Empty-day state: swap in `SportGrid` as the whole body instead of the current empty illustration.
6. Wire the grid's "Lift" box to ensure a `StrengthSession` exists for the current `(cycleId, period, day)` before pushing to `AddExerciseScreen`; the cardio branches push to `/cardio-session/new?sport=...` with period/day params.
7. **Calendar screen** — migrate `calendar_screen.dart` from its cycle-scoped provider to `sessionsInDateRangeProvider` so the day buckets include imports.
8. **Calendar sport dots** — `calendar_sport_dots.dart` reads the same date-scoped provider so the per-day colored indicators reflect imported sessions alongside cycle-attached ones.
9. **Exercises home screen day view** — extend `_WorkoutSessionView` in `exercises_screen.dart` to accept cardio sessions for the day alongside strength workouts. The inner PageView builds its page list as `[...strengthExercises, ...cardioSessionsForDay]`, ordered performed-then-planned. Cardio pages render a full-page `CardioSessionCard` variant (same fields as the compact card from chunk 2, but scaled up to fill the page — room for a larger metrics hero and optional future additions like HR-over-time charts from `SessionSample` data). Date-filter the sessions so imports appear here too.

---

## B. Persistent quick-log affordance

**Status:** scoped down 2026-04-23. The Workout tab's quick-log is now handled by the pinned sport grid from Section A — no AppBar ⊕ needed there. B applies only to the *other* top-level tabs (Stats, Cycle list, Exercises, Calendar) where the grid isn't visible.

### The problem

Logging a cardio session from anywhere outside the Workout tab still requires navigating back to Workout first. If the user is looking at Stats or reviewing the Calendar and decides to log a just-finished run, the friction of switching tabs to find the grid compounds into "I'll log it later."

The reframe: put the quick-log action in every top-level tab's AppBar so starting a session is never more than one tap away. Strava, TrainingPeaks, and Garmin Connect all ship some variant of this.

### Current state

The Log Cardio IconButton lives in `WorkoutHomeScreen`'s AppBar (workout_screen.dart:1241-1262). It opens `SportPickerSheet.show()` (cardio sports only) and routes to `/cardio-session/new` with the visible period/day attached. Other AppBars across the app are sparse — `cycle_list_screen.dart` has "New cycle," `stats_screen.dart` has a TabBar, `exercises_screen.dart` has just a title. No screen uses a FloatingActionButton today.

There's no app-global scaffold pattern. Snackbars and dialogs are resolved per-context. The shared sport picker works via a static helper on `SportPickerSheet`.

### Options

**B1 — Consistent AppBar action.** Add a ⊕ IconButton to every top-level tab's AppBar. Factor the handler into a single function (something like `logSessionFromAnywhere(context, {Sport? preset})`) that opens the picker and routes. Small, predictable, matches current app style.

**B2 — Persistent FAB.** Add a FloatingActionButton on every top-level tab. Bigger, more discoverable, more modern. Downside: YAWA4U currently has no FABs, so this is a new pattern; and FABs can obscure content in list-heavy views.

**B3 — Adaptive surface.** Desktop layout gets a ⊕ button in the NavigationRail leading slot. Mobile layout gets a ⊕ in the BottomNavigationBar as a center-highlighted tab (the "+" pattern used by Strava). Two implementations but each feels native to its form factor.

### Recommendation

**B1 (consistent AppBar action)**, with the caveat that the "⊕" should actually be `directions_run` or similar — the review said "⊕" as shorthand but a sport-specific icon reads better than a generic plus. The existing button on the Workout tab stays; the same button shows up on Stats, Exercises, Calendar, and the cycle list with identical behaviour. More tab stays as-is (the More menu's "Log cardio session" tile keeps working as a fallback).

B2 is tempting but would fight the existing app style and be the only FAB in the tree. B3 is over-engineered for a single button.

The shared handler should live in a new file — `lib/presentation/widgets/cardio/quick_log_action.dart` — as either a helper function that takes a `BuildContext` or a small widget `QuickLogAction()` that each screen drops into its `actions:` list. Widget-form is slightly more Flutter-idiomatic and lets the callback logic stay encapsulated.

### Risks

Low. The sport picker is already shared, the routing is already stable. The one thing to watch: if a screen has a route-specific param the Workout tab relies on (currently: trainingCycleId, period, day get attached to the created session), other screens won't have those, so the default route must handle the bare `/cardio-session/new?sport=run` case and not crash. The Cardio session screen does handle this today — no cycle attached means an ad-hoc session.

### Implementable chunks

1. Extract the existing quick-log handler from `workout_screen.dart` into `QuickLogAction` widget (or helper function).
2. Drop it into `cycle_list_screen.dart`'s AppBar actions.
3. Drop it into `stats_screen.dart`'s AppBar actions.
4. Drop it into `exercises_screen.dart`'s AppBar actions.
5. Drop it into `calendar_screen.dart`'s AppBar actions (if it has one; may need to add).
6. Check if route params need adapting (probably not — the Workout tab's cycle/period/day attachment is a nice-to-have, not a requirement).

---

## C. Cycle view — sport distribution vs. muscle-group priority

### The problem

The cycle list today leans hard on muscle-group language: each cycle shows a row of muscle-group badges drawn from `TrainingCycle.muscleGroupPriorities`. For a pure strength cycle this is genuinely useful — you can see at a glance that it's a chest-and-triceps focus. For a triathlon cycle it's wrong: muscle groups are not what the user thinks about, and the badges are going to be empty or nonsensical. Even for a mixed-sport cycle (2 lifts + 4 runs per week), muscle-group priority is not the right framing.

The reframe: a cycle's visual identity should communicate its character, and "character" means different things for different cycles. "Character" of a strength cycle is which muscle groups get emphasis. "Character" of a cardio cycle is the sport mix and total volume. "Character" of a mixed cycle is both, in proportion.

### Current state

`TrainingCycle.muscleGroupPriorities` is a `Map<String, int>?` on the model. `primarySport` is a `Sport?` that acts as a UI hint — prefills days-per-period and drives the default sport on the add-session sheet, but deliberately does not restrict what sessions a cycle can contain. Every cycle is mixed-capable.

`_buildTrainingCycleCard()` in `cycle_list_screen.dart` renders a cycle tile. It shows the cycle name, status badge, total session count, completion ratio, and (per the reading) a muscle-group badge row derived from `muscleGroupPriorities`.

There's no pre-computed sport distribution per cycle, but the data is trivially available. `sessionsByTrainingCycleProvider(cycleId)` emits every session. A simple `.fold` or `.where` by `session.sport` gives `Map<Sport, int>`. The pattern already exists in `CardioStats.fromSessions` which builds a `perSport: Map<Sport, SportAggregate>` the same way.

### Options

**C1 — Replace muscle badges with sport distribution.** Every cycle tile shows a sport-distribution ribbon: "6 lifts • 4 runs • 2 bikes" or small icons with counts. Drop the muscle-group row entirely from the list view. Muscle-group priority stays editable inside the cycle detail screen (where it still makes sense for strength-heavy cycles).

**C2 — Adaptive: show whichever is dominant.** If a cycle is >80% strength by session count, show muscle badges (current behaviour). If it has any meaningful cardio (>20% cardio sessions), switch to sport distribution. Threshold-based; requires a decision rule and some nuance for edge cases.

**C3 — Both, always.** Two rows on every tile — sport distribution on top, muscle-group priority below, each compact enough to fit. Users get more information per tile but tiles get denser.

### Recommendation

**C1 (replace with sport distribution).** The muscle-group badges on the list view are low-signal for most cycles — they exist because strength was the only sport, not because they're the most useful summary. Sport distribution is a better universal answer. The muscle-group priority system doesn't disappear — it stays inside the cycle detail and the cycle creator for users who want strength-specific planning. The list view just stops leading with it.

C2 is attractive but introduces a rule the user has to discover ("why do some tiles show muscles and others don't?"). C3 is fair but dense.

Visually, the sport distribution could render as a thin horizontal bar with proportional segments colored by sport, plus a small legend — less information-dense than bullet counts but more scannable. This matches how Strava shows weekly sport distribution on its feed.

### Risks

Users who built strength-only cycles will see a visual change. Worth making sure the sport-distribution ribbon handles "100% strength, 0 other" gracefully — probably as a single solid bar in strength-color rather than a segmented bar. Test this case first.

`muscleGroupPriorities` as a field has no great story post-redesign. Keep it populated because the cycle creator still writes it, but deprecate it on the list view. Later passes can decide whether to remove it entirely or keep it inside the cycle detail as a strength-specific feature.

### Implementable chunks

1. Add `cycleSessionDistribution(cycleId)` provider — returns `Map<Sport, int>` folded from the cycle's sessions.
2. Build `SportDistributionRibbon` widget — takes a `Map<Sport, int>` and a total, renders proportional segments.
3. Swap the muscle-group row in `_buildTrainingCycleCard` for `SportDistributionRibbon`.
4. Handle the "strength-only" edge case visually (solid bar not segmented).
5. Keep the muscle-group priority editor inside the cycle detail / creator (no change there).

---

## Cross-cutting considerations

The three opportunities share one latent question: **how much does YAWA4U want to lean into being a multi-sport app, visually?** A is the biggest bet on "yes." B is tactical reinforcement of the same bet. C is the tile-level statement of it. Committing to all three says loudly: strength is one of our sports, not the sport. Doing A alone without B or C will produce an inconsistent surface — today's plan is multi-sport but logging and cycle tiles are still strength-flavored.

Worth knowing which design direction feels right before building any of them. A reasonable sequencing if you do commit: **B first (cheapest, immediate user win), then C (visual identity), then A (the biggest restructure)**. B and C together reshape perception; A then delivers the payoff when the user lands on the Workout tab and it finally feels like one app for all their training.

## All decisions locked in (final pass 2026-04-23)

### Section A — Home screen redesign

- **Workout tab shape** — unified card scroll, not stacked distinct cards.
- **Card rhythm** — strength and cardio cards share outer shape / header slot / footer slot. See card structure sketches above.
- **Sport grid visibility** — pinned footer when the day has content; whole-body 2×2 when the day is empty.
- **Card ordering** — performed order (completed first, then in-progress, then planned), with existing move-up/down affordances retained.
- **Weightlift grid box** — auto-creates a `StrengthSession` for the current day if one doesn't exist, then pushes to `AddExerciseScreen`.
- **Empty-cycle day** — the 2×2 grid IS the empty-state. No separate "no sessions" illustration; the grid itself communicates "tap to start something."
- **HealthKit / Strava imports** — land as `WorkoutStatus.completed` and render as regular cardio cards with a source badge under the title. No separate acknowledgement UI. The "recent imports" sliver from the earlier A2 proposal is retired — imports flow directly into the today-card scroll.
- **Imports across every date-anchored view** — imports are `trainingCycleId: null` ad-hoc sessions, so any screen that currently filters by cycle misses them. All date-anchored views must switch to a date-filter (via `sessionsInDateRangeProvider`), not a cycle-filter, so imports appear wherever a cycle-attached session would for that date:
  - **Calendar screen** — day buckets + per-day detail read by date.
  - **Calendar sport dots** — the little sport-color indicators on each calendar day include imported sessions.
  - **Workout home screen** — `todaysSessionsProvider` is defined against the date range, not the cycle; cycle-attached and ad-hoc sessions interleave.
  - **Exercises home screen (`ExercisesHomeScreen`)** — the existing two-level swipe (outer day PageView, inner exercise PageView) extends so the inner PageView treats "unit for this day" as either a strength exercise OR a cardio session. Swiping left-right moves through strength exercises, then cardio sessions (imports + cycle-attached), ordered performed-then-planned. Cardio sessions render a full-page version of the `CardioSessionCard` with the same hero / sub-metrics / feedback treatment defined for Section A. Strength-exercise-level "previous performance" history stays strength-only because imports don't carry exercises.

### Section B — Persistent quick-log

- **Scope** — applies only to Stats, Cycle list, Exercises, Calendar. The Workout tab is handled by the sport grid.
- **Icon** — generic `add_circle_outline` with tooltip "Log session". Sport picker sheet disambiguates on tap. `directions_run` on the Workout tab AppBar stays as-is for continuity.

### Section C — Sport distribution ribbon

- **Colors** — reuse `Sport.color`. Shared color vocabulary with session cards, stats charts, and calendar dots keeps the user's mental model compressed: one hue per sport, used everywhere.

### Execution order

**A → C → B.**

Rationale: A is the biggest-leverage change and is now fully designed. Doing A first transforms what the user sees every day and reshapes B's value (the Workout tab's sport grid reduces the need for a quick-log button there). C carries the multi-sport identity through to the Training Cycles tile list, reinforcing what A just established. B closes the loop with discoverability on secondary surfaces.

Rough effort:
- **A:** 3–4 focused sessions. New `todaysSessionsProvider`, `CardioSessionCard` widget, `SportGrid` widget, `CustomScrollView` rewrite of `WorkoutHomeScreen`, empty-state swap, Lift-box auto-create logic.
- **C:** ~1 focused session. `cycleSessionDistribution` provider, `SportDistributionRibbon` widget, `_buildTrainingCycleCard` swap, strength-only edge case.
- **B:** ~half a session. Extract `QuickLogAction` widget, drop into 4 AppBars.

---

## Not in scope for this doc

P2 items #11 (contrast tokens), #12 (touch targets), #13 (skeleton loaders), #14 (drag-to-reorder intervals), #15 (app icon clarity), #16 (mobile calendar sport dots), #17 (WeeklySummaryCard additional placements) are mechanical polish and don't need design-first thinking. Pick them off one at a time when you want a fast win.
