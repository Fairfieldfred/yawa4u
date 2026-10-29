import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/core/utils/day_exercise_order.dart';
import 'package:yawa4u/data/models/workout.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  // A template day that alternates Chest, Back, Chest, Back, stored as one workout per muscle group.
  List<Workout> alternatingDay() => [
    TestFixtures.createWorkout(
      id: 'chest',
      exercises: [
        TestFixtures.createExercise(id: 'bench', workoutId: 'chest', orderIndex: 0),
        TestFixtures.createExercise(id: 'fly', workoutId: 'chest', orderIndex: 2),
      ],
    ),
    TestFixtures.createWorkout(
      id: 'back',
      label: 'Back',
      exercises: [
        TestFixtures.createExercise(id: 'row', workoutId: 'back', muscleGroup: MuscleGroup.back, orderIndex: 1),
        TestFixtures.createExercise(id: 'pullup', workoutId: 'back', muscleGroup: MuscleGroup.back, orderIndex: 3),
      ],
    ),
  ];

  // Pre-change data: each workout numbered from 0, so indices collide across workouts.
  List<Workout> legacyDay() => [
    TestFixtures.createWorkout(
      id: 'chest',
      exercises: [
        TestFixtures.createExercise(id: 'bench', workoutId: 'chest', orderIndex: 0),
        TestFixtures.createExercise(id: 'fly', workoutId: 'chest', orderIndex: 1),
      ],
    ),
    TestFixtures.createWorkout(
      id: 'back',
      label: 'Back',
      exercises: [
        TestFixtures.createExercise(id: 'row', workoutId: 'back', muscleGroup: MuscleGroup.back, orderIndex: 0),
      ],
    ),
  ];

  List<String> ids(Iterable<dynamic> exercises) => [for (final e in exercises) e.id as String];

  group('orderedDayExercises', () {
    test('follows the day-wide orderIndex across muscle-group workouts', () {
      expect(ids(orderedDayExercises(alternatingDay())), ['bench', 'row', 'fly', 'pullup']);
    });

    test('keeps legacy workout-by-workout order when indices collide', () {
      expect(ids(orderedDayExercises(legacyDay())), ['bench', 'fly', 'row']);
    });
  });

  group('moveDayExercise', () {
    test('swaps with the neighbour across muscle groups', () {
      final ordered = orderedDayExercises(alternatingDay());
      expect(ids(moveDayExercise(ordered, 'row', -1)!), ['row', 'bench', 'fly', 'pullup']);
      expect(ids(moveDayExercise(ordered, 'row', 1)!), ['bench', 'fly', 'row', 'pullup']);
    });

    test('returns null at either end or for an unknown exercise', () {
      final ordered = orderedDayExercises(alternatingDay());
      expect(moveDayExercise(ordered, 'bench', -1), isNull);
      expect(moveDayExercise(ordered, 'pullup', 1), isNull);
      expect(moveDayExercise(ordered, 'missing', 1), isNull);
    });
  });

  group('renumberDayExercises', () {
    test('writes day-wide positions, keeps each exercise in its workout, returns only changed workouts', () {
      final day = alternatingDay();
      final moved = moveDayExercise(orderedDayExercises(day), 'pullup', -1)!; // bench, row, pullup, fly

      final changed = renumberDayExercises(day, moved);
      final byId = {for (final w in changed) w.id: w};

      expect(byId['chest']!.exercises.map((e) => (e.id, e.orderIndex)), [('bench', 0), ('fly', 3)]);
      expect(byId['back']!.exercises.map((e) => (e.id, e.orderIndex)), [('row', 1), ('pullup', 2)]);
      expect(ids(orderedDayExercises(changed)), ['bench', 'row', 'pullup', 'fly']);
    });

    test('migrates a legacy day to unique day-wide indices', () {
      final day = legacyDay();
      final changed = {for (final w in renumberDayExercises(day, orderedDayExercises(day))) w.id: w};
      final stored = [for (final w in day) changed[w.id] ?? w];

      final indices = [for (final w in stored) ...w.exercises.map((e) => e.orderIndex)];
      expect(indices.toSet().length, 3);
      expect(ids(orderedDayExercises(stored)), ['bench', 'fly', 'row']);
    });

    test('returns nothing when the order is already stored', () {
      final day = alternatingDay();
      expect(renumberDayExercises(day, orderedDayExercises(day)), isEmpty);
    });
  });

  test('nextDayOrderIndex is one past the highest index, optionally ignoring an exercise', () {
    expect(nextDayOrderIndex(alternatingDay()), 4);
    expect(nextDayOrderIndex(alternatingDay(), excludingExerciseId: 'pullup'), 3);
    expect(nextDayOrderIndex(const []), 0);
  });
}
