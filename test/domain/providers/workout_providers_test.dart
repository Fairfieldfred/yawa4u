import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/data/models/session.dart';
import 'package:yawa4u/data/models/workout.dart';
import 'package:yawa4u/domain/providers/session_providers.dart';
import 'package:yawa4u/domain/providers/workout_providers.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  // Testing StreamProvider-derived providers using pre-loaded AsyncValue
  // overrides. ProviderContainer can't resolve stream .future in tests
  // reliably, so we test the logic of derived providers by feeding them
  // pre-resolved AsyncValue.data via overrideWithValue on the derived
  // synchronous providers.

  group('completedWorkoutsProvider', () {
    test('filters to completed workouts only', () {
      final workouts = [
        TestFixtures.createWorkout(
          id: 'w1',
          status: WorkoutStatus.completed,
        ),
        TestFixtures.createWorkout(
          id: 'w2',
          status: WorkoutStatus.incomplete,
        ),
        TestFixtures.createWorkout(
          id: 'w3',
          status: WorkoutStatus.skipped,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          workoutsProvider.overrideWithValue(AsyncValue.data(workouts)),
        ],
      );
      addTearDown(container.dispose);

      final completed = container.read(completedWorkoutsProvider);
      expect(completed.length, 1);
      expect(completed.first.status, WorkoutStatus.completed);
      expect(completed.first.id, 'w1');
    });

    test('returns empty list when no completed workouts', () {
      final workouts = [
        TestFixtures.createWorkout(
          id: 'w1',
          status: WorkoutStatus.incomplete,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          workoutsProvider.overrideWithValue(AsyncValue.data(workouts)),
        ],
      );
      addTearDown(container.dispose);

      final completed = container.read(completedWorkoutsProvider);
      expect(completed, isEmpty);
    });

    test('returns empty list on error', () {
      final container = ProviderContainer(
        overrides: [
          workoutsProvider.overrideWithValue(
            AsyncValue.error(Exception('db error'), StackTrace.current),
          ),
        ],
      );
      addTearDown(container.dispose);

      final completed = container.read(completedWorkoutsProvider);
      expect(completed, isEmpty);
    });

    test('returns empty list while loading', () {
      final container = ProviderContainer(
        overrides: [
          workoutsProvider.overrideWithValue(const AsyncValue.loading()),
        ],
      );
      addTearDown(container.dispose);

      final completed = container.read(completedWorkoutsProvider);
      expect(completed, isEmpty);
    });
  });

  group('workoutProvider', () {
    test('returns specific workout by id', () {
      final workouts = [
        TestFixtures.createWorkout(id: 'w1', label: 'Chest'),
        TestFixtures.createWorkout(id: 'w2', label: 'Back'),
      ];

      final container = ProviderContainer(
        overrides: [
          workoutsProvider.overrideWithValue(AsyncValue.data(workouts)),
        ],
      );
      addTearDown(container.dispose);

      final workout = container.read(workoutProvider('w1'));
      expect(workout, isNotNull);
      expect(workout!.label, 'Chest');
    });

    test('returns null for non-existent id', () {
      final container = ProviderContainer(
        overrides: [
          workoutsProvider.overrideWithValue(
            const AsyncValue.data(<Workout>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final workout = container.read(workoutProvider('non-existent'));
      expect(workout, isNull);
    });

    test('returns null while loading', () {
      final container = ProviderContainer(
        overrides: [
          workoutsProvider.overrideWithValue(const AsyncValue.loading()),
        ],
      );
      addTearDown(container.dispose);

      final workout = container.read(workoutProvider('w1'));
      expect(workout, isNull);
    });
  });

  group('workoutsByTrainingCycleListProvider', () {
    // Phase 6b/6c: this list provider reads from
    // [sessionsByTrainingCycleProvider] and filters to StrengthSession.
    // Because that upstream is `StreamProvider.autoDispose.family`, we
    // hold an explicit `container.listen(...)` subscription while the
    // stream settles — otherwise a bare `.read` races with autoDispose.
    test('returns list from stream data', () async {
      final cycleId = 'cycle-1';
      final sessions = <Session>[
        StrengthSession(
          id: 'w1',
          trainingCycleId: cycleId,
          source: SessionSource.userLogged,
          status: WorkoutStatus.incomplete,
          periodNumber: 1,
          dayNumber: 1,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          sessionsByTrainingCycleProvider(cycleId).overrideWith(
            (ref) => Stream<List<Session>>.value(sessions),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Keep a live subscription so autoDispose doesn't kill the
      // provider while we wait for its first emission.
      final sub = container.listen(
        sessionsByTrainingCycleProvider(cycleId),
        (_, _) {},
      );
      addTearDown(sub.close);

      await container.read(sessionsByTrainingCycleProvider(cycleId).future);

      final list = container.read(
        workoutsByTrainingCycleListProvider(cycleId),
      );
      expect(list.length, 1);
    });

    test('returns empty list while loading', () {
      final container = ProviderContainer(
        overrides: [
          sessionsByTrainingCycleProvider('x').overrideWith(
            // A never-completing stream keeps the provider in loading state.
            (ref) => const Stream<List<Session>>.empty(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(
        sessionsByTrainingCycleProvider('x'),
        (_, _) {},
      );
      addTearDown(sub.close);

      final list = container.read(
        workoutsByTrainingCycleListProvider('x'),
      );
      expect(list, isEmpty);
    });

    test('returns empty list on error', () async {
      final container = ProviderContainer(
        overrides: [
          sessionsByTrainingCycleProvider('x').overrideWith(
            (ref) => Stream<List<Session>>.error(Exception('err')),
          ),
        ],
      );
      addTearDown(container.dispose);

      // `container.listen` with an onError swallows the stream error so
      // the test runner's zone doesn't flag it as uncaught. We don't
      // await `.future` — that races with autoDispose on error streams —
      // and instead just pump a microtask before reading the derived
      // provider synchronously.
      final sub = container.listen(
        sessionsByTrainingCycleProvider('x'),
        (_, _) {},
        onError: (_, _) {},
      );
      addTearDown(sub.close);

      await Future<void>.delayed(Duration.zero);

      final list = container.read(
        workoutsByTrainingCycleListProvider('x'),
      );
      expect(list, isEmpty);
    });
  });

  group('ShowExerciseHistoryNotifier', () {
    test('defaults to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final show = container.read(showExerciseHistoryProvider);
      expect(show, true);
    });

    test('toggle changes value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(showExerciseHistoryProvider.notifier).toggle();
      expect(container.read(showExerciseHistoryProvider), false);

      container.read(showExerciseHistoryProvider.notifier).toggle();
      expect(container.read(showExerciseHistoryProvider), true);
    });

    test('multiple toggles cycle correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(showExerciseHistoryProvider), true);

      for (var i = 0; i < 5; i++) {
        container.read(showExerciseHistoryProvider.notifier).toggle();
      }
      // 5 toggles from true -> false
      expect(container.read(showExerciseHistoryProvider), false);
    });
  });
}
