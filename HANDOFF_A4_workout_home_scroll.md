# Handoff Spec — A4: WorkoutHomeScreen sliver scroll

> Chunk 4 of Section A in `DESIGN_OPPORTUNITIES.md`. Replaces the `PageView`-based day view in `WorkoutHomeScreen` with a `CustomScrollView` whose slivers are: (a) day-navigation chrome, (b) a `SliverList` of session cards (strength + cardio interleaved by performed order), (c) a pinned footer holding `SportGrid`.

**Status: shipped 2026-04-22.** Built end-to-end on the day this spec was written. Verified on iOS device; Android build was unblocked by an unrelated Gradle signing-config fix (see post-ship notes). One follow-up landed on top: the `SportGrid` is now filtered by the user's onboarding sport selection. See **Post-ship notes** at the bottom for what diverged from this spec and what was added later.

Author: Claude, 2026-04-22.

---

## Overview

The Workout tab is currently a `PageView` over a sequence of training days computed from the active cycle. Each page renders the day's strength `ExerciseCardWidget`s; cardio sessions and Strava/Health imports are not visible there. Chunks 1–3 of Section A are already merged: `todaysSessionsProvider`, `CardioSessionCard`, and `SportGrid` exist and are unit-tested. Chunk 4 is the integration: rebuild `WorkoutHomeScreen`'s body so today's sessions — strength exercises **and** cardio sessions, planned and completed, cycle-attached and ad-hoc — render as a single vertical scroll, with `SportGrid` pinned beneath the scroll (or filling the screen on an empty day).

This is the largest chunk in Section A and the riskiest — it touches the most-used screen in the app and replaces a delicate keyboard/debounce surface. Read the **Risks & required preservations** section before writing code.

---

## Current state (read this first)

- `lib/presentation/screens/workout/workout_screen.dart` — 2,258 lines.
- PageView lives at lines 1297–1316; its `itemBuilder` calls `_buildDayPageContent(...)`.
- The PageView's `onPageChanged` does two things you must preserve in any replacement: `FocusScope.of(context).unfocus()` (dismisses the iOS keyboard) and `_selectDay(pos.period, pos.day)` (drives day-navigation state).
- The State class holds: a `PageController`, per-field `_debounceTimers` (300 ms coalescing for weight/reps writes — **set-edit changes are not flushed by the provider tree, they go directly through `ExerciseSetDao.updateByUuid`**), `_localWeights` / `_localReps` overrides, and `_setDaoForDispose` captured in `initState` so `dispose()` can flush in-flight edits without `ref.read` (which is unsafe in `dispose`).
- The AppBar (1241–1290) currently includes `Icons.directions_run` for quick-log cardio, `Icons.calendar_today` for the period selector, theme toggle, and a 3-dot menu that appears only when `todaysWorkouts.isNotEmpty`.
- Stack-overlay decorations in the body: `CalendarDropdown` (period selector), and a "FINISH WORKOUT" bottom button when every set on the day is logged but the workouts aren't yet marked complete.

---

## Layout

The day body becomes:

```
┌──────────────────────────────────────────────┐
│ AppBar (unchanged — see "AppBar" below)      │
├──────────────────────────────────────────────┤
│ CustomScrollView                             │
│  ┌──────────────────────────────────────┐    │
│  │ SliverPersistentHeader (pinned: false)│   │  ← day navigation chrome
│  │   Period • Day N — "Push"            │    │     (existing widget reused)
│  │   ◀ prev day      next day ▶         │    │
│  └──────────────────────────────────────┘    │
│  ┌──────────────────────────────────────┐    │
│  │ SliverList                           │    │  ← interleaved session cards
│  │   ExerciseCardWidget(...)            │    │
│  │   ExerciseCardWidget(...)            │    │
│  │   CardioSessionCard(...)             │    │
│  │   ExerciseCardWidget(...)            │    │
│  │   …                                  │    │
│  └──────────────────────────────────────┘    │
│  ┌──────────────────────────────────────┐    │
│  │ (16px breathing room)                │    │
│  └──────────────────────────────────────┘    │
├──────────────────────────────────────────────┤
│ SportGrid — pinned footer (compact variant)  │  ← outside CustomScrollView
├──────────────────────────────────────────────┤
│ FINISH WORKOUT button (conditional)          │  ← below SportGrid
└──────────────────────────────────────────────┘
```

**SportGrid is pinned outside the scroll**, not as a sliver, so the cards can scroll behind/under it without affecting its position. Implement it as `Column { Expanded(CustomScrollView), SportGrid(variant: compact), if (showFinishButton) FinishWorkoutButton }` inside the existing `Stack` body. The `Stack` continues to host the `CalendarDropdown` overlay. The `FINISH WORKOUT` button moves out of the `Stack` (where it was a `Positioned(bottom: 0, …)` child) and becomes the bottom slot of the `Column` instead — it sits **below** the SportGrid so the grid is never visually obscured by it.

**Empty-day mode:** when the day has zero sessions (after dedupe + import inclusion), replace the `Expanded(CustomScrollView)` child with `SportGrid(variant: expanded)` filling the full body. The grid becomes the empty state — no separate illustration. The day-navigation chrome remains visible above it (the user can still swipe to a different day's view) but the chrome may be smaller and the grid centered in remaining space.

---

## Data sources

| Source | Purpose | Where it comes from |
|---|---|---|
| `sessionsInDateRangeProvider(todayStart, todayEnd)` | Today's sessions (strength + cardio, including ad-hoc imports) | Already exists |
| `todaysSessionsProvider` (chunk 1) | Convenience wrapper around the date-range provider for today | `lib/domain/providers/session_providers.dart` lines 91–97 |
| `currentTrainingCycleProvider` | Active cycle for cycle-attached writes (Lift box) | Existing |
| `_homeState.displayPeriod`, `_homeState.displayDay` | Currently-viewed (period, day) — drives the day navigation chrome | `WorkoutHomeController` |

**Important — date filter, not cycle filter.** `todaysSessionsProvider` is intentionally not cycle-scoped. Imports land as `trainingCycleId: null`; filtering by cycle drops them. The Workout tab now answers "what should I do today?", not "what's next in this cycle?".

When the user navigates to a non-today day via the calendar, switch the data source to `sessionsInDateRangeProvider(dayStart, dayEnd)` for that day. `todaysSessionsProvider` is the special-case sugar; the underlying provider parameterizes on date.

---

## Components

| Component | Variant | Where to use it | Notes |
|---|---|---|---|
| `ExerciseCardWidget` | existing | One per `Exercise` inside any `StrengthSession` for the day | Pass through the existing `ExerciseCardCallbacks` exactly as the current `_buildDayPageContent` does. Don't fork the callbacks — reuse them. |
| `CardioSessionCard` | planned / completed-userLogged / completed-imported / swim | One per `CardioSession` for the day | Internal state branches off `session.status` and `session.source`; the widget already handles this. |
| `SportGrid` | `compact` (footer) / `expanded` (empty day) | Below the card list, or filling the body | `SportGridCallbacks { onLift, onRun, onBike, onSwim }`. **Lift** must auto-create a `StrengthSession` for the current `(cycleId, period, day)` if one doesn't exist before pushing `AddExerciseScreen`. |
| `CalendarDropdown` | existing | Overlay for period/day selection | Unchanged. Continues to live in the `Stack`. |
| `RestTimerWidget` | existing | Whatever overlay it's in today | Verify its z-index after the rewrite. |

### Card ordering

Sort the day's sessions before flattening into the list. Spec'd order:

1. **Completed** sessions, ordered by `completedDate` ascending (so the user reads top-to-bottom in the order they finished things).
2. **In-progress** sessions, ordered by earliest `startTime`.
3. **Planned** sessions, ordered by `scheduledDate` then creation order (`createdDate`/UUID order is fine if `scheduledDate` is null).

A `StrengthSession` is "in-progress" if any `Exercise.sets` has `isLogged: true` AND the session is not `completed`. A `CardioSession` is "in-progress" if `startTime != null && completedDate == null`.

After sorting at the **session** level, flatten:

- `StrengthSession` → its `exercises` (in `orderIndex` order) → one `ExerciseCardWidget` per exercise.
- `CardioSession` → one `CardioSessionCard`.

So a day with `[StrengthSession{3 exercises}, CardioSession]` produces a 4-card scroll.

There is no existing helper for this ordering. Add one as `lib/core/utils/session_order.dart`:

```dart
List<Session> sortByPerformedOrder(Iterable<Session> sessions) { … }
```

Pure function, easily unit-tested. Cover the three buckets and the all-empty / all-completed edge cases.

---

## States and interactions

| Element | State | Behaviour |
|---|---|---|
| Day-navigation chrome | Default | Shows current period • day • day name (e.g. "Period 2 · Day 3 — Push"). Prev/next chevrons. Tapping the date opens `CalendarDropdown` overlay (existing pattern). |
| Day-navigation chrome | Today | Subtle "Today" pill next to the day label so users know their current view. |
| Card list | Default | Scrolls vertically. Each card retains its existing internal interactions. |
| Card list | Loading | Display 2 skeleton cards (rounded-12, same dimensions, shimmer). The `todaysSessionsProvider` returns a `Stream`; show skeletons during the initial load (`AsyncValue.loading`). |
| Card list | Empty | Body becomes `SportGrid(variant: expanded)` (see Empty-day mode above). |
| `SportGrid` (compact) | Default | Pinned at bottom, ~120 px tall, sits above the home indicator. Casts a small upward shadow to separate from scroll content. |
| `SportGrid` (compact) | Keyboard visible | **Hides behind the keyboard**, does not push the scroll up. Set `Scaffold.resizeToAvoidBottomInset: false` on this screen and let the keyboard cover the grid. (See "Risks" — this is the iOS keyboard-collision issue from the design doc.) |
| `SportGrid.onLift` | Tap | If a `StrengthSession` exists for `(currentCycleId, displayPeriod, displayDay)`, push `AddExerciseScreen` for it. Otherwise, create one via `SessionRepository.createStrength(StrengthSession(...))` first, then push. |
| `SportGrid.onRun` / `onBike` / `onSwim` | Tap | `context.push('/cardio-session/new?sport=<sport>&trainingCycleId=<id>&period=<p>&day=<d>')`. If no current cycle, drop the cycle/period/day params — the cardio screen handles ad-hoc sessions. |
| Day swipe (deferred) | — | The horizontal-swipe-between-days gesture from the old PageView is not part of chunk 4. The day-navigation chrome's chevrons cover this functionality. If users miss the swipe, add a horizontal `Dismissible` or `GestureDetector` later — but it's not required to ship A4. |
| "FINISH WORKOUT" pinned button | Visible when every strength set is logged but no session is marked complete | Existing logic at lines 1343–end. Renders **below** the SportGrid as the final slot of the bottom `Column`. Same conditional visibility as today (`todaysWorkouts.isNotEmpty && !todaysWorkouts.every((w) => w.isCompleted) && todaysWorkouts.every((w) => _isWorkoutComplete(w))`). When hidden, the SportGrid sits at the screen bottom; when visible, the SportGrid lifts to make room for it. |

---

## AppBar (unchanged behaviour, minor cleanup)

The AppBar can be simplified now that the SportGrid handles "add a session":

| Action | Keep? | Notes |
|---|---|---|
| `directions_run` quick-log | **Remove** from this tab. The grid replaces it. (This is per the locked-in design — Section B explicitly de-scopes the Workout tab from getting a `QuickLogAction`.) |
| `calendar_today` period selector | **Keep** | Continues to drive `_togglePeriodSelector()`. |
| Theme toggle | **Keep** | No change. |
| 3-dot workout options (`Icons.more_vert`) | **Keep** | Show condition becomes `todaysSessions.any((s) => s is StrengthSession)` instead of `todaysWorkouts.isNotEmpty` so the menu still scopes to strength-only actions. |

Title and subtitle (period • day labels) remain in the AppBar's title slot or move into the day-navigation chrome — recommend keeping them in the AppBar to avoid duplication.

---

## Responsive behaviour

| Breakpoint | Changes |
|---|---|
| Mobile (default) | Single-column scroll, full-width cards with 16 px horizontal margin. SportGrid as 2×2 compact footer. |
| Tablet (≥ 600 px width) | Cards constrained to `maxWidth: 560` and centered. SportGrid stays 2×2 compact footer with the same constraint. |
| Desktop (≥ 1024 px, future) | Out of scope for A4. Note for later: SportGrid compact variant could become a 4×1 horizontal strip on wide layouts. |

---

## Edge cases

- **Empty day** — full-body `SportGrid(variant: expanded)`. No "no sessions" illustration.
- **Cycle not started yet (no current training cycle)** — `currentTrainingCycleProvider` returns null. Render the SportGrid as the body (same as empty day). The Lift box's auto-create path needs to also handle "no cycle" — fallback to creating an ad-hoc `StrengthSession` with `trainingCycleId: null`. Confirm `SessionRepository.createStrength` accepts a null cycle id; if not, this is a minor repo change, not a chunk-4 blocker.
- **Today is a rest day** — `daysPerPeriod` may not match calendar days. The chrome shows the next training day; sessions list still date-filtered. Imports from a rest day should still appear (a Strava ride on a rest day is a real session that happened today).
- **Mid-keystroke navigation** — user types into a weight field, then taps a SportGrid box. The `dispose()` flush logic must continue to work; the `_setDaoForDispose` capture pattern stays exactly as is.
- **Provider refresh during scroll** — `todaysSessionsProvider` is a Stream. Drift emits on every set update. Use `AsyncValue.previous` or `cachePrevious()` so the list doesn't flicker on every keystroke. The current `_cachedWorkouts` pattern can be retired if `AsyncValue.previous` proves stable, but keep it as a fallback if you see flicker.
- **Strength session with zero exercises** — currently happens when the Lift box auto-creates a session before navigating. Render a placeholder card "Tap + to add your first exercise" pointing back to `AddExerciseScreen`, OR don't render the empty session at all and rely on the SportGrid Lift box being the user's path back in. Recommend **don't render** — the empty-session card is noise.
- **Imported session with sparse data** — `CardioSessionCard` already constrains visual height to 3 lines max; overflow goes behind the ⋮ menu's "Details" item.

---

## Animation / motion

| Element | Trigger | Animation | Duration | Easing |
|---|---|---|---|---|
| Card list → empty state | Day becomes empty (last session deleted) | Cross-fade | 200 ms | `Curves.easeOut` |
| SportGrid compact ↔ expanded | Day flips between empty and populated | Implicit `AnimatedSwitcher` | 250 ms | `Curves.easeInOut` |
| New session appears | Card inserted at top of list | `AnimatedList` slide-in from top | 300 ms | `Curves.easeOutCubic` |
| Day-navigation chrome | Period/day changes | Cross-fade label | 150 ms | `Curves.linear` |

`AnimatedList` is optional polish — ship without it if it complicates the keyboard work.

---

## Risks & required preservations

These are the things that will break if you're not careful. Read all of them before starting.

### 1. Debounced set-edit flush in `dispose()`

Lines 82–121 of `workout_screen.dart`. The current State flushes pending weight/reps writes through a captured DAO reference because `ref.read` is unsafe in `dispose`. **This must survive the rewrite verbatim.** If you collapse the State class, keep the `_setDaoForDispose` capture and the per-key flush loop. Losing this regresses UX-review P0 #2.

### 2. Keyboard handling

The PageView calls `FocusScope.of(context).unfocus()` on every page change to dismiss the iOS keyboard. The replacement scroll has no equivalent natural dismiss event. Two options:

- **A.** `GestureDetector` wrapping the `CustomScrollView` with `onTap: () => FocusScope.of(context).unfocus()` and `behavior: HitTestBehavior.translucent`. Simple, but interferes with card taps.
- **B.** `NotificationListener<UserScrollNotification>` that calls `unfocus()` when scroll direction changes. Doesn't interfere with taps but may dismiss too aggressively.

Recommend **B** with a `direction == ScrollDirection.forward || direction == ScrollDirection.reverse` filter so it only fires on meaningful scrolls, not the rest position.

### 3. Keyboard ↔ SportGrid collision

iOS keyboard rises ~300 px. Without `Scaffold.resizeToAvoidBottomInset: false`, the keyboard pushes the scroll up and the SportGrid floats awkwardly mid-screen. Set `resizeToAvoidBottomInset: false` on this screen specifically (not the whole app) and let the keyboard **cover** the SportGrid (and the FINISH WORKOUT button if it's visible). The grid stays where it was; user dismisses the keyboard to see it again. This is the locked-in behaviour — do not push the grid up.

### 4. Provider flicker during typing

Each weight/reps keystroke debounces a 300 ms write. When the write lands, Drift emits, `todaysSessionsProvider` recomputes, the `SliverList` rebuilds. The `ExerciseCardWidget` already uses `_localWeights` / `_localReps` overrides so the field doesn't fight the user, but the surrounding `Card` rebuilds and may flash. Mitigate with `AsyncValue.previous` so the list keeps the previous value during loading transitions.

### 5. PageController disposal

The current `dispose()` calls `_pageController?.dispose()` (line 119). After removing the PageView, drop the field too — leaving an unused `PageController` allocated leaks memory and reads as dead code.

### 6. The "FINISH WORKOUT" pinned button

Currently positioned at `bottom: 0` of the Stack. Move it out of the Stack and into the bottom `Column` as the slot **below** the SportGrid (locked-in decision). The visibility conditional and styling stay the same; only the parent changes from `Positioned` to a plain `Column` child rendered conditionally. The keyboard covers both the SportGrid and the FINISH WORKOUT button when raised — same `resizeToAvoidBottomInset: false` handles both.

---

## Implementation steps

Suggested order — each step independently shippable to a branch:

1. **Add `sortByPerformedOrder` helper** in `lib/core/utils/session_order.dart`. Unit-test the three buckets and the empty cases.
2. **Build `_TodayBody` widget** (a private `ConsumerWidget` inside `workout_screen.dart` or a separate file under `lib/presentation/screens/workout/`). Takes `(period, day)` + the day's sessions, returns the `CustomScrollView`. Renders skeleton during `AsyncValue.loading`, expanded `SportGrid` when empty, sliver list otherwise.
3. **Wire `_TodayBody` behind a feature flag** — keep the PageView reachable behind a debug toggle so you can side-by-side test on device before deleting the old code path.
4. **Replace `_buildDayPageContent` invocation** in the body Stack with `Column { Expanded(_TodayBody), SportGrid(compact) }`.
5. **Remove the PageView, `_pageController`, `_isSwiping`, `_lastSyncedPageIndex`** — but keep the debounce flush logic. Run the test suite; the existing PageView-focused tests will need updates.
6. **Strip the `Icons.directions_run` quick-log button** from the AppBar.
7. **Smoke test on device:** swap days via calendar, type into weight fields, navigate away mid-keystroke, log a Strava session and confirm it appears, hit empty-day state, exercise the Lift box's auto-create path.
8. **Delete the feature flag** once confidence is high.

---

## Acceptance criteria

- [x] Today's strength sessions and cardio sessions render as siblings in a single vertical scroll, ordered: completed → in-progress → planned.
- [x] Strava / Health Connect imports appear on the day they happened (not just cycle days). _Imports show only on the today-equivalent cycle day to avoid leaking onto unrelated training days; see post-ship note 1._
- [x] An empty day shows `SportGrid(variant: expanded)` filling the body — no separate empty illustration.
- [x] A populated day shows `SportGrid(variant: compact)` pinned at the bottom; cards scroll behind/above it.
- [x] iOS keyboard does not push the SportGrid up; it covers it.
- [x] Mid-keystroke navigation (type into weight, tap SportGrid box) flushes the in-flight value to the DB. _The `_setDaoForDispose` capture + per-key flush loop is preserved verbatim from pre-rewrite._
- [x] Swiping the card list does not eat taps on cards; tapping a SportGrid box does not eat scroll.
- [x] Lift box auto-creates a `StrengthSession` for `(cycleId, period, day)` if one doesn't exist, then pushes `AddExerciseScreen`.
- [x] Run/Bike/Swim boxes push `/cardio-session/new` with cycle/period/day params.
- [x] No `PageController`, `_pageController`, `_isSwiping`, or `_lastSyncedPageIndex` references remain.
- [x] Existing debounce-flush behaviour in `dispose()` is preserved exactly.
- [x] `sortByPerformedOrder` covered by 7 unit tests (`test/core/utils/session_order_test.dart`); all pass. Pre-existing widget tests still pass. _No new widget tests for `_buildSessionScroll` branches — see post-ship note 5._

---

## Out of scope for this chunk

- **Drag-to-reorder cards** — UX-review P2 #14, separate work.
- **Swipe-between-days gesture** — replace later if users ask.
- **Day chrome aesthetics overhaul** — this chunk reuses whatever's there; visual refresh is a separate pass.
- **Section B `QuickLogAction`** — explicitly de-scoped from the Workout tab.
- **Section C sport-distribution ribbon on cycle tiles** — different screen.

---

## Post-ship notes (2026-04-22 → 2026-04-23)

What actually shipped, where it diverged from this spec, and what was added on top.

### 1. Imports gated to today's cycle day, not "the calendar day they happened"

The spec said imports should "appear on the day they happened (not just cycle days)." In practice the implementation gates imports (`trainingCycleId == null`) by `isViewingToday`, which compares the displayed `(period, day)` against today's calendar position in the cycle (`cycle.startDate + daysPerPeriod` math). So an ad-hoc Strava run lands on today's training day but doesn't appear when the user navigates to a different day via the calendar.

This was a pragmatic call: the cycle/period/day model and the calendar-date model don't perfectly align (cycles can start in the past, days-per-period varies, rest days break the mapping). Doing it strictly by date — which the spec implied — would need either a `scheduledDate` populated on every cycle workout (not currently guaranteed) or a date↔(period,day) helper that handles every edge case. Today's behaviour is "imports show up where they're most likely actionable" rather than "imports show up on the precise calendar date." If it bites we can revisit by switching the data source for the displayed day to `sessionsInDateRangeProvider(dayStart, dayEnd)` — see `lib/presentation/screens/workout/workout_screen.dart` lines around `cycleCardioForDay` / `adHocImportsToday` for the exact gate.

### 2. SportGrid is now filtered by the user's onboarding sport selection

Added on top of A4 the same day, in response to user feedback. `SportGrid` accepts a `sports: List<Sport>?` parameter; the Workout screen passes the value of the new `selectedSportsProvider` (a `NotifierProvider<List<Sport>>` wrapping `OnboardingService.selectedSports`). The grid layout adapts to count: 1 wide box for a single sport, 1×N for 2–3, 1×4 compact / 2×2 expanded for 4. A new editor in `Settings → Sports I train` lets the user change the selection without re-onboarding; edits propagate to the Workout tab via the reactive provider. Last-remaining-sport tap is a no-op with a hint string so the min-1 invariant is visible.

Files added/changed for this:
- `lib/domain/providers/onboarding_providers.dart` — added `SelectedSportsNotifier` and `selectedSportsProvider`
- `lib/presentation/widgets/cardio/sport_grid.dart` — `sports` param, dynamic layout, `Sport.other` filtered out
- `lib/presentation/screens/workout/workout_screen.dart` — `ref.watch(selectedSportsProvider)` in `build()`; threaded through `_buildSportGridFooter`, `_buildEmptyDayBody`, and `_buildSessionScroll`'s empty-day fallback
- `lib/presentation/screens/settings/settings_screen.dart` — new `_SportsSection` and `_SportToggleTile` after the Equipment block

### 3. Compact SportGrid was shrunk (1×4 single row, no header)

The original spec implied a 2×2 grid pinned at the bottom with the "ADD SESSION" header strip. After first-cut implementation that turned out to be ~190 px tall — too much real estate. Compact variant is now a single row of N boxes (where N matches the user's selected sports), the header is dropped, padding is `(8,6,8,6)`, and the 4-sport case lands at ~75 px tall (≈⅓ of the original). Box internals shrunk too (icon 32→28 px, font 15→13, spacing 10→6, label gets ellipsis on edge cases). Expanded (empty-day) variant is unchanged — it has the whole screen to fill so 2×2 still makes sense.

### 4. FINISH WORKOUT goes BELOW the SportGrid (locked-in)

Per Fred's call during spec review. Implemented as a plain conditional Column child below the grid (not a Stack `Positioned`); the keyboard covers both the grid and the button via `Scaffold.resizeToAvoidBottomInset: false`.

### 5. Widget tests for `_buildSessionScroll` not added

Spec called for new tests covering the empty / loading / populated branches of `_TodayBody`. The function ended up named `_buildSessionScroll` (a method on the State class, not a separate widget), which is harder to test in isolation. The unit tests for `sortByPerformedOrder` cover the sorting logic that drives the slot ordering; the rendering paths were verified by device smoke-test rather than widget tests. Adding widget tests is a follow-up if regression risk turns out to be real — would likely require extracting `_buildSessionScroll` into a real `ConsumerWidget` first.

### 6. Side fixes that landed during this work

Not part of A4 but tagged here so future readers find them:

- **`ScrollDirection` import** — added `import 'package:flutter/rendering.dart' show ScrollDirection;` to `workout_screen.dart`. Not exported by `flutter/material.dart`.
- **`Positioned.fill` wrapping** — the body Column needed tight constraints inside the Stack; loose-fit Stack layout that worked for the old PageView didn't work for a Column-with-Expanded.
- **Android Gradle release-signing fix** — `android/app/build.gradle.kts` had an unconditional `keystoreProperties["keyAlias"] as String` that blew up with "null cannot be cast to non-null type kotlin.String" on machines without `android/key.properties`. Wrapped the `signingConfigs.create("release") { ... }` in an `if (keystorePropertiesFile.exists())` guard and added a debug-keys fallback for the release build type when the keystore isn't set up. Pre-existing issue, unrelated to A4.
- **Empty-day body lifted to parent** — first-cut implementation rendered the expanded SportGrid inside `_buildSessionScroll` AND the compact footer, producing two grids. Moved the empty-day check up to the build-method Stack so the Column-with-grid OR the empty-day grid is rendered, never both.

### 7. Source of truth for what's in the workout screen now

If something here drifts from the code, the code wins. Key landmarks in `lib/presentation/screens/workout/workout_screen.dart`:

- `build()` — watches `selectedSportsProvider`, computes `dayCardioSessions`, decides empty vs populated.
- `_buildSessionScroll(...)` — sliver list, NotificationListener for keyboard dismiss, calls `sortByPerformedOrder` and a private `_RenderSlot` to interleave cards.
- `_buildSportGridFooter(...)` / `_buildEmptyDayBody(...)` / `_buildFinishWorkoutBar(...)` — the three bottom-of-screen pieces.
- `_onLiftPressed(...)` / `_onCardioPressed(...)` — SportGrid callbacks.
- `dispose()` — preserved debounce-flush logic, untouched.

The PageView-era helpers (`_pageController`, `_isSwiping`, `_lastSyncedPageIndex`, `_buildDayPageContent`, `_addExerciseForDay`, the `Icons.directions_run` AppBar action) are gone. `lib/core/utils/day_sequence.dart` is no longer imported by the Workout screen but the file itself remains in case other screens use it.
