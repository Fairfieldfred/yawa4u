// Stats screen — Overview tab template selector.
//
// Verifies the cycle dropdown offers an "All Time" scope that aggregates
// every strength session on the device, including cycle-less sessions
// imported by a cloud/WiFi sync.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/theme/skins/skin_repository.dart';
import 'package:yawa4u/data/models/session.dart';
import 'package:yawa4u/data/models/stats_data.dart';
import 'package:yawa4u/data/models/training_cycle.dart';
import 'package:yawa4u/data/models/user_measurement.dart';
import 'package:yawa4u/domain/providers/measurement_providers.dart';
import 'package:yawa4u/domain/providers/onboarding_providers.dart';
import 'package:yawa4u/domain/providers/session_providers.dart';
import 'package:yawa4u/domain/providers/stats_providers.dart';
import 'package:yawa4u/domain/providers/training_cycle_providers.dart';
import 'package:yawa4u/l10n/app_localizations.dart';
import 'package:yawa4u/presentation/screens/stats/stats_screen.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  const cycleId = 'cycle-1';

  late SharedPreferences prefs;

  // Stats shown while a single template is selected — one session only.
  const cycleStats = WorkoutStats(
    totalWorkouts: 1,
    completedWorkouts: 1,
    skippedWorkouts: 0,
    completionRate: 1,
    setsByMuscleGroup: {},
    exerciseFrequency: {},
    volumeProgression: [],
    personalRecords: {},
    totalSets: 0,
  );

  // One session inside the template + one cycle-less session of the kind
  // a cloud sync imports.
  final sessions = <Session>[
    TestFixtures.createStrengthSession(
      id: 'in-cycle',
      trainingCycleId: cycleId,
      status: WorkoutStatus.completed,
    ),
    TestFixtures.createStrengthSession(
      id: 'synced',
      status: WorkoutStatus.completed,
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await SkinRepository().initialize(prefs);
  });

  Widget buildScreen() {
    final cycle = TestFixtures.createTrainingCycle(
      id: cycleId,
      name: 'My Template',
      status: TrainingCycleStatus.current,
    );
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        trainingCyclesProvider.overrideWith(
          (ref) => Stream.value(<TrainingCycle>[cycle]),
        ),
        sessionsProvider.overrideWithValue(AsyncValue.data(sessions)),
        cycleStatsProvider(cycleId).overrideWith((ref) => cycleStats),
        userMeasurementsProvider.overrideWith(
          (ref) => Stream.value(<UserMeasurement>[]),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StatsScreen(),
      ),
    );
  }

  /// Bounded pumps — charts may animate, pumpAndSettle could hang.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('dropdown offers an All Time scope', (tester) async {
    await tester.pumpWidget(buildScreen());
    await settle(tester);

    // Default scope is the active template.
    expect(find.text('My Template (Active)'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String?>));
    await settle(tester);

    expect(find.text('All Time'), findsOneWidget);
  });

  testWidgets('All Time aggregates every session on the device', (tester) async {
    await tester.pumpWidget(buildScreen());
    await settle(tester);

    // Template scope: only the in-cycle session.
    expect(find.text('1/1'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String?>));
    await settle(tester);
    await tester.tap(find.text('All Time'));
    await settle(tester);

    // All Time: the in-cycle session plus the cycle-less synced one.
    expect(find.text('2/2'), findsOneWidget);
  });
}
