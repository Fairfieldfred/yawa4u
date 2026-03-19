import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/domain/controllers/workout_home_controller.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  group('WorkoutHomeState', () {
    test('default state has period selector hidden and no selection', () {
      const state = WorkoutHomeState();
      expect(state.showPeriodSelector, false);
      expect(state.selectedPeriod, isNull);
      expect(state.selectedDay, isNull);
    });

    test('copyWith preserves values when no overrides given', () {
      const state = WorkoutHomeState(
        showPeriodSelector: true,
        selectedPeriod: 2,
        selectedDay: 3,
      );
      final copy = state.copyWith();
      expect(copy.showPeriodSelector, true);
      expect(copy.selectedPeriod, 2);
      expect(copy.selectedDay, 3);
    });

    test('copyWith with clearSelection nulls period and day', () {
      const state = WorkoutHomeState(
        selectedPeriod: 2,
        selectedDay: 3,
      );
      final cleared = state.copyWith(clearSelection: true);
      expect(cleared.selectedPeriod, isNull);
      expect(cleared.selectedDay, isNull);
    });
  });

  group('findFirstIncompleteWorkout', () {
    test('returns null for empty list', () {
      expect(findFirstIncompleteWorkout([]), isNull);
    });

    test('returns null when all sets are logged', () {
      final workout = TestFixtures.createWorkout(
        periodNumber: 1,
        dayNumber: 1,
        exercises: [
          TestFixtures.createExercise(
            sets: [
              TestFixtures.createExerciseSet(isLogged: true),
            ],
          ),
        ],
      );
      expect(findFirstIncompleteWorkout([workout]), isNull);
    });

    test('returns null when all sets are skipped', () {
      final workout = TestFixtures.createWorkout(
        periodNumber: 1,
        dayNumber: 1,
        exercises: [
          TestFixtures.createExercise(
            sets: [
              TestFixtures.createExerciseSet(isSkipped: true),
            ],
          ),
        ],
      );
      expect(findFirstIncompleteWorkout([workout]), isNull);
    });

    test('returns first incomplete day', () {
      final w1 = TestFixtures.createWorkout(
        periodNumber: 1,
        dayNumber: 1,
        exercises: [
          TestFixtures.createExercise(
            sets: [TestFixtures.createExerciseSet(isLogged: true)],
          ),
        ],
      );
      final w2 = TestFixtures.createWorkout(
        periodNumber: 1,
        dayNumber: 2,
        exercises: [
          TestFixtures.createExercise(
            sets: [TestFixtures.createExerciseSet()], // not logged
          ),
        ],
      );
      final result = findFirstIncompleteWorkout([w1, w2]);
      expect(result, (1, 2));
    });

    test('handles multiple workouts per day', () {
      final w1 = TestFixtures.createWorkout(
        periodNumber: 1,
        dayNumber: 1,
        label: 'Chest',
        exercises: [
          TestFixtures.createExercise(
            sets: [TestFixtures.createExerciseSet(isLogged: true)],
          ),
        ],
      );
      final w2 = TestFixtures.createWorkout(
        periodNumber: 1,
        dayNumber: 1,
        label: 'Triceps',
        exercises: [
          TestFixtures.createExercise(
            sets: [TestFixtures.createExerciseSet()], // not logged
          ),
        ],
      );
      // Day 1 is incomplete because w2 has unlogged sets
      final result = findFirstIncompleteWorkout([w1, w2]);
      expect(result, (1, 1));
    });

    test('returns correct day across periods', () {
      final w1 = TestFixtures.createWorkout(
        periodNumber: 1,
        dayNumber: 1,
        exercises: [
          TestFixtures.createExercise(
            sets: [TestFixtures.createExerciseSet(isLogged: true)],
          ),
        ],
      );
      final w2 = TestFixtures.createWorkout(
        periodNumber: 2,
        dayNumber: 3,
        exercises: [
          TestFixtures.createExercise(
            sets: [TestFixtures.createExerciseSet()],
          ),
        ],
      );
      final result = findFirstIncompleteWorkout([w2, w1]); // unordered input
      expect(result, (2, 3));
    });
  });

  group('isWorkoutComplete', () {
    test('returns true for empty exercises', () {
      final workout = TestFixtures.createWorkout(exercises: []);
      expect(isWorkoutComplete(workout), true);
    });

    test('returns true when all sets logged', () {
      final workout = TestFixtures.createWorkout(
        exercises: [
          TestFixtures.createExercise(
            sets: [
              TestFixtures.createExerciseSet(isLogged: true),
              TestFixtures.createExerciseSet(isLogged: true),
            ],
          ),
        ],
      );
      expect(isWorkoutComplete(workout), true);
    });

    test('returns true when all sets logged or skipped', () {
      final workout = TestFixtures.createWorkout(
        exercises: [
          TestFixtures.createExercise(
            sets: [
              TestFixtures.createExerciseSet(isLogged: true),
              TestFixtures.createExerciseSet(isSkipped: true),
            ],
          ),
        ],
      );
      expect(isWorkoutComplete(workout), true);
    });

    test('returns false when a set is neither logged nor skipped', () {
      final workout = TestFixtures.createWorkout(
        exercises: [
          TestFixtures.createExercise(
            sets: [
              TestFixtures.createExerciseSet(isLogged: true),
              TestFixtures.createExerciseSet(), // not logged, not skipped
            ],
          ),
        ],
      );
      expect(isWorkoutComplete(workout), false);
    });
  });

  group('calculateRIR', () {
    test('recovery period returns 8', () {
      expect(calculateRIR(5, 5), 8);
    });

    test('period before recovery returns 0', () {
      expect(calculateRIR(4, 5), 0);
    });

    test('two periods before recovery returns 1', () {
      expect(calculateRIR(3, 5), 1);
    });

    test('three periods before recovery returns 2', () {
      expect(calculateRIR(2, 5), 2);
    });

    test('four periods before recovery returns 3', () {
      expect(calculateRIR(1, 5), 3);
    });

    test('period after recovery returns 0', () {
      expect(calculateRIR(6, 5), 0);
    });
  });

  group('getSetTypeBadge', () {
    test('regular returns null', () {
      expect(getSetTypeBadge(SetType.regular), isNull);
    });

    test('myorep returns M', () {
      expect(getSetTypeBadge(SetType.myorep), 'M');
    });

    test('myorepMatch returns MM', () {
      expect(getSetTypeBadge(SetType.myorepMatch), 'MM');
    });

    test('maxReps returns MX', () {
      expect(getSetTypeBadge(SetType.maxReps), 'MX');
    });

    test('endWithPartials returns EP', () {
      expect(getSetTypeBadge(SetType.endWithPartials), 'EP');
    });

    test('dropSet returns DS', () {
      expect(getSetTypeBadge(SetType.dropSet), 'DS');
    });
  });

  group('calculateDayName', () {
    test('returns dayName from workout if available', () {
      final workout = TestFixtures.createWorkout(dayName: 'Push Day');
      final result = calculateDayName(
        workouts: [workout],
        startDate: DateTime(2024, 1, 1),
        daysPerPeriod: 5,
        displayPeriod: 1,
        displayDay: 1,
      );
      expect(result, 'PUS');
    });

    test('calculates from start date when no dayName', () {
      final workout = TestFixtures.createWorkout(dayName: null);
      // Jan 1 2024 is a Monday (weekday=1, %7=1)
      final result = calculateDayName(
        workouts: [workout],
        startDate: DateTime(2024, 1, 1),
        daysPerPeriod: 5,
        displayPeriod: 1,
        displayDay: 1,
      );
      expect(result, 'MON');
    });

    test('returns default day name when no start date and no dayName', () {
      final workout = TestFixtures.createWorkout(dayName: null);
      final result = calculateDayName(
        workouts: [workout],
        startDate: null,
        daysPerPeriod: 5,
        displayPeriod: 1,
        displayDay: 1,
      );
      expect(result, 'SUN');
    });

    test('returns DAY X for high day numbers without start date', () {
      final workout = TestFixtures.createWorkout(dayName: null);
      final result = calculateDayName(
        workouts: [workout],
        startDate: null,
        daysPerPeriod: 10,
        displayPeriod: 1,
        displayDay: 8,
      );
      expect(result, 'DAY 8');
    });
  });
}
