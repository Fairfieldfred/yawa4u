# Design-first opportunities — planning doc

Three larger UX bets flagged at the end of `UX_REVIEW.md` under "Beyond fixes". Each is design-first because the right answer isn't obvious from the code and because getting it wrong forces a second rewrite. This doc is the design pass — it's meant to be read, argued with, and converged on before any code is written.

Author: Claude, 2026-04-22. Grounded in a read of the post-Phase-6 codebase.

---

## A. Home screen redesign — "today's plan"

### The problem

The Workout tab is still shaped by the strength-only world that predates the multi-sport expansion. You land on it, and it answers one question: "what's my next lifting workout inside the active cycle?" That was fine when strength was the only sport. Post-v5, a user who installs YAWA4U to track runs and occasionally lift gets a screen that can't represent their training — cardio is reachable only via a button in the AppBar.

The reframe worth considering: make the Workout tab a "today" surface that gathers everything the user might act on this morning. Today's planned sessions regardless of sport, yesterday's imported HealthKit activity that hasn't been acknowledged yet, this week's volume at a glance, and a next-step when there's nothing scheduled. The workout viewer stops being the main surface and becomes one card among several — the one you drill into when you tap "start today's strength session."

### Current state

`WorkoutHomeScreen` in `lib/presentation/screens/workout/workout_screen.dart` is 2,258 lines. Its body is a `PageView` over a day sequence computed from the active cycle; each page renders `ExerciseCardWidget`s for that day's strength exercises. States it handles: no current cycle, cycle not started, cycle ended, active cycle with workouts, all workouts complete. Cardio is surfaced only through the AppBar's quick-log button.

The data infrastructure for a "today" view is mostly already there. `sessionsProvider` emits all sessions polymorphically. `thisWeekVolumeProvider` and `thisWeekStrengthCountProvider` aggregate the weekly view. `WeeklySummaryCard` exists, rendered today only on the cycle list screen. There's no `todaysSessionsProvider` yet, but it's a one-liner derived from `sessionsInDateRangeProvider` with today's bounds.

### Options

**A1 — Minimum: add a weekly summary header on top of the existing Workout tab.** Embed `WeeklySummaryCard` above the PageView. User still sees today's strength workout as the primary content; the week summary gives cardio visibility as secondary context. Shipping cost: a day.

**A2 — Middle: stack cards.** Replace the PageView-as-whole-page with a scrollable column of cards: "today's plan" card (the current PageView, compressed), "recent imports" card (HealthKit activity not yet acknowledged), "this week" card (WeeklySummaryCard), and a "create cycle" CTA when there's no active cycle. The day-navigation carousel stays inside the "today's plan" card. Shipping cost: 2-3 focused sessions.

**A3 — Full rethink: today/upcoming/past tabs.** Turn the Workout tab into a three-tab surface. "Today" shows everything scheduled for the current day. "Upcoming" shows the next N days with a calendar-style timeline. "Recent" shows the past week including imports. Each item is a card that drills into its own detail view (strength session, cardio session, or acknowledged-import). Shipping cost: multi-week.

### Recommendation

**A2 (stack cards).** A1 is too small a lever — it improves discoverability but doesn't change the mental model. A3 is attractive in principle but it's a second app inside YAWA4U and the payoff isn't proportional to the risk at this stage. A2 keeps the existing day-navigation affordances that users already know (don't force relearning), while recomposing the Workout tab so cardio, strength, and imports are all first-class.

A2 also lets us incrementally land A3's pieces later. "Today's plan" card can grow a sport-switcher. "Recent imports" card can become the start of a HealthKit acknowledgement flow. "This week" card can link to a fuller weekly view.

### Risks

The PageView's text-field focus behaviour is delicate — the debounce-flush work in Phase 6/Session 1 proves it. Wrapping the PageView in a scrollable parent needs careful keyboard-dismiss and scroll-position handling, otherwise mid-workout taps bounce between the nested scroll and the outer scroll. Worth mocking up on device before committing.

The "recent imports" card depends on HealthKit sync state that the current tree tracks loosely. Might need a provider that flags "unseen" imports explicitly — either a last-acked-timestamp on the user profile or an `acknowledgedAt` column on the session.

### Implementable chunks

1. Add `todaysSessionsProvider` (1 function, re-uses `sessionsInDateRangeProvider`).
2. Move the existing PageView into a widget (`TodayStrengthCard` or similar), no behaviour change.
3. Wrap `WorkoutHomeScreen` in a `CustomScrollView` with slivers for each card; initial pass renders just the strength card so it's a visual no-op.
4. Add the WeeklySummaryCard sliver above the strength card.
5. Add the "recent imports" provider + card — this is where the HealthKit acknowledgement work lives.
6. Empty-state: when there's no active cycle, surface a "create cycle" card and the week summary instead of the current empty view.

---

## B. Persistent quick-log affordance

### The problem

Logging a cardio session today requires being on the Workout tab. If you're looking at Stats, Exercises, the Calendar, or the More menu, you have to navigate back to Workout to log a run. This is minor friction but it's the kind of friction that compounds into "I'll log it later" and then never.

The reframe: make starting a session a first-class action available from every screen, the same way Strava, TrainingPeaks, and Garmin Connect do with a persistent ⊕ button.

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

## Open questions to converge on before any code

1. **Primary icon.** For the quick-log action (B), stick with the current `directions_run`, switch to a generic `add`, or use a sport-aware adaptive icon (strength vs. run based on cycle context)?

2. **Empty cycle.** What should the Workout tab look like when there is no active cycle AND there is no session scheduled today AND there's nothing to acknowledge from HealthKit? Review said "create a cycle" CTA — should it also suggest one-off session logging?

3. **Multi-sport cycle identity.** For the sport distribution ribbon (C), should the segment colors match the sport accent colors (from `Sport.color`) or a dedicated cycle palette? The former is simpler; the latter lets a designer tune specifically for this surface.

4. **HealthKit ack model.** Do imported activities need an explicit acknowledgement step, or do they just appear in the session list as already-logged? This affects A5-6 and the "recent imports" card.

5. **Order of execution.** Does B-then-C-then-A feel right, or does one of these feel more urgent than the others?

---

## Not in scope for this doc

P2 items #11 (contrast tokens), #12 (touch targets), #13 (skeleton loaders), #14 (drag-to-reorder intervals), #15 (app icon clarity), #16 (mobile calendar sport dots), #17 (WeeklySummaryCard additional placements) are mechanical polish and don't need design-first thinking. Pick them off one at a time when you want a fast win.
