import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/theme/skins/skins.dart';
import 'package:yawa4u/data/database/database.dart' hide TrainingCycle;
import 'package:yawa4u/domain/providers/database_providers.dart';
import 'package:yawa4u/domain/providers/onboarding_providers.dart';
import 'package:yawa4u/domain/providers/rest_timer_provider.dart';
import 'package:yawa4u/l10n/app_localizations.dart';
import 'package:yawa4u/presentation/navigation/app_router.dart';

import 'workout_app_harness.dart' show NoopNotificationService;

/// Bootstraps the full GoRouter app (onboarding redirect included) against
/// an in-memory database and mock preferences.
class AppRouterHarness {
  late AppDatabase db;
  late ProviderContainer container;
  late SharedPreferences prefs;

  Future<void> initialize({Map<String, Object> initialPrefs = const {}}) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    SharedPreferences.setMockInitialValues(initialPrefs);
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
    container.read(restTimerProvider.notifier).cancel();
    container.dispose();
    await db.close();
  }

  /// Pumps the router-driven app (starts at '/', redirects to onboarding
  /// on a fresh install).
  Future<void> pumpApp(WidgetTester tester) async {
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await settle(tester);
  }

  /// Bounded pumps (NOT pumpAndSettle — loading spinners animate forever).
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }
}
