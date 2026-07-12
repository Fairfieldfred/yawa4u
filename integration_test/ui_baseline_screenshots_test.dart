import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yawa4u/domain/providers/database_providers.dart';
import 'package:yawa4u/domain/providers/template_providers.dart';
import 'package:yawa4u/domain/providers/use_case_providers.dart';
import 'package:yawa4u/main.dart' as app;

/// Walks the screens touched by the Phase-7 inline-TextStyle sweep and
/// captures baseline screenshots (dark + light) via the screenshot driver:
///
///   flutter drive --driver=test_driver/screenshot_driver.dart \
///     --target=integration_test/ui_baseline_screenshots_test.dart -d `{device}`
///
/// `flutter drive` fresh-installs the app, so the test is self-seeding: it
/// pre-marks onboarding complete, then creates and starts a cycle from the
/// built-in "5 Day Full Body" template through the app's own repositories.
///
/// Two hard-won rules for this app:
/// - The home tabs are StatefulShellRoute.indexedStack branches, so hidden
///   branches stay in the widget tree — every finder MUST be `.hitTestable()`
///   or taps land on offstage widgets.
/// - goTab taps the destination twice: the second tap (now the active tab)
///   pops that branch back to its root, clearing leftover pushed routes.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture UI baseline screenshots', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    await prefs.setBool('has_created_first_trainingCycle', true);
    await prefs.setString('theme_mode', 'dark');
    await prefs.setString('user_training_cycle_term', 'Mesocycle');

    app.main();
    await _settle(tester, seconds: 10);

    Future<void> cap(String name) async {
      await tester.pump(const Duration(milliseconds: 300));
      try {
        await binding.takeScreenshot(name);
      } catch (e) {
        debugPrint('SCREENSHOT FAILED $name: $e');
      }
    }

    Future<void> goTab(IconData icon) async {
      final tab = find
          .descendant(
            of: find.byType(BottomNavigationBar),
            matching: find.byIcon(icon),
          )
          .hitTestable();
      if (tab.evaluate().isEmpty) {
        debugPrint('STEP FAILED (goTab $icon): tab not found');
        return;
      }
      await tester.tap(tab.first, warnIfMissed: false);
      await _settle(tester);
      // Second tap pops the (now active) branch back to its root route.
      await tester.tap(tab.first, warnIfMissed: false);
      await _settle(tester);
    }

    Future<void> step(String what, Future<void> Function() body) async {
      try {
        await body();
      } catch (e) {
        debugPrint('STEP FAILED ($what): $e');
      }
    }

    // The fresh-install empty state is itself a sweep target (Phase 4 CTA).
    await cap('dark_00_workout_empty_state');

    // Seed: create + start a cycle from the built-in template, with
    // scheduled dates starting today, using the app's own providers.
    await step('seed cycle', () async {
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp).first),
        listen: false,
      );
      final templateRepo = container.read(templateRepositoryProvider);
      final templates = await templateRepo.getAllTemplates();
      final template = templates.firstWhere(
        (t) => t.name.toLowerCase().contains('full body'),
        orElse: () => templates.first,
      );
      final result = await templateRepo.createTrainingCycleFromTemplate(template);
      await container.read(trainingCycleRepositoryProvider).create(result.trainingCycle);
      final workoutRepo = container.read(workoutRepositoryProvider);
      final today = DateTime.now();
      final day0 = DateTime(today.year, today.month, today.day);
      for (final workout in result.trainingCycle.workouts) {
        final offset = (workout.periodNumber - 1) * result.trainingCycle.daysPerPeriod + (workout.dayNumber - 1);
        await workoutRepo.create(
          workout.copyWith(scheduledDate: day0.add(Duration(days: offset))),
        );
      }
      for (final cardio in result.cardioSessions) {
        await container.read(sessionRepositoryProvider).createCardio(cardio);
      }
      await container.read(startTrainingCycleUseCaseProvider).execute(result.trainingCycle);
      await _settle(tester, seconds: 4);
    });

    Future<void> captureAllScreens(String prefix) async {
      // 1. Workout home (Session tab)
      await goTab(Icons.play_circle_fill);
      await cap('${prefix}_01_workout_home');

      // 2. Exercise info dialog
      await step('info dialog', () async {
        final info = find.byTooltip('Exercise info').hitTestable();
        if (info.evaluate().isEmpty) return;
        await tester.tap(info.first, warnIfMissed: false);
        await _settle(tester);
        await cap('${prefix}_02_exercise_info_dialog');
        await tester.tapAt(const Offset(20, 120));
        await _settle(tester);
      });

      // 3. Workout app-bar menu + cycle summary dialog
      await step('workout menu', () async {
        final menu = find.descendant(of: find.byType(AppBar), matching: find.byIcon(Icons.more_vert)).hitTestable();
        if (menu.evaluate().isEmpty) return;
        await tester.tap(menu.first, warnIfMissed: false);
        await _settle(tester);
        await cap('${prefix}_03_workout_menu');
        final summary = find.text('Summary').hitTestable();
        if (summary.evaluate().isNotEmpty) {
          await tester.tap(summary.first, warnIfMissed: false);
          await _settle(tester);
          await cap('${prefix}_04_cycle_summary_dialog');
          await tester.tapAt(const Offset(20, 120));
          await _settle(tester);
        } else {
          await tester.tapAt(const Offset(20, 400));
          await _settle(tester);
        }
      });

      // 4. Muscle-group picker + add-exercise screen (FAB)
      await step('add exercise', () async {
        await goTab(Icons.play_circle_fill);
        final fab = find.byType(FloatingActionButton).hitTestable();
        if (fab.evaluate().isEmpty) return;
        await tester.tap(fab.first, warnIfMissed: false);
        await _settle(tester);
        await cap('${prefix}_05_muscle_group_picker');
        final chest = find.text('Chest').hitTestable();
        if (chest.evaluate().isNotEmpty) {
          await tester.tap(chest.first, warnIfMissed: false);
          await _settle(tester);
          await cap('${prefix}_05b_add_exercise');
          // Close via the X so we skip both this screen and the sheet.
          final close = find.byIcon(Icons.close).hitTestable();
          if (close.evaluate().isNotEmpty) {
            await tester.tap(close.first, warnIfMissed: false);
            await _settle(tester);
          } else {
            await _back(tester);
          }
        }
        // If the muscle-group sheet is still up, dismiss via its barrier.
        if (find.text('Select Muscle Group').hitTestable().evaluate().isNotEmpty) {
          await tester.tapAt(const Offset(220, 60));
          await _settle(tester);
        }
      });

      // 5. Cycle list + card menu
      await goTab(Icons.event_note);
      await cap('${prefix}_06_cycle_list');
      await step('cycle menu', () async {
        final menu = find.byIcon(Icons.more_vert).hitTestable();
        if (menu.evaluate().isEmpty) return;
        await tester.tap(menu.last, warnIfMissed: false);
        await _settle(tester);
        await cap('${prefix}_07_cycle_menu');
        await tester.tapAt(const Offset(20, 400));
        await _settle(tester);
      });

      // 6. Cycle detail / plan editor (tap the cycle card)
      await step('cycle detail', () async {
        await goTab(Icons.event_note);
        final card = find.textContaining('Full Body').hitTestable();
        if (card.evaluate().isEmpty) return;
        await tester.tap(card.first, warnIfMissed: false);
        await _settle(tester);
        await cap('${prefix}_07b_cycle_detail');
        await goTab(Icons.event_note);
      });

      // 7. Cycle create screen
      await step('cycle create', () async {
        final newBtn = find.text('New').hitTestable();
        if (newBtn.evaluate().isEmpty) return;
        await tester.tap(newBtn.first, warnIfMissed: false);
        await _settle(tester);
        await cap('${prefix}_08_cycle_create');
        await _back(tester);
        final discard = find.textContaining('Discard').hitTestable();
        if (discard.evaluate().isNotEmpty) {
          await tester.tap(discard.last, warnIfMissed: false);
          await _settle(tester);
        }
      });

      // 8. Template picker + preview
      await step('templates', () async {
        await goTab(Icons.event_note);
        final tmpl = find.textContaining('emplate').hitTestable();
        if (tmpl.evaluate().isEmpty) return;
        await tester.tap(tmpl.first, warnIfMissed: false);
        await _settle(tester, seconds: 4);
        await cap('${prefix}_08b_template_selection');
        final card = find.textContaining('Full Body').hitTestable();
        if (card.evaluate().isNotEmpty) {
          await tester.tap(card.first, warnIfMissed: false);
          await _settle(tester);
          await cap('${prefix}_08c_template_preview');
          await _back(tester);
        }
        await _back(tester);
      });

      // 9. Exercises tab
      await goTab(Icons.fitness_center);
      await cap('${prefix}_09_exercises');

      // 10. Calendar tab
      await goTab(Icons.calendar_month);
      await cap('${prefix}_10_calendar');

      // 11. More tab + Statistics
      await goTab(Icons.more_horiz);
      await cap('${prefix}_11_more');
      await step('statistics', () async {
        final stats = find.text('Statistics').hitTestable();
        if (stats.evaluate().isEmpty) return;
        await tester.tap(stats.first, warnIfMissed: false);
        await _settle(tester);
        await cap('${prefix}_12_stats_overview');
        await _back(tester);
      });

      // 12. Community library: programs, detail, themes, uploads
      await step('community', () async {
        await goTab(Icons.more_horiz);
        final tile = find.text('Community Library').hitTestable();
        if (tile.evaluate().isEmpty) return;
        await tester.tap(tile.first, warnIfMissed: false);
        await _settle(tester, seconds: 6);
        await cap('${prefix}_14_community_programs');
        final detailCard = find.textContaining('Arms').hitTestable();
        if (detailCard.evaluate().isNotEmpty) {
          await tester.tap(detailCard.first, warnIfMissed: false);
          await _settle(tester, seconds: 6);
          await cap('${prefix}_15_community_template_detail');
          await _back(tester);
        }
        final themes = find.text('Themes').hitTestable();
        if (themes.evaluate().isNotEmpty) {
          await tester.tap(themes.first, warnIfMissed: false);
          await _settle(tester, seconds: 6);
          await cap('${prefix}_16_community_themes');
        }
        final uploads = find.text('My Uploads').hitTestable();
        if (uploads.evaluate().isNotEmpty) {
          await tester.tap(uploads.first, warnIfMissed: false);
          await _settle(tester, seconds: 6);
          await cap('${prefix}_17_community_my_uploads');
        }
        await _back(tester);
      });
    }

    // ---- Dark pass ----
    await captureAllScreens('dark');

    // ---- Light pass ----
    await goTab(Icons.more_horiz);
    final light = find.text('Light').hitTestable();
    if (light.evaluate().isNotEmpty) {
      await tester.tap(light.first, warnIfMissed: false);
      await _settle(tester);
      await captureAllScreens('light');
    }
  }, timeout: const Timeout(Duration(minutes: 15)));
}

/// pumpAndSettle that tolerates screens with ongoing animations.
Future<void> _settle(WidgetTester tester, {int seconds = 3}) async {
  try {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 200),
      EnginePhase.sendSemanticsUpdate,
      Duration(seconds: seconds),
    );
  } catch (_) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

Future<void> _back(WidgetTester tester) async {
  final backTooltip = find.byTooltip('Back').hitTestable();
  final backIcon = find.byIcon(Icons.arrow_back).hitTestable();
  final backIos = find.byIcon(Icons.arrow_back_ios).hitTestable();
  if (backTooltip.evaluate().isNotEmpty) {
    await tester.tap(backTooltip.first, warnIfMissed: false);
  } else if (backIcon.evaluate().isNotEmpty) {
    await tester.tap(backIcon.first, warnIfMissed: false);
  } else if (backIos.evaluate().isNotEmpty) {
    await tester.tap(backIos.first, warnIfMissed: false);
  } else {
    try {
      await tester.pageBack();
    } catch (_) {}
  }
  await _settle(tester);
}
