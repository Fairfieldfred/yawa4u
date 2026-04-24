# A4: WorkoutHomeScreen Sliver Scroll — Completion Record

> Chunk 4 of Section A in `DESIGN_OPPORTUNITIES.md`. Replaced the `PageView`-based day view with a `CustomScrollView` and pinned `SportGrid` footer.

**Status: shipped 2026-04-22.** All acceptance criteria met. Overflow menu added 2026-04-23.

For the full Section A summary, see `DESIGN_OPPORTUNITIES.md`. For data model details, see `DATA_STRUCTURE_v5.md`.

---

## What shipped

- `CustomScrollView` with `SliverList` of interleaved strength exercise cards and `CardioSessionCard` widgets, sorted by `sortByPerformedOrder` (completed → in-progress → planned).
- Pinned `SportGrid` footer outside the scroll. Compact (1xN single row) when day has content; expanded (2x2) filling the body on empty days.
- `FINISH WORKOUT` button below the SportGrid (not in a Stack).
- `Scaffold.resizeToAvoidBottomInset: false` — keyboard covers SportGrid rather than pushing it up.
- Debounce-flush logic in `dispose()` preserved verbatim from the PageView era.
- `NotificationListener<UserScrollNotification>` dismisses keyboard on meaningful scroll.
- PageView, `_pageController`, `_isSwiping`, `_lastSyncedPageIndex` all removed.

---

## Non-obvious decisions (post-ship notes)

### 1. Imports gated to today's cycle day

Ad-hoc imports (`trainingCycleId == null`) appear only when `isViewingToday` — they don't follow the user when navigating to other days via the calendar. Pragmatic call: the cycle/period/day model doesn't perfectly align with calendar dates. Could revisit by switching to `sessionsInDateRangeProvider(dayStart, dayEnd)` for all day views.

### 2. SportGrid filtered by onboarding sport selection

`SportGrid` accepts `sports: List<Sport>?` driven by `selectedSportsProvider`. Layout adapts: 1 wide box for single sport, 1xN for 2-3, 2x2 expanded for 4. Editable in Settings without re-onboarding. Min-1 invariant enforced with a hint string.

### 3. Compact SportGrid is a single row, no header

Original spec had a 2x2 grid with "ADD SESSION" header (~190px). Actual compact variant is a single row of N boxes (~75px). Expanded (empty-day) variant remains 2x2.

### 4. Widget tests deferred

`_buildSessionScroll` is a State method (not a standalone widget), making it hard to test in isolation. `sortByPerformedOrder` has 7 unit tests. Rendering paths verified by device smoke-test. Extracting to a real `ConsumerWidget` would enable proper widget tests if regression risk materializes.

---

## Key landmarks in the code

`lib/presentation/screens/workout/workout_screen.dart`:

| Method | Purpose |
|---|---|
| `build()` | Watches `selectedSportsProvider`, computes `dayCardioSessions`, decides empty vs populated |
| `_buildSessionScroll(...)` | Sliver list + keyboard dismiss + `sortByPerformedOrder` + `_RenderSlot` interleaving |
| `_buildSportGridFooter(...)` | Compact SportGrid at bottom |
| `_buildEmptyDayBody(...)` | Expanded SportGrid for empty days |
| `_buildFinishWorkoutBar(...)` | Conditional FINISH WORKOUT button |
| `_onLiftPressed(...)` | Auto-creates StrengthSession if needed, pushes AddExerciseScreen |
| `_onCardioPressed(...)` | Pushes `/cardio-session/new` with cycle/period/day params |
| `dispose()` | Debounce-flush via `_setDaoForDispose` capture (preserved from pre-rewrite) |

---

## CardioSessionCard overflow menu (2026-04-23)

Full overflow menu matching exercise card's pattern. Items: Notes, Move up/down, Replace, Skip, Delete (with 6-second undo). Ephemeral `_manualSlotOrder` state for reordering; reset on data mutation. See `DESIGN_OPPORTUNITIES.md` Section A for details.

Files: `cardio_session_card.dart`, `workout_screen.dart`, `workout_dialogs.dart`. Tests: 17 in `cardio_session_card_test.dart`.
