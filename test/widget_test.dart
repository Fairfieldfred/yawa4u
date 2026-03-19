// Widget tests for Yawa4u app.
//
// These tests verify the app boots correctly with proper initialization
// of SkinRepository and SharedPreferences.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/theme/skins/skin_repository.dart';
import 'package:yawa4u/data/models/training_cycle.dart';
import 'package:yawa4u/data/models/workout.dart';
import 'package:yawa4u/data/models/exercise.dart';
import 'package:yawa4u/data/models/custom_exercise_definition.dart';
import 'package:yawa4u/domain/providers/database_providers.dart';
import 'package:yawa4u/domain/providers/exercise_providers.dart';
import 'package:yawa4u/domain/providers/onboarding_providers.dart';
import 'package:yawa4u/domain/providers/training_cycle_providers.dart';
import 'package:yawa4u/domain/providers/workout_providers.dart';
import 'package:yawa4u/main.dart';

import 'helpers/test_app_database.dart';

void main() {
  late SharedPreferences prefs;
  late TestAppDatabase testDb;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': true,
      'user_height_cm': 180.0,
      'user_weight_kg': 80.0,
    });
    prefs = await SharedPreferences.getInstance();
    await SkinRepository().initialize(prefs);

    testDb = TestAppDatabase();
    await testDb.initialize();
  });

  tearDown(() async {
    await testDb.close();
  });

  /// Build ProviderScope that overrides ALL Drift-backed StreamProviders
  /// with simple [Stream.value] equivalents. This prevents Drift stream
  /// subscriptions whose cleanup creates pending zero-duration timers
  /// that fail the Flutter test framework's invariant check.
  ProviderScope buildTestApp() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(testDb.database),
        workoutsProvider.overrideWith(
          (ref) => Stream.value(<Workout>[]),
        ),
        trainingCyclesProvider.overrideWith(
          (ref) => Stream.value(<TrainingCycle>[]),
        ),
        exercisesProvider.overrideWith(
          (ref) => Stream.value(<Exercise>[]),
        ),
        customExerciseDefinitionsProvider.overrideWith(
          (ref) => Stream.value(<CustomExerciseDefinition>[]),
        ),
      ],
      child: const MyApp(),
    );
  }

  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Theme is configured with light and dark modes',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.themeMode, ThemeMode.dark);
    expect(materialApp.theme, isNotNull);
    expect(materialApp.darkTheme, isNotNull);
  });

  testWidgets('App title is set correctly', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'YAWA4U');
  });
}
