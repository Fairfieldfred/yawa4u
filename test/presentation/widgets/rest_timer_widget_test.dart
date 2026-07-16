import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/models/live_set_info.dart';
import 'package:yawa4u/data/services/notification_service.dart';
import 'package:yawa4u/domain/providers/onboarding_providers.dart';
import 'package:yawa4u/domain/providers/rest_timer_provider.dart';
import 'package:yawa4u/l10n/app_localizations.dart';
import 'package:yawa4u/presentation/widgets/rest_timer_widget.dart';

/// No-op notification service so widget tests never hit platform channels.
class _NoopNotificationService implements NotificationService {
  @override
  Future<void> ensureInitialized() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> showNow({required int id, required String title, required String body}) async {}

  @override
  Future<void> showRestCountdown({required int id, required DateTime until, required LiveSetInfo info}) async {}

  @override
  Future<void> showRestPaused({required int id, required LiveSetInfo info, required String remainingDisplay}) async {}

  @override
  Future<void> cancel(int id) async {}
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(_NoopNotificationService()),
        restTimerHapticProvider.overrideWithValue(() async {}),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> pumpTimer(
    WidgetTester tester,
    ProviderContainer container, {
    void Function(String exerciseId, String workoutId)? onTap,
  }) {
    return tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RestTimerWidget(onTap: onTap)),
        ),
      ),
    );
  }

  group('RestTimerWidget', () {
    testWidgets('renders nothing when timer is not running', (tester) async {
      final container = makeContainer();
      await pumpTimer(tester, container);

      // Default state has isRunning=false, so widget should be SizedBox.shrink
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Rest:'), findsNothing);
    });

    testWidgets('shows timer UI when running', (tester) async {
      final container = makeContainer();
      await pumpTimer(tester, container);

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
      final container = makeContainer();
      await pumpTimer(tester, container);

      final notifier = container.read(restTimerProvider.notifier);
      notifier.startCustom(90);
      await tester.pump();

      // 90 seconds = 01:30
      expect(find.textContaining('01:30'), findsOneWidget);

      notifier.cancel();
    });

    testWidgets('minus button subtracts 30 seconds', (tester) async {
      final container = makeContainer();
      await pumpTimer(tester, container);

      final notifier = container.read(restTimerProvider.notifier);
      notifier.startCustom(90);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(container.read(restTimerProvider).remainingSeconds, 60);
      expect(find.textContaining('01:00'), findsOneWidget);

      notifier.cancel();
    });

    testWidgets('control buttons have at least 44px hit boxes', (tester) async {
      final container = makeContainer();
      await pumpTimer(tester, container);

      container.read(restTimerProvider.notifier).startCustom(60);
      await tester.pump();

      for (final icon in [Icons.pause_rounded, Icons.remove, Icons.add, Icons.skip_next_rounded]) {
        final size = tester.getSize(
          find.ancestor(of: find.byIcon(icon), matching: find.byType(InkWell)).first,
        );
        expect(size.width, greaterThanOrEqualTo(44), reason: '$icon width');
        expect(size.height, greaterThanOrEqualTo(44), reason: '$icon height');
      }

      container.read(restTimerProvider.notifier).cancel();
    });

    testWidgets('cancel button stops timer', (tester) async {
      final container = makeContainer();
      await pumpTimer(tester, container);

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

      final container = makeContainer();
      await pumpTimer(
        tester,
        container,
        onTap: (exerciseId, workoutId) {
          tappedExerciseId = exerciseId;
          tappedWorkoutId = workoutId;
        },
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
