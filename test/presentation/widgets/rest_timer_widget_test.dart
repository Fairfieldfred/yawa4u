import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/domain/providers/rest_timer_provider.dart';
import 'package:yawa4u/presentation/widgets/rest_timer_widget.dart';

void main() {
  group('RestTimerWidget', () {
    testWidgets('renders nothing when timer is not running', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: RestTimerWidget()),
          ),
        ),
      );

      // Default state has isRunning=false, so widget should be SizedBox.shrink
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Rest:'), findsNothing);
    });

    testWidgets('shows timer UI when running', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: RestTimerWidget()),
          ),
        ),
      );

      // Start a 60-second timer
      final notifier = container.read(restTimerProvider.notifier);
      notifier.startCustom(60);
      await tester.pump();

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.textContaining('Rest:'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Cancel so the periodic Timer doesn't leak into the test framework.
      notifier.cancel();
    });

    testWidgets('displays formatted time', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: RestTimerWidget()),
          ),
        ),
      );

      final notifier = container.read(restTimerProvider.notifier);
      notifier.startCustom(90);
      await tester.pump();

      // 90 seconds = 01:30
      expect(find.textContaining('01:30'), findsOneWidget);

      notifier.cancel();
    });

    testWidgets('cancel button stops timer', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: RestTimerWidget()),
          ),
        ),
      );

      container.read(restTimerProvider.notifier).startCustom(60);
      await tester.pump();

      // Tap the skip/cancel button (last icon button)
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.pump();

      // Timer should be hidden now
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('onTap callback invoked with exercise and workout IDs', (tester) async {
      String? tappedExerciseId;
      String? tappedWorkoutId;

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: RestTimerWidget(
                onTap: (exerciseId, workoutId) {
                  tappedExerciseId = exerciseId;
                  tappedWorkoutId = workoutId;
                },
              ),
            ),
          ),
        ),
      );

      final notifier = container.read(restTimerProvider.notifier);
      notifier.start(
        SetType.regular,
        exerciseId: 'ex1',
        workoutId: 'w1',
      );
      await tester.pump();

      // Tap the timer banner (the GestureDetector)
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(tappedExerciseId, 'ex1');
      expect(tappedWorkoutId, 'w1');

      notifier.cancel();
    });
  });
}
