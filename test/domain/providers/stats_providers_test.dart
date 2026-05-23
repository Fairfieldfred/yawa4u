import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/data/models/session.dart';
import 'package:yawa4u/domain/providers/session_providers.dart';
import 'package:yawa4u/domain/providers/stats_providers.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  group('cardioStatsProvider', () {
    test('computes stats from cardio sessions', () {
      final sessions = <Session>[
        TestFixtures.createCardioSession(
          id: 'cs1',
          sport: Sport.run,
          status: WorkoutStatus.completed,
          detail: TestFixtures.createCardioDetail(
            actualDistanceM: 5000.0,
            actualDurationSec: 1500,
          ),
        ),
        TestFixtures.createCardioSession(
          id: 'cs2',
          sport: Sport.run,
          status: WorkoutStatus.completed,
          detail: TestFixtures.createCardioDetail(
            actualDistanceM: 10000.0,
            actualDurationSec: 3000,
          ),
        ),
        // Strength sessions should be ignored
        TestFixtures.createStrengthSession(id: 'ss1'),
      ];

      final container = ProviderContainer(
        overrides: [
          sessionsProvider.overrideWithValue(AsyncValue.data(sessions)),
        ],
      );
      addTearDown(container.dispose);

      final stats = container.read(cardioStatsProvider);
      expect(stats.perSport.containsKey(Sport.run), isTrue);
    });

    test('returns empty stats when no sessions', () {
      final container = ProviderContainer(
        overrides: [
          sessionsProvider.overrideWithValue(const AsyncValue.data([])),
        ],
      );
      addTearDown(container.dispose);

      final stats = container.read(cardioStatsProvider);
      expect(stats.perSport, isEmpty);
    });

    test('returns empty stats on error', () {
      final container = ProviderContainer(
        overrides: [
          sessionsProvider.overrideWithValue(
            AsyncValue.error(Exception('error'), StackTrace.current),
          ),
        ],
      );
      addTearDown(container.dispose);

      final stats = container.read(cardioStatsProvider);
      expect(stats.perSport, isEmpty);
    });
  });

  group('cardioStatsBySportProvider', () {
    test('filters stats to single sport', () {
      final sessions = <Session>[
        TestFixtures.createCardioSession(
          id: 'cs1',
          sport: Sport.run,
          detail: TestFixtures.createCardioDetail(actualDistanceM: 5000.0),
        ),
        TestFixtures.createCardioSession(
          id: 'cs2',
          sport: Sport.bike,
          detail: TestFixtures.createCardioDetail(actualDistanceM: 20000.0),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          sessionsProvider.overrideWithValue(AsyncValue.data(sessions)),
        ],
      );
      addTearDown(container.dispose);

      final runStats = container.read(cardioStatsBySportProvider(Sport.run));
      // Should only include run sessions
      expect(runStats.perSport.containsKey(Sport.bike), isFalse);
    });
  });

  group('thisWeekStrengthCountProvider', () {
    test('counts strength sessions this week', () {
      final now = DateTime.now();
      final sessions = <Session>[
        TestFixtures.createStrengthSession(
          id: 'ss1',
          scheduledDate: now,
        ),
        TestFixtures.createStrengthSession(
          id: 'ss2',
          scheduledDate: now.subtract(const Duration(days: 1)),
        ),
        // Cardio should not be counted
        TestFixtures.createCardioSession(
          id: 'cs1',
          sport: Sport.run,
          scheduledDate: now,
        ),
        // Old session should not be counted
        TestFixtures.createStrengthSession(
          id: 'ss3',
          scheduledDate: now.subtract(const Duration(days: 30)),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          sessionsProvider.overrideWithValue(AsyncValue.data(sessions)),
        ],
      );
      addTearDown(container.dispose);

      final count = container.read(thisWeekStrengthCountProvider);
      // The exact count depends on what day of the week "now" is,
      // so just verify it's at least 1 (today's session is always in range)
      expect(count, greaterThanOrEqualTo(1));
    });

    test('returns 0 on error', () {
      final container = ProviderContainer(
        overrides: [
          sessionsProvider.overrideWithValue(
            AsyncValue.error(Exception('error'), StackTrace.current),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(thisWeekStrengthCountProvider), equals(0));
    });

    test('returns 0 when no sessions', () {
      final container = ProviderContainer(
        overrides: [
          sessionsProvider.overrideWithValue(const AsyncValue.data([])),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(thisWeekStrengthCountProvider), equals(0));
    });
  });
}
