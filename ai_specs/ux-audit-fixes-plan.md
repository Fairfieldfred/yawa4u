# UX/UI Audit Fixes — Implementation Plan

## Overview

Fix all findings from the 2026-07-09 code-level UX/UI audit (5 parallel reviewers, ~91 presentation files).
7 phases in priority order: rest timer → gym ergonomics → backup → funnel/IA → navigation refactor → undo coverage → consistency sweep.

**Spec**: none (quick plan; findings embedded below with file:line refs — this doc is self-contained).

## Context

- **Structure**: layer-first (`core → data → domain → presentation`); Riverpod ^3; go_router ^17; Drift.
- **State management**: `StreamProvider` for Drift, `Notifier` for screen state; repositories own writes.
- **Reference implementations**: undo pattern `workout_screen.dart:452-463` (6s snackbar); empty states `lib/presentation/widgets/empty_state_widget.dart`; snackbar helpers `lib/core/extensions/context_extensions.dart:122-151`; test setup `test/helpers/` (`AppDatabase.forTesting(NativeDatabase.memory())`, mock `sharedPreferencesProvider`).
- **Deps**: `share_plus` + `file_picker` already in pubspec (Phase 3 needs no new deps). NEW dep needed: `flutter_local_notifications` (Phase 1).
- **Testing discipline**: vertical-slice TDD — one failing test at a time, public interfaces only, minimal implementation, refactor after green. Robot journey tests: key-first stable selectors (app-owned `Key`s), deterministic seams (inject clock/prefs), add only selectors needed for declared journeys.
- **Conventions**: all styling via skin system / `Theme.of(context)`; no hardcoded colors; l10n via ARB (`flutter gen-l10n` after edits); `flutter analyze` clean before commit; GitNexus impact analysis before editing shared symbols.
- **Assumptions**: keep `WorkoutRepository` facade untouched; no schema changes anywhere in this plan.

## Plan

### Phase 1: Rest timer that actually works (vertical slice) ✅

- **Goal**: timer survives phone lock; user notified at zero via haptic + local notification.
- [x] `pubspec.yaml` - add `flutter_local_notifications`; platform setup (Android manifest perms/receiver, iOS `AppDelegate`/Info.plist)
- [x] `lib/data/services/notification_service.dart` - NEW: thin wrapper (init, requestPermission, `scheduleAt(DateTime, title, body)`, `cancel`); injectable via provider for fakes
- [x] `lib/domain/providers/rest_timer_provider.dart:70-153` - persist `endTimestamp` (SharedPreferences); derive `remainingSeconds` from wall-clock, not tick count; rehydrate in `build()`; on start → schedule OS notification; on skip/pause → cancel/reschedule; at zero → `HapticFeedback.heavyImpact()`
- [x] `lib/presentation/screens/workout/workout_screen.dart` - `WidgetsBindingObserver`: on resume, re-sync timer state from persisted timestamp
- [x] `lib/presentation/widgets/rest_timer_widget.dart:131-137` - controls ≥44px hit boxes; add −30s alongside +30s (provider: signed `addTime`)
- [x] TDD: timer state derived from persisted end-timestamp survives provider rebuild (inject fake clock + mock prefs)
- [x] TDD: start schedules notification at correct time; skip cancels it; +30s reschedules (fake NotificationService records calls)
- [x] TDD: completion fires haptic + resets state exactly once
- [x] Verify: `flutter analyze` && `flutter test`
- Note (2026-07-10): fixed 34 pre-existing test failures unrelated to this phase — test harnesses lacked l10n delegates (`test/helpers/test_widget_wrapper.dart`, `muscle_group_badge_test.dart`, `cardio_session_card_test.dart`). On-device verification of notification timing (iOS prompt, Android 13+ POST_NOTIFICATIONS / exact-alarm fallback) still recommended.

### Phase 2: In-gym logging ergonomics ✅

- **Goal**: log a set one-handed, keyboard never blocks input, weights pre-filled.
- [x] `lib/presentation/screens/workout/workout_screen.dart:1442` - remove `resizeToAvoidBottomInset: false`; `Scrollable.ensureVisible` on field focus (EditableText's built-in caret-on-screen covers this once insets resize)
- [x] `workout_screen.dart:1702-1711, 1750-1759` - don't dismiss keyboard on scroll while a field has focus
- [x] `lib/presentation/widgets/exercise_card_widget.dart:691,778` - `keyboardAppearance: Theme.of(context).brightness`
- [x] `exercise_card_widget.dart:727-777` - weight `textInputAction.next` + FocusNode chain → reps `.done` (framework's built-in `.next` traversal moves to reps; no manual FocusNodes needed)
- [x] `exercise_card_widget.dart:668,759,864,657,276` - raise weight/reps/log-checkbox to ≥44px height; widen set-menu + info-button hit boxes via `BoxConstraints`
- [x] `exercise_card_widget.dart:886-888` - `HapticFeedback.selectionClick()` on set-log toggle
- [x] `lib/presentation/screens/workout/add_exercise_screen.dart:494-507` - seed initial sets via new `ExerciseHistoryService.buildInitialSets` (wraps `getAutoPopulateWeightWithSuggestion`)
- [x] `exercise_card_widget.dart` + `workout_screen.dart:346-352,885-891` - style auto-suggested (unconfirmed) weight distinctly (accent/italic) until user edits or logs (`autoSuggestedSetIdsProvider`)
- [x] `exercise_card_widget.dart:152-169` - promote "Try X" suggestion to tappable chip that fills weight field; bump last-performance legibility (≥12px, higher contrast)
- [x] `exercise_card_widget.dart` - PR badge on set row when logged weight×reps beats history (`getBestSetVolume` + `isPersonalRecord`)
- [x] `exercise_card_widget.dart:645,887` - tap on disabled Log checkbox → hint snackbar (`onDisabledLogTap`)
- [x] `workout_screen.dart:258-316` (`_toggleSetLog`, `_addSetToExercise`, `_updateSetType`, `_deleteSet`) - wrap writes in try/catch + error snackbar (`_guardWrite`)
- [x] `workout_screen.dart:1299-1301` - distinct loading skeleton vs true empty state (`_buildLoadingState`)
- [x] `lib/presentation/screens/workout/add_exercise_screen.dart:385-406` - batch last-performed lookups (`lastPerformedDatesProvider`, one history pass); autofocus search field (`:94`)
- [x] TDD: initial sets seeded with history weight+suggestion; empty history → empty sets
- [x] TDD: PR detection true/false boundary cases (equal, higher weight lower reps)
- [x] Robot journey: open workout → tap weight → keypad next → reps → log set → timer starts; stable Keys `workout_set_weight_{i}`, `workout_set_reps_{i}`, `workout_set_log_{i}` (`test/journeys/log_set_journey_test.dart` + `test/robots/` + `test/harness/`)
- [x] Verify: `flutter analyze` && `flutter test`

### Phase 3: Backup export/restore to file ✅

- **Goal**: user can recover data without a second device (local-first data-loss gap).
- [x] `lib/data/services/data_backup_service.dart` - ensure `exportToJson()` produces v4 string (already did); added `exportToFile()` (timestamped temp file)
- [x] `lib/presentation/screens/settings/sync_screen.dart` - "Backup" section: Export (share JSON via `share_plus`), Restore (pick via `file_picker` → confirm dialog stating merge semantics → `importFromJson`); progress indicator + success/error snackbars; localized strings (ARB en+es, `flutter gen-l10n`)
- [x] `sync_screen.dart:126,161` - surface merge-vs-replace semantics in WiFi sync UI copy (`syncMergeNote`; kept `replace:false`)
- [x] TDD: export→import round-trip preserves cycles/sessions/exercises/sets — already covered by existing `data_backup_service_test.dart` ("export then import on fresh DB produces equivalent data", "full strength chain round-trips", "full multi-sport chain round-trips"); verified green
- [x] TDD: malformed/v3 file → graceful error/back-compat path — already covered ("corrupted JSON returns error result", "import accepts v3 JSON with no cardio content"); verified green
- [x] Verify: `flutter analyze` && `flutter test`

### Phase 4: First-run funnel, discoverability, settings consolidation ✅

- **Goal**: new user lands somewhere actionable; features findable; one source of truth per setting.
- [x] `workout_screen.dart:2154-2189` - empty state gains primary "Create cycle" + secondary "Use template" actions (reuse `EmptyStateWidget`; added optional per-action `key`)
- [x] `lib/presentation/screens/home/home_screen.dart:111,152` - Cycles tab icon → `Icons.event_note` (both bottom bar and NavigationRail)
- [x] `lib/presentation/navigation/app_router.dart:77-102` + onboarding screens - reorder: Profile → Sports → Equipment → Terminology; equipment skipped when strength not selected (routes unchanged; flow order redirected at the screens' continue handlers)
- [x] `lib/presentation/screens/onboarding/onboarding_profile_screen.dart:490-499,589-613` - height/weight optional (validators only check ranges when filled; Body stats screen remains the later entry point)
- [x] `lib/presentation/screens/onboarding/onboarding_terminology_screen.dart:69-80` - finish → `context.go('/')` (Home); Workout-tab CTA takes over
- [x] `lib/presentation/screens/more/more_screen.dart` - "Community library" tile → `/community`; Training section (Statistics first) promoted above Appearance
- [x] `more_screen.dart:334-368` / `settings_screen.dart:322-345` - single Language surface (`showLanguageSheet` in localization_classes.dart; both locations open it)
- [x] `more_screen.dart:261-267` / `settings_screen.dart:284-319` - Settings toggle labeled "Default units" + "Per-sport units…" cross-link
- [x] `settings_screen.dart:279` - unsaved-changes guard (`PopScope` + discard dialog)
- [x] `cycle_create_screen.dart:326-334` - `autovalidateMode: onUserInteraction`; "Creates N periods × M days" summary above Create
- [x] `cycle_list_screen.dart:391-428` - disabled "Save as template"/"Share" get explanatory hint line (`_MenuItemWithHint`)
- [x] Robot journey: fresh install → onboarding (skip profile fields) → land Home → tap empty-state CTA → cycle create screen; Keys `onboarding_continue`, `empty_workout_create_cycle` (`test/journeys/onboarding_journey_test.dart`)
- [x] Verify: `flutter analyze` && `flutter test`

### Phase 5: Navigation architecture (StatefulShellRoute) ✅

- **Goal**: tabs deep-linkable; one navigation idiom; kill `homeTabIndexProvider` side-effect coupling.
- **Risk boundary**: isolated phase — touches many screens; run GitNexus impact on `homeTabIndexProvider` + `HomeScreen` first. (GitNexus index was stale/read-only; impact mapped via grep — 8 call sites across 7 screens, all migrated.)
- [x] `app_router.dart` - migrate `/` IndexedStack to `StatefulShellRoute.indexedStack` with branches `/`, `/cycles`, `/exercises`, `/calendar`, `/more`
- [x] `home_screen.dart:32-55` - shell renders `navigationShell`; keep NavigationRail/Ctrl+1-5 shortcuts
- [x] Replace `homeTabIndexProvider`-then-`go('/')` call sites (cycle_list ×3, calendar, cycle_create, community_template_detail, template_preview, edit_workout) with direct `context.go('/')`/`context.go('/cycles')`; `navigation_providers.dart` deleted; CLAUDE.md + DATA_STRUCTURE_v6.md updated
- [x] `app_router.dart` - `/templates` route for `TemplateSelectionScreen`; imperative pushes (plan_a_cycle, cycle_list, workout empty-state) → `context.push('/templates')`; `popUntil` workarounds removed (template_preview, community_template_detail)
- [x] Keep legacy redirects (`/workouts` → `/sessions`) working — untouched, verified by analyze/tests
- [x] Robot journey: deep-link to `/calendar` renders Calendar tab; back from pushed template screen returns to Cycles tab (`test/journeys/tab_deep_link_journey_test.dart`)
- [x] Verify: `flutter analyze` && `flutter test`

### Phase 6: Forgiveness & undo coverage ✅

- **Goal**: every destructive/movable action reversible or clearly confirmed.
- [x] `lib/presentation/screens/calendar/calendar_screen.dart:367-451,648-732` - `onExerciseDropped`/`onExerciseReordered`/cardio moves capture undo snapshots before mutate; `ScheduleSnapshot` gained `exercisePlacements` so exercise moves/reorders actually restore (previously the snapshot couldn't undo cross-workout moves); `moveCardioToDate`/`reorderExerciseWithinDayByDate` now return snapshots
- [x] `calendar_screen.dart` snackbars (moved exercise/cardio, rest-day inserted/removed) - `SnackBarAction` "Undo" (6s) invoking restore; edit-sheet Undo kept
- [x] `lib/domain/providers/calendar_providers.dart:645-661` - in-session undo; 24h claim dropped (`hasRecentSnapshot` = snapshot exists)
- [x] `workout_screen.dart:2718-2786` - Reset workout: fresh-from-DB snapshots → 6s undo snackbar (`_restoreWorkouts`). Also fixed a real bug: `copyWith(weight: null)` was a no-op, so Reset never cleared weights — added `ExerciseSet.copyWith(clearWeight:)`
- [x] `cycle_list_screen.dart:1184-1228` - delete-cycle dialog enumerates N workouts + N logged sets destroyed; destructive styling kept
- [x] `lib/presentation/screens/cardio/cardio_session_screen.dart` - `PopScope` dirty-guard (mirrors interval builder)
- [x] `cardio_session_screen.dart:201,286-304,247-248` - `_ModeIndicator` Plan/Log segmented indicator; confirm dialog on planned→completed promotion
- [x] `cardio_session_screen.dart:497-504` - RPE: clear button for "not set", slider min 1
- [x] `lib/presentation/screens/cardio/interval_builder_screen.dart:693-700` - pace/power zone kinds hidden until zones configured (kept visible if the interval already uses them); distance target uses `DistanceInput` with the sport's `UnitSystem`
- [x] `lib/presentation/screens/settings/integrations_screen.dart:249-258` - Strava disconnect confirm dialog
- [x] TDD: calendar move snapshot→undo restores exact prior scheduledDates (multi-cycle) + cardio-move and exercise-placement restore tests (`schedule_service_test.dart`)
- [x] TDD: reset-workout undo restores weight/reps/isLogged per set (`workout_flow_test.dart`)
- [x] Verify: `flutter analyze` && `flutter test`

### Phase 7: Consistency sweep — theming, l10n, errors, a11y, community polish ✅ (complete)

- **Goal**: skin system honored everywhere; es locale complete; no silent errors.
- [x] `lib/core/extensions/context_extensions.dart:147` - success snackbar uses the skin success color; dialog/loading helpers now REQUIRE localized strings (no English defaults; zero existing callers). Also removed the Navigator push/pop helpers — they collided with go_router's extension and had no callers
- [x] `lib/core/theme/app_theme.dart:88-543` - dead static themes + `AppThemeMode` deleted (zero refs verified); `MuscleGroupColors` ThemeExtension kept
- [x] `lib/core/theme/colors.dart:117-132` - `getMuscleColor` deleted (zero callers; skin-driven `MuscleGroupColors` is the real mechanism)
- [x] Hardcoded-color sweep — priority files converted: `exercise_card_widget.dart` (greys → `onSurfaceVariant`/`disabledColor`), `edit_workout_screen.dart` (hardcoded dark menu surface + white-on-color → theme card/onSurface), `calendar_screen.dart` (`Colors.red` → `context.errorColor` ×4)
- [x] Inline-TextStyle sweep (256 hits) — done 2026-07-12: ~170 size/weight styles across 37 files converted to the `textTheme` ramp (`text_styles.dart` sizes; w500/w700 snapped to ramp weights, off-ramp sizes snapped to nearest, explicit colors always carried via `copyWith`). Remaining 81 `TextStyle(` occurrences are color-only styles (out of scope) plus 3 deliberate leaves (conditional-bold chip labels with no fontSize, where the chip theme owns the size). Verified: `flutter analyze` clean, 1145 tests green, screenshot pass vs baseline — all 19 dark screens reproduced with only intended typography deltas (see `ai_specs/screenshots/{baseline,current,diff}/`)
  - Baseline screenshots captured 2026-07-11 in `ai_specs/screenshots/baseline/` (19 dark + 8 light screens) via a reproducible harness: `flutter drive --driver=test_driver/screenshot_driver.dart --target=integration_test/ui_baseline_screenshots_test.dart -d <simulator>`. The test is self-seeding (flutter drive fresh-installs the app each run: it skips onboarding via prefs and creates/starts a "5 Day Full Body" template cycle through the app's repositories), so re-running it after the sweep produces directly diffable after-shots. Caveats: template-picker/preview and some light-theme dialog/community captures are flaky run-to-run; shell-branch finders must stay `.hitTestable()`.
- [x] Swallowed errors: `exercise_card_widget.dart:108` history-load failure → tap-to-retry affordance; `calendar_sport_dots.dart:35` failure now logged; `cycle_comparison_view.dart:160-163` raw `Error: $e` → localized; integrations sync errors were already surfaced inline (unknown-error fallback localized)
- [x] Migrate direct `ScaffoldMessenger` calls → `context.show*SnackBar` helpers: 107 simple calls across 23 files migrated; calls with `SnackBarAction`/custom styling (e.g. undo snackbars) intentionally stay raw — the helpers don't support actions
- [x] Localize stragglers: `calendar_dropdown` period snackbars; integrations unknown-error + last-run summary; month arrays in `cardio_session_screen` + `cycle_list_screen` → locale-aware `DateFormat`; `stats_screen` measurement date → `DateFormat.Md`
- [x] `integrations_screen.dart:42-88` - permission-denied guide branches on `Platform.isIOS` (Apple Health steps + `app-settings:` deep-link) vs Android Health Connect
- [x] A11y: `textScaler` clamped 0.8–1.6 in MaterialApp builder; icon-only buttons in cardio/stats/settings/community all carry tooltips (verified — none missing); scroll wrappers added to `rest_timer_dialog.dart` + all three `workout_dialogs.dart` dialogs; inches field labeled
- [x] `stats_screen.dart:434-486` - Overview empty state when no workouts (mirrors Cardio tab guard); chart heights scale with viewport (clamped 180–320)
- [x] Community: upload affordance always visible (unverified tap → `showEmailLinkPrompt`); signed-out My Uploads gets a Sign in button; template download shows a success snackbar before navigating; `initialTab` clamped
- [x] Verify: `flutter analyze` && `flutter test` && ARB parity check (no missing/extra keys; only the pre-existing ICU false positives noted in LOCALIZATION.md)

## Risks / Out of scope

- **Risks**: (1) Phase 5 shell-route migration touches many call sites — isolated phase, GitNexus impact first, legacy redirects must keep working; (2) `flutter_local_notifications` platform setup (iOS permission prompt timing, Android 13+ POST_NOTIFICATIONS) needs on-device verification beyond tests; (3) theming/l10n sweeps are wide-but-mechanical — commit per-file-group to keep diffs reviewable.
- **Out of scope**: visual/spacing redesign (needs simulator screenshot pass); stats feature promotion to a tab (kept as More reorder only); persisting calendar undo across restarts; timer sound (haptic + notification only); renaming legacy `workoutUuid` column; any DB schema change.
