# YAWA4U — UX Review

Post-Phase-5 assessment. Grounded in actual code inspection, not assumptions.

Author: UX pass for Fred
Date: 2026-04-17

---

## Executive summary

The strength-training core has mature UX. The cardio expansion (Phases 3–5) works but feels additive, not integrated. The three biggest opportunities to improve the app right now, in order:

1. **Cardio is a second-class citizen on the home screen.** A user opening YAWA4U to "do cardio today" has no affordance on the Workout tab — they go through More → Log cardio session. This is backwards. The cardio banner in `edit_workout_screen.dart` helps inside a cycle, but the main workout-of-the-day surface has no cardio entry.
2. **Onboarding is strength-only.** Three screens ask about height, equipment, and terminology — none ask "what sports do you train?". New users get a lifter-shaped experience even if they signed up to track runs.
3. **"Workout" vs. "Session" terminology is now ambiguous.** Code, routes, and UI strings mix the two. Until that settles, documentation and support conversations will be harder than they should be.

Below, findings are prioritized P0 (ship-blocking for a polished release), P1 (significant friction), P2 (polish).

---

## P0 — Address before the next public build

### 1. Onboarding ignores the multi-sport expansion

**Where:** `lib/presentation/screens/onboarding/onboarding_terminology_screen.dart`, and the whole 3-screen flow.

**Problem:** After Phases 1–5, the app supports four sports, per-sport units, and per-sport HR zones. Onboarding asks about none of it. A runner who installs the app walks out with imperial lifting units, no primary-sport hint on their first cycle, and no zones configured.

**Fix:** Insert a sport-preference screen between Profile and Equipment, or fold it into terminology. "Which sports are you planning to track? (multi-select)" → set `OnboardingService.setUnitsFor` with sport-aware defaults; the first cycle creator prefills `primarySport` from the first checked choice.

**Effort:** ~1 focused session.

### 2. Destructive actions lack confirmation dialogs

**Where:** `workout_screen.dart` `_deleteSet` call site (direct delete, no prompt). Compare with `_deleteExercise` which does prompt.

**Problem:** A mistyped tap on a set's delete button wipes the set instantly with no undo. On a small screen this is easy to do. `_localWeights.clear()` similarly discards in-flight edits when the user navigates away.

**Fix:** Wrap `_deleteSet` with a confirmation dialog OR — better UX — replace with optimistic delete + snackbar undo ("Set deleted. Undo."). Same pattern for exercise delete. Guard navigate-away when in-flight edits exist.

**Effort:** ~half a session.

### 3. Error messages leak raw exceptions to users

**Where:** `cardio_session_screen.dart` save handler (`'Could not save session: $e'`), `stats_screen.dart` error branch (`'Error loading stats: $error'`), `cycle_create_screen.dart` create handler.

**Problem:** Flutter exception strings are dev-facing. A user who hits a transient Drift lock sees something like `Could not save session: StateError (Bad state: already closed)` — unactionable.

**Fix:** Centralize user-facing error copy (e.g., `lib/core/utils/user_errors.dart`). Map known exception shapes to phrases like "Couldn't save — try again." For `stats_screen.dart` specifically, add a Retry button rather than a dead-end error message.

**Effort:** ~1 focused session. Touching every catch block is mechanical.

### 4. Onboarding uses raw `Navigator.push`, breaking go-router back-stack

**Where:** `onboarding_profile_screen.dart:384` uses `Navigator.of(context).push(MaterialPageRoute(...))`. Rest of the app uses `context.push()` / `context.go()`.

**Problem:** The onboarding screens exist outside go-router's awareness. Back button behavior is subtly different, deep linking into onboarding is broken, and the `/onboarding` guard in the router only protects the first screen.

**Fix:** Add routes for `/onboarding/equipment` and `/onboarding/terminology`, use `context.push()` between them. Single-commit refactor.

**Effort:** ~half a session.

---

## P1 — Significant friction

### 5. Cardio is invisible on the main Workout tab

**Where:** `lib/presentation/screens/workout/workout_screen.dart` (WorkoutHomeScreen) — the first thing a user sees after launch.

**Problem:** There's no button, banner, or entry point for cardio. A user who wants to log a run has to tap Training Cycles → open a cycle → scroll to the right day → tap "Add cardio" in the banner, OR tap More → Log cardio session. Neither is discoverable.

**Fix (two options):**

- **Minimum:** Add a small "Log cardio" chip in the AppBar of the Workout tab or a secondary FAB. Opens the sport picker → cardio session screen.
- **Better:** Add a sport-switcher above the current workout content so the workout tab renders either strength or cardio contextually. This aligns with the polymorphic model and doesn't push cardio to a settings-style menu.

**Effort:** Min → half a session. Better → a focused session.

### 6. "Workout" vs. "Session" terminology is inconsistent

**Where:** Everywhere. Route is `/workouts`, model is `Workout` alongside new `Session`, UI strings mix "workout" and "session", code comments disagree with each other, help text talks about "cycles" and "workouts" but new cardio flows say "sessions".

**Problem:** Documentation is already impossible to write coherently. Fred's own mental model will drift over time. Support conversations ("I can't find my workout" vs. "I can't find my session") get confusing.

**Fix:** Pick one for the user-facing label — my recommendation is **"Session"** because it generalizes better across sports and already matches the new data model. Then:
- UI strings replace "workout" → "session" globally
- Route `/workouts/…` → `/sessions/…` with redirects for backward compat
- Database table name stays `workouts` for now (migration cost) — only the visible label changes

Schedule this for a focused session and use search-and-replace carefully. The `Workout` model class name can stay for another major version to avoid a huge refactor blast.

**Effort:** ~half a session.

### 7. More menu is crowded and ungrouped

**Where:** `lib/presentation/screens/more/more_screen.dart` — after Phase 5, ~14 list tiles including Appearance, Statistics, Log cardio session, Units, Zones, Integrations, Share App, Share Template, Sync, Settings, Send feedback, Website, Language, Privacy, plus the debug tile.

**Problem:** Long flat lists force scanning. Users can't find "where are my units?" without scrolling past 8 other tiles.

**Fix:** Add `_SectionHeader` rows between groups:
- **Appearance** (theme mode, skins)
- **Training** (stats, units, zones)
- **Integrations** (integrations, sync, share data, share template)
- **Log** (cardio session)
- **About** (feedback, website, language, privacy, settings)

**Effort:** ~30 minutes of layout work.

### 8. Onboarding profile screen has structural awkwardness

**Where:** `onboarding_profile_screen.dart`.

**Observed issues:**
- "Let's get to know you" header is followed immediately by the app icon picker. The subtitle "Your preferred app icon" misleads — the screen does height + weight + DEXA too. Icon picking should come later or be optional.
- Weight ranges are extremely permissive (66–660 lbs / 30–300 kg). 660 lbs is world-record bench press bodyweight. A typo of `300` instead of `200` won't be caught.
- BMI indicator is dense information wedged between weight input and DEXA expander. The BMI category legend + big circle + CDC link is a lot for an onboarding screen.
- No progress indicator ("Step 1 of 3"). Users don't know how much onboarding is left.

**Fix:** Reorder to Height → Weight → BMI (small card only) → optional DEXA → optional App Icon. Tighten weight ranges (80–400 lbs / 40–180 kg catches 99.9% of users). Add step indicator.

**Effort:** ~half a session.

### 9. Empty states are inconsistent in quality

**Where:** Scattered.

**Good examples (keep as reference):** Stats Cardio tab empty state — icon, heading, subtext, specific next-action. Weekly summary card empty state.

**Bad examples:** `stats_screen.dart` Body Metrics empty state tells users "Add body measurements in Settings" but doesn't link. Workout empty state in `workout_screen.dart` says "No workouts available" with no CTA. Cardio banner empty shows only an "Add cardio" chip with no framing.

**Fix:** Extract a `_StandardEmptyState` widget taking `(icon, title, body, ctaLabel, onCta)` and reuse across all screens. Body Metrics should link to Settings, Workout empty should link to "Create a Cycle".

**Effort:** ~half a session.

### 10. Stats screen cycle selector only affects Overview tab

**Where:** `stats_screen.dart` build method.

**Problem:** The cycle dropdown appears inside the Overview TabBarView child, so the Cardio, Compare, and Body tabs don't react to it. Users select "Summer Bulk" on Overview, swipe to Cardio, and see lifetime stats — not the bulk's cardio stats.

**Fix:** Lift the cycle selector out of the Overview tab and place it directly under the TabBar (before the TabBarView). Pass the `effectiveCycleId` into `_buildCardioTab()` and filter accordingly (the `cardioStatsForCycleProvider` is already built).

**Effort:** ~30 minutes.

---

## P2 — Polish items

### 11. Contrast: text with alpha ≤ 0.5 on surface backgrounds

**Where:** `stats_screen.dart`, `onboarding_profile_screen.dart`, empty-state icons across the app. Pattern: `Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)` on text/icons.

**Problem:** Likely fails WCAG AA body-text contrast (4.5:1). In bright sunlight on an OLED screen, 0.5-alpha body text is nearly invisible.

**Fix:** Define `context.textSecondary` (alpha 0.7) and `context.textTertiary` (alpha 0.55) as explicit theme tokens. Reserve sub-0.5 alpha for purely decorative elements. Run actual contrast-check on your real skin palettes.

**Effort:** ~half a session of mechanical find/replace.

### 12. Touch targets smaller than 48×48

**Where:** Equipment checkboxes (~20×20) in onboarding. Some `IconButton`s in dense rows.

**Fix:** Wrap small controls in an `InkWell` with `minWidth` / `minHeight` of 48. For `IconButton`, set `visualDensity: VisualDensity.standard` rather than `compact`.

**Effort:** ~30 minutes.

### 13. Loading states are all-or-nothing

**Where:** Stats screen, Cardio session screen (edit mode), template preview.

**Problem:** Full-screen `CircularProgressIndicator` on initial load. No skeleton UI. On a slow network or cold DB start, the screen is blank for 1–2 seconds.

**Fix:** Render the screen chrome (AppBar, section headers, skeleton placeholders) while data loads. Flutter's `AnimatedSwitcher` + gray rectangles handles 90% of this cleanly without a dedicated skeleton package.

**Effort:** Low but surface-area-wide. Can be incremental.

### 14. Interval builder lacks drag-to-reorder

**Where:** `interval_builder_screen.dart` — up/down arrow buttons per row.

**Problem:** For users building a 10-step interval workout, moving the 8th step to slot 2 is 6 button taps. Acceptable for v1, painful beyond that.

**Fix:** Wrap the interval list in `ReorderableListView`. Material handles drag handles. Also add drag-to-reorder for exercises in strength workouts while you're there (same widget, same pattern).

**Effort:** ~half a session.

### 15. App icon picker in onboarding is clever but unclear

**Where:** `onboarding_profile_screen.dart` `_buildSelectableIcon` — shows three icons, selected one centered and enlarged.

**Problem:** The shuffling carousel is a novel interaction with no affordance explaining what it does. First-time users don't know the icons are tappable or what they represent (different gender variants? different brand variants?).

**Fix:** Either move icon selection out of onboarding (users hit More → customize later) or add an explicit label under each variant ("Neutral", "Masculine", "Feminine" or whatever the actual distinction is).

**Effort:** ~30 minutes.

### 16. Mobile calendar doesn't show sport dots

**Where:** `table_calendar` usage in `calendar_screen.dart`. The desktop calendar cell got `CalendarSportDots` in Phase 3B; the mobile calendar didn't.

**Fix:** Use `table_calendar`'s `markerBuilder` to render the same `CalendarSportDots` widget for days that have cardio sessions. Already built; just needs wiring.

**Effort:** ~30 minutes.

### 17. WeeklySummaryCard is built but under-exposed

**Where:** `lib/presentation/widgets/cardio/weekly_summary_card.dart` is on the cycle list screen only.

**Opportunity:** Also show it on the Stats Overview tab, the Home screen, or the empty state of the Workout tab. The component is self-contained and cheap to embed.

**Effort:** ~15 minutes per placement.

---

## Beyond fixes: three design opportunities

### A. Home screen redesign

The Workout tab is currently "today's lifting workout or empty state". Post-multisport, it could be "today's plan — lifting sets, cardio sessions, yesterday's imported HealthKit workouts, this week's progress". A real "today" surface instead of a single-workout viewer. This is the single biggest lever for making the cardio expansion feel native.

### B. Quick-log affordance

TrainingPeaks, Strava, and Garmin all have a FAB-style quick-log surface that sits on every screen. YAWA4U's "Add exercise" FAB is contextual to the workout screen; "Log cardio" is buried in More. A single persistent quick-log (⊕ in the AppBar everywhere) that opens the sport picker would be a discoverability multiplier.

### C. Cycle view is strength-shaped

The cycle list tiles, the calendar view, and the cycle creator all lean heavily on muscle-group language, colors, and priorities. For a triathlon cycle, this is the wrong framing. A cycle rendered with a sport distribution ribbon ("6 runs, 4 bikes, 2 swims, 3 lifts") would communicate the cycle's character more directly than the current muscle-group-priority system.

---

## Suggested execution order

If you're going to work through these, my recommendation:

1. **One focused session:** P0 items #1 (onboarding sport pref), #2 (destructive-action confirms), #3 (error copy), #4 (onboarding nav fix). All mechanical, high impact.
2. **One focused session:** P1 items #5 (cardio on home tab), #7 (more-menu groups), #8 (onboarding reorder). UX-level improvements.
3. **One focused session:** P1 #6 (terminology normalization — "Session" everywhere). Needs careful search/replace.
4. **Slow burn:** P2 items. Pick them off one at a time when you want a quick win.

Opportunities A / B / C are each a design-first pass worth a whole session of thinking before writing code.

---

## What I explicitly did NOT review

- **Actual on-device rendering.** I can't run the app. Any finding about visual hierarchy or contrast assumes the Material 3 defaults behave predictably — an on-device photo shoot will surface things I can't.
- **Animations and transitions.** Code-level review doesn't show timing or feel.
- **Onboarding A/B performance.** No analytics data, just static analysis.
- **Accessibility with a real screen reader.** TalkBack / VoiceOver testing would surface missing `Semantics` labels that static analysis hints at but can't verify.
- **Internationalization.** Every UI string is currently English-only; real i18n audit is separate work.

This review is honest about what one careful read can and can't see.
