import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/theme/skins/skins.dart';
import 'package:yawa4u/data/database/database.dart' hide TrainingCycle;
import 'package:yawa4u/data/services/notification_service.dart';
import 'package:yawa4u/domain/providers/database_providers.dart';
import 'package:yawa4u/domain/providers/onboarding_providers.dart';
import 'package:yawa4u/domain/providers/rest_timer_provider.dart';
import 'package:yawa4u/l10n/app_localizations.dart';
import 'package:yawa4u/presentation/screens/workout/workout_screen.dart';

/// No-op notification service for widget tests (no platform channels).
class NoopNotificationService implements NotificationService {
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
  Future<void> cancel(int id) async {}
}

/// Bootstraps the Workout tab against an in-memory database.
///
/// Owns the [ProviderContainer] and database lifecycle; call [dispose] in
/// tearDown.
class WorkoutAppHarness {
  late AppDatabase db;
  late ProviderContainer container;
  late SharedPreferences prefs;

  Future<void> initialize() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await SkinRepository().initialize(prefs);
    db = AppDatabase.forTesting(NativeDatabase.memory());

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(NoopNotificationService()),
        restTimerHapticProvider.overrideWithValue(() async {}),
      ],
    );
  }

  Future<void> dispose() async {
    // Stop the rest timer's periodic display timer before teardown so the
    // test framework doesn't flag a pending Timer.
    container.read(restTimerProvider.notifier).cancel();
    container.dispose();
    await db.close();
  }

  /// Pumps the Workout tab and waits for the initial async loads.
  Future<void> pumpWorkoutTab(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const WorkoutHomeScreen(),
        ),
      ),
    );
    // Bounded pumps (NOT pumpAndSettle — the rest timer ticks forever).
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }
}
