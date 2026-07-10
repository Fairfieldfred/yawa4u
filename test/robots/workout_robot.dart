import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/domain/providers/rest_timer_provider.dart';

import '../harness/workout_app_harness.dart';

/// Intent-level interactions with the Workout tab's exercise cards.
class WorkoutRobot {
  WorkoutRobot(this.tester, this.harness);

  final WidgetTester tester;
  final WorkoutAppHarness harness;

  Finder _weightField(int setIndex) => find.byKey(ValueKey('workout_set_weight_$setIndex'));
  Finder _repsField(int setIndex) => find.byKey(ValueKey('workout_set_reps_$setIndex'));
  Finder _logCheckbox(int setIndex) => find.byKey(ValueKey('workout_set_log_$setIndex'));

  Future<void> enterWeight(int setIndex, String weight) async {
    final field = _weightField(setIndex).first;
    expect(field, findsOneWidget);
    await tester.tap(field);
    await tester.pump();
    await tester.enterText(field, weight);
    await tester.pump();
  }

  /// Presses the keypad's Next action (weight field → reps field).
  Future<void> pressKeyboardNext() async {
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
  }

  Future<void> enterReps(int setIndex, String reps) async {
    final field = _repsField(setIndex).first;
    expect(field, findsOneWidget);
    await tester.enterText(field, reps);
    await tester.pump();
    // Let the debounced weight/reps writes flush.
    await tester.pump(const Duration(milliseconds: 400));
  }

  void expectRepsFieldFocused(int setIndex) {
    final editable = find.descendant(
      of: _repsField(setIndex).first,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(editable).focusNode.hasFocus, isTrue);
  }

  Future<void> logSet(int setIndex) async {
    final checkbox = _logCheckbox(setIndex).first;
    expect(checkbox, findsOneWidget);
    await tester.tap(checkbox);
    // Bounded pumps for the async write + provider refresh.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  void expectRestTimerRunning() {
    final timerState = harness.container.read(restTimerProvider);
    expect(timerState.isRunning, isTrue, reason: 'rest timer should start when a set is logged');
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  }

  /// Stops the rest timer's periodic display Timer so the widget-test
  /// binding's pending-timer invariant passes at the end of the journey.
  Future<void> stopRestTimer() async {
    harness.container.read(restTimerProvider.notifier).cancel();
    await tester.pump();
  }
}
