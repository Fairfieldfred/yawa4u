# YAWA4U — UX Review

Post-Phase-6 assessment. Originally written 2026-04-17 (post-Phase-5), updated 2026-04-23 to reflect completed work.

---

## Executive summary

The strength-training core has mature UX. The cardio expansion (Phases 3–6) is now **integrated, not just additive** — the Workout tab renders both strength and cardio as sibling cards, every top-level tab has a quick-log action, and the cycle list shows sport distribution visually.

Remaining opportunities are polish-level: empty-state consolidation, contrast tokens, drag-to-reorder refinements, and skeleton loaders.

---

## P0 — All addressed

### 1. Onboarding ignores the multi-sport expansion — DONE

`onboarding_sports_screen.dart` asks "Which sports do you train?" with multi-select (Strength, Run, Bike, Swim). Per-sport unit preferences seeded from selection. Strength pre-selected by default.

### 2. Destructive actions lack confirmation dialogs — DONE

`workout_screen.dart` uses optimistic delete + 6-second undo snackbar (Gmail/Material pattern) for both `_deleteSet` and `_deleteExercise`. `edit_workout_screen.dart` uses explicit confirmation AlertDialog. Two different patterns but both are safe — undo snackbar is arguably better UX for live-workout flow.

### 3. Error messages leak raw exceptions — DONE

`lib/core/utils/user_errors.dart` centralizes user-facing error copy. Maps known exception shapes to phrases like "Couldn't save — try again." Used across stats, cardio, and cycle screens. No raw `$e` strings remain in user-facing snackbars.

### 4. Onboarding uses raw Navigator.push — DONE

All onboarding screens now use `context.push()` (go_router). Routes exist for `/onboarding/equipment`, `/onboarding/sports`, `/onboarding/terminology`.

---

## P1 — Mostly addressed

### 5. Cardio is invisible on the main Workout tab — DONE

Resolved by the Section A home screen redesign. The Workout tab is now a `CustomScrollView` with interleaved strength exercise cards and `CardioSessionCard` widgets. A pinned `SportGrid` footer provides one-tap session creation for all four sports. See DESIGN_OPPORTUNITIES.md Section A.

### 6. "Workout" vs. "Session" terminology — DONE (scoped)

Settled in `TERMINOLOGY.md`: "Workout" is the user-facing label, "Session" is the code-level term. `WorkoutRepository` is a facade over `SessionRepository` in v6. Routes coexist (`/workouts/...` and `/cardio-session/...`). No global rename of UI strings — "Workout" works across all sports.

### 7. More menu is crowded and ungrouped — DONE

`more_screen.dart` has section headers (`_MoreSectionHeader`): Appearance, Training, Integrations & data, Preferences, Help & feedback, About. The "Log cardio session" tile was removed (now handled by QuickLogAction on every tab).

### 8. Onboarding profile screen has structural awkwardness — PARTIALLY DONE

- Progress indicator added (Step 1 of 4, linear bar in AppBar).
- BMI display compacted into an expandable bottom sheet.
- Icon picker remains at the top of the form — functional but could be moved to "later" settings.
- Weight range validation could be tightened (currently accepts 30–300 kg / 66–660 lbs).

### 9. Empty states are inconsistent in quality — OPEN

Empty states follow a similar pattern (icon + title + description) but are implemented ad-hoc per screen. No shared `_StandardEmptyState` widget exists. The cardio stats empty state and zones empty state are well-done; others vary.

**Remaining work:** Extract a reusable `EmptyStateWidget(icon, title, body, ctaLabel, onCta)` and migrate existing empty states to use it. ~half a session.

### 10. Stats screen cycle selector only affects Overview tab — DONE

Cycle dropdown lifted above the TabBar. All tabs (Overview, Cardio, Compare, Body) respect `_selectedCycleId`.

---

## P2 — Polish items

### 11. Contrast: text with alpha <= 0.5 — OPEN

Pattern `onSurface.withValues(alpha: 0.5)` used in several screens. Should define `context.textSecondary` (0.7) and `context.textTertiary` (0.55) as theme tokens.

**Effort:** ~half a session of mechanical find/replace.

### 12. Touch targets smaller than 48x48 — OPEN

Equipment checkboxes (~20x20) in onboarding. Some dense `IconButton`s.

**Effort:** ~30 minutes.

### 13. Loading states are all-or-nothing — OPEN

Full-screen `CircularProgressIndicator` on initial load with no skeleton UI. Can be improved incrementally with `AnimatedSwitcher` + gray placeholders.

**Effort:** Low per screen, wide surface area.

### 14. Interval builder drag-to-reorder — DONE

`interval_builder_screen.dart` uses `ReorderableListView.builder`. Material standard reorder handles are in place.

### 15. App icon picker in onboarding is clever but unclear — OPEN

Shuffling carousel with no affordance label. Could add labels under each variant or move to Settings.

**Effort:** ~30 minutes.

### 16. Mobile calendar sport dots — DONE

`CalendarSportDots` widget renders colored dots per sport. Used in mobile calendar via `markerBuilder`. Reads from `sessionsInDateRangeProvider` so imports are included.

### 17. WeeklySummaryCard additional placements — DONE

Present on cycle list screen and stats screen (beyond its original single placement).

---

## What I explicitly did NOT review

- **Actual on-device rendering.** Findings about visual hierarchy or contrast are based on code inspection, not live testing.
- **Animations and transitions.** Code-level review doesn't show timing or feel.
- **Accessibility with a real screen reader.** TalkBack / VoiceOver testing would surface missing `Semantics` labels.
- **Internationalization.** Every UI string is currently English-only.

---

## Remaining work summary

| Item | Priority | Effort |
|------|----------|--------|
| Empty state consolidation (#9) | P1 | ~half session |
| Contrast tokens (#11) | P2 | ~half session |
| Touch targets (#12) | P2 | ~30 min |
| Skeleton loaders (#13) | P2 | Incremental |
| Icon picker labels (#15) | P2 | ~30 min |
| Onboarding weight range (#8) | P2 | ~15 min |
