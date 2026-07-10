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

### Phase 4: First-run funnel, discoverability, settings consolidation

- **Goal**: new user lands somewhere actionable; features findable; one source of truth per setting.
- [ ] `workout_screen.dart:2154-2189` - empty state gains primary "Create cycle" + secondary "Use template" actions (reuse `EmptyStateWidget`)
- [ ] `lib/presentation/screens/home/home_screen.dart:111,152` - Cycles tab icon → plan-style (e.g. `Icons.event_note`), not `Icons.analytics`
- [ ] `lib/presentation/navigation/app_router.dart:77-102` + onboarding screens - reorder: Profile → Sports → Equipment → Terminology; filter equipment step by chosen sports (skip if no strength)
- [ ] `lib/presentation/screens/onboarding/onboarding_profile_screen.dart:490-499,589-613` - height/weight optional (remove hard validators; prompt later at first Body-stats use)
- [ ] `lib/presentation/screens/onboarding/onboarding_terminology_screen.dart:69-80` - finish → `context.go('/')` (Home), not forced cycle creation; Workout-tab CTA (above) takes over
- [ ] `lib/presentation/screens/more/more_screen.dart` - add "Community library" tile → `/community`; promote Statistics placement
- [ ] `more_screen.dart:334-368` / `lib/presentation/screens/settings/settings_screen.dart:322-345` - single Language surface; other location links to it
- [ ] `more_screen.dart:261-267` / `settings_screen.dart:284-319` - label Settings toggle "Default units", cross-link to per-sport overrides screen
- [ ] `settings_screen.dart:279` - unsaved-changes guard (`PopScope` + discard dialog) for Save-model fields
- [ ] `cycle_create_screen.dart:326-334` - `autovalidateMode: onUserInteraction`; add "creates N periods × M days" summary line above Create (`:384-398`)
- [ ] `cycle_list_screen.dart:391-428` - disabled "Save as template"/"Share" get explanatory subtitle (why disabled)
- [ ] Robot journey: fresh install → onboarding (skip profile fields) → land Home → tap empty-state CTA → cycle create screen; Keys `onboarding_continue`, `empty_workout_create_cycle`
- [ ] Verify: `flutter analyze` && `flutter test`

### Phase 5: Navigation architecture (StatefulShellRoute)

- **Goal**: tabs deep-linkable; one navigation idiom; kill `homeTabIndexProvider` side-effect coupling.
- **Risk boundary**: isolated phase — touches many screens; run GitNexus impact on `homeTabIndexProvider` + `HomeScreen` first.
- [ ] `app_router.dart` - migrate `/` IndexedStack to `StatefulShellRoute.indexedStack` with branches `/`, `/cycles`, `/exercises`, `/calendar`, `/more`
- [ ] `home_screen.dart:32-55` - shell renders `navigationShell`; keep NavigationRail/Ctrl+1-5 shortcuts
- [ ] Replace `homeTabIndexProvider`-then-`go('/')` call sites (`cycle_list_screen.dart:243,684,954`, `calendar_screen.dart:1701`, `cycle_create_screen.dart:185`, `community_template_detail_screen.dart:63-75`) with direct `context.go('/cycles')` etc.
- [ ] `app_router.dart` - add route for `TemplateSelectionScreen`; convert imperative pushes (`plan_a_cycle_screen.dart:100`, `cycle_list_screen.dart:564`, `workout_screen.dart:791,2105`) to `context.push`; remove `popUntil` workaround (`template_preview_screen.dart:57-60`)
- [ ] Keep legacy redirects (`app_router.dart:144-150,197-205`) working
- [ ] Robot journey: deep-link to `/calendar` renders Calendar tab; back from pushed template screen returns to correct tab
- [ ] Verify: `flutter analyze` && `flutter test`

### Phase 6: Forgiveness & undo coverage

- **Goal**: every destructive/movable action reversible or clearly confirmed.
- [ ] `lib/presentation/screens/calendar/calendar_screen.dart:367-451,648-732` - `onExerciseDropped`/`onExerciseReordered`/cardio moves capture undo snapshots (`calendarUndoProvider.notifier.setSnapshots`) before mutate
- [ ] `calendar_screen.dart` snackbars (moved/inserted/removed) - add `SnackBarAction` "Undo" invoking restore (keep edit-sheet Undo too)
- [ ] `lib/domain/providers/calendar_providers.dart:645-661` - align messaging with reality: in-session undo (drop the 24h claim) OR persist snapshots; pick in-session
- [ ] `workout_screen.dart:2718-2786` - Reset workout: snapshot sets → 6s undo snackbar (mirror delete-set pattern `:452-463`)
- [ ] `cycle_list_screen.dart:1184-1228` - delete-cycle dialog enumerates what's destroyed (N workouts, logged history); type-safe destructive styling kept
- [ ] `lib/presentation/screens/cardio/cardio_session_screen.dart` - `PopScope` dirty-guard (mirror `interval_builder_screen.dart:245-252`)
- [ ] `cardio_session_screen.dart:201,286-304,247-248` - explicit Plan/Log segmented indicator; confirm dialog on planned→completed promotion
- [ ] `cardio_session_screen.dart:497-504` - RPE: discrete "not set" affordance (clear button/`null` chip), slider min 1
- [ ] `lib/presentation/screens/cardio/interval_builder_screen.dart:693-700` - hide pace/power zone kinds until zones configured (per file-header intent `:24-27`); distance target respects `UnitSystem` (`:769-801`, reuse `DistanceInput`)
- [ ] `lib/presentation/screens/settings/integrations_screen.dart:249-258` - Strava disconnect confirm dialog
- [ ] TDD: calendar move snapshot→undo restores exact prior scheduledDates (multi-cycle)
- [ ] TDD: reset-workout undo restores weight/reps/isLogged per set
- [ ] Verify: `flutter analyze` && `flutter test`

### Phase 7: Consistency sweep — theming, l10n, errors, a11y, community polish

- **Goal**: skin system honored everywhere; es locale complete; no silent errors.
- [ ] `lib/core/extensions/context_extensions.dart:147` - success snackbar uses `SkinExtension.success`; `:171-230` dialog/loading defaults require localized strings (update all callers; ARB en+es)
- [ ] `lib/core/theme/app_theme.dart:88-543` - delete dead static themes (verify zero refs first)
- [ ] `lib/core/theme/colors.dart:117-132` - `getMuscleColor` → skin-driven `MuscleGroupColors` (English-substring match breaks under es)
- [ ] Hardcoded-color sweep (249 hits): priority files `exercise_card_widget.dart` (grey states → `colorScheme.onSurfaceVariant`), `edit_workout_screen.dart` (white-on-color), `calendar_screen.dart:423,446,705,727` (`Colors.red` → `context.errorColor`)
- [ ] Inline-TextStyle sweep (256 hits): priority files `community_browse_screen.dart`, `exercise_card_widget.dart`, `edit_workout_screen.dart`, `completed_cycle_workout_screen.dart`, `calendar_screen.dart` → `context.textTheme.*`
- [ ] Swallowed errors → small retry affordance: `integrations_screen.dart:337`, `exercise_card_widget.dart:108`, `calendar_sport_dots.dart:35`; raw `Error: $e` → localized message `cycle_comparison_view.dart:160-163`
- [ ] Migrate direct `ScaffoldMessenger` calls (108) to `context.show*SnackBar` helpers — mechanical, per-file
- [ ] Localize stragglers: `calendar_dropdown.dart:169,189,228`; `integrations_screen.dart:627,635-640`; hardcoded month arrays `cardio_session_screen.dart:448-465`, `cycle_list_screen.dart:1230-1245` → `DateFormat`; `stats_screen.dart:386` date format
- [ ] `integrations_screen.dart:42-88` - branch permission-denied guide on `Platform.isIOS` (Apple Health copy + iOS Settings deep-link) vs Android Health Connect
- [ ] A11y: clamp `textScaler` app-side (MaterialApp builder); `Semantics` labels on icon-only buttons in cardio/stats/settings/community; scroll wrappers in `rest_timer_dialog.dart` + `workout_dialogs.dart`; `settings_screen.dart:414` inches label
- [ ] `stats_screen.dart:434-486` - Overview empty state (guard charts like `:183-190`); `:453,462,326` responsive chart heights
- [ ] Community: `community_browse_screen.dart:66` always show upload affordance → unverified tap triggers `showEmailLinkPrompt`; `:372-392` signed-out My Uploads gets sign-in button; `community_template_detail_screen.dart:63-75` success snackbar before nav (match skin flow `community_skin_detail_screen.dart:51-57`); clamp `initialTab` (`:35`)
- [ ] Verify: `flutter analyze` && `flutter test` && ARB parity check (LOCALIZATION.md script)

## Risks / Out of scope

- **Risks**: (1) Phase 5 shell-route migration touches many call sites — isolated phase, GitNexus impact first, legacy redirects must keep working; (2) `flutter_local_notifications` platform setup (iOS permission prompt timing, Android 13+ POST_NOTIFICATIONS) needs on-device verification beyond tests; (3) theming/l10n sweeps are wide-but-mechanical — commit per-file-group to keep diffs reviewable.
- **Out of scope**: visual/spacing redesign (needs simulator screenshot pass); stats feature promotion to a tab (kept as More reorder only); persisting calendar undo across restarts; timer sound (haptic + notification only); renaming legacy `workoutUuid` column; any DB schema change.
