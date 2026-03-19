import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/models/workout.dart';
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
    test('returns list from stream data', () {
      final cycleId = 'cycle-1';
      final workouts = [
        TestFixtures.createWorkout(id: 'w1', trainingCycleId: cycleId),
      ];

      final container = ProviderContainer(
        overrides: [
          workoutsByTrainingCycleProvider(cycleId).overrideWithValue(
            AsyncValue.data(workouts),
          ),
        ],
      );
      addTearDown(container.dispose);

      final list = container.read(
        workoutsByTrainingCycleListProvider(cycleId),
      );
      expect(list.length, 1);
    });

    test('returns empty list while loading', () {
      final container = ProviderContainer(
        overrides: [
          workoutsByTrainingCycleProvider('x').overrideWithValue(
            const AsyncValue.loading(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final list = container.read(
        workoutsByTrainingCycleListProvider('x'),
      );
      expect(list, isEmpty);
    });

    test('returns empty list on error', () {
      final container = ProviderContainer(
        overrides: [
          workoutsByTrainingCycleProvider('x').overrideWithValue(
            AsyncValue.error(Exception('err'), StackTrace.current),
          ),
        ],
      );
      addTearDown(container.dispose);

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
