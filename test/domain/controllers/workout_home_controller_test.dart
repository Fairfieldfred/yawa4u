import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/models/training_cycle.dart';
import 'package:yawa4u/data/models/workout.dart';
import 'package:yawa4u/data/repositories/training_cycle_repository.dart';
import 'package:yawa4u/data/repositories/workout_repository.dart';
import 'package:yawa4u/domain/controllers/workout_home_controller.dart';
import 'package:yawa4u/domain/providers/database_providers.dart';
import 'package:yawa4u/domain/providers/training_cycle_providers.dart';
import 'package:yawa4u/domain/providers/use_case_providers.dart';
import 'package:yawa4u/domain/use_cases/end_training_cycle_use_case.dart';
import 'package:yawa4u/domain/use_cases/finish_workout_use_case.dart';
import 'package:yawa4u/domain/use_cases/reset_workout_use_case.dart';

import '../../helpers/test_fixtures.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class MockTrainingCycleRepository extends Mock implements TrainingCycleRepository {}

class MockFinishWorkoutUseCase extends Mock implements FinishWorkoutUseCase {}

class MockResetWorkoutUseCase extends Mock implements ResetWorkoutUseCase {}

class MockEndTrainingCycleUseCase extends Mock implements EndTrainingCycleUseCase {}

class FakeWorkout extends Fake implements Workout {}

class FakeTrainingCycle extends Fake implements TrainingCycle {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeWorkout());
    registerFallbackValue(FakeTrainingCycle());
  });
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

  // ---------------------------------------------------------------------------
  // Controller method tests (via ProviderContainer with mocked dependencies)
  // ---------------------------------------------------------------------------

  group('WorkoutHomeController - UI state', () {
    late ProviderContainer container;
    late MockWorkoutRepository mockWorkoutRepo;

    setUp(() {
      mockWorkoutRepo = MockWorkoutRepository();
      container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(mockWorkoutRepo),
        ],
      );
      // Force initialization of the controller
      container.read(workoutHomeControllerProvider);
    });

    tearDown(() => container.dispose());

    test('togglePeriodSelector toggles the flag', () {
      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );

      controller.togglePeriodSelector();
      expect(
        container.read(workoutHomeControllerProvider).showPeriodSelector,
        true,
      );

      controller.togglePeriodSelector();
      expect(
        container.read(workoutHomeControllerProvider).showPeriodSelector,
        false,
      );
    });

    test('hidePeriodSelector sets flag to false', () {
      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );

      controller.togglePeriodSelector(); // show
      controller.hidePeriodSelector();
      expect(
        container.read(workoutHomeControllerProvider).showPeriodSelector,
        false,
      );
    });

    test('selectDay sets period/day and hides selector', () {
      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );

      controller.togglePeriodSelector(); // show
      controller.selectDay(2, 3);

      final state = container.read(workoutHomeControllerProvider);
      expect(state.selectedPeriod, 2);
      expect(state.selectedDay, 3);
      expect(state.showPeriodSelector, false);
    });

    test('navigateToNextDay updates period and day', () {
      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );

      controller.navigateToNextDay(3, 4);

      final state = container.read(workoutHomeControllerProvider);
      expect(state.selectedPeriod, 3);
      expect(state.selectedDay, 4);
    });
  });

  group('WorkoutHomeController - set operations', () {
    late ProviderContainer container;
    late MockWorkoutRepository mockWorkoutRepo;

    final exercise = TestFixtures.createExercise(
      id: 'ex-1',
      workoutId: 'w-1',
      sets: [
        TestFixtures.createExerciseSet(
          id: 's-1',
          setNumber: 1,
          weight: 100,
          reps: '10',
        ),
        TestFixtures.createExerciseSet(
          id: 's-2',
          setNumber: 2,
          weight: 80,
          reps: '12',
        ),
      ],
    );
    final workout = TestFixtures.createWorkout(
      id: 'w-1',
      exercises: [exercise],
    );

    setUp(() {
      mockWorkoutRepo = MockWorkoutRepository();
      container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(mockWorkoutRepo),
        ],
      );
      container.read(workoutHomeControllerProvider);
    });

    tearDown(() => container.dispose());

    test('updateSetWeight updates weight on a valid value', () async {
      when(() => mockWorkoutRepo.getById('w-1')).thenAnswer((_) async => workout);
      when(() => mockWorkoutRepo.update(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.updateSetWeight('w-1', 'ex-1', 0, '120');

      final captured = verify(() => mockWorkoutRepo.update(captureAny())).captured;
      final updated = captured.first as Workout;
      expect(updated.exercises.first.sets[0].weight, 120.0);
    });

    test('updateSetWeight is no-op for non-numeric non-empty value', () async {
      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.updateSetWeight('w-1', 'ex-1', 0, 'abc');

      verifyNever(() => mockWorkoutRepo.getById(any()));
    });

    test('toggleSetLog toggles isLogged', () async {
      when(() => mockWorkoutRepo.getById('w-1')).thenAnswer((_) async => workout);
      when(() => mockWorkoutRepo.update(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.toggleSetLog('w-1', 'ex-1', 0);

      final captured = verify(() => mockWorkoutRepo.update(captureAny())).captured;
      final updated = captured.first as Workout;
      expect(updated.exercises.first.sets[0].isLogged, true);
    });

    test('toggleSetLog no-op when weight is null', () async {
      final noWeightExercise = TestFixtures.createExercise(
        id: 'ex-1',
        workoutId: 'w-1',
        sets: [
          TestFixtures.createExerciseSet(
            id: 's-1',
            setNumber: 1,
            weight: null,
            reps: '10',
          ),
        ],
      );
      final noWeightWorkout = TestFixtures.createWorkout(
        id: 'w-1',
        exercises: [noWeightExercise],
      );
      when(() => mockWorkoutRepo.getById('w-1')).thenAnswer((_) async => noWeightWorkout);

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.toggleSetLog('w-1', 'ex-1', 0);

      verifyNever(() => mockWorkoutRepo.update(any()));
    });

    test('addSetBelow inserts a set and renumbers', () async {
      when(() => mockWorkoutRepo.getById('w-1')).thenAnswer((_) async => workout);
      when(() => mockWorkoutRepo.update(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.addSetBelow('w-1', 'ex-1', 0);

      final captured = verify(() => mockWorkoutRepo.update(captureAny())).captured;
      final updated = captured.first as Workout;
      final sets = updated.exercises.first.sets;
      expect(sets.length, 3);
      expect(sets[0].setNumber, 1);
      expect(sets[1].setNumber, 2); // new set
      expect(sets[2].setNumber, 3); // old set 2, renumbered
    });

    test('deleteSet removes and renumbers', () async {
      when(() => mockWorkoutRepo.getById('w-1')).thenAnswer((_) async => workout);
      when(() => mockWorkoutRepo.update(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.deleteSet('w-1', 'ex-1', 0);

      final captured = verify(() => mockWorkoutRepo.update(captureAny())).captured;
      final updated = captured.first as Workout;
      final sets = updated.exercises.first.sets;
      expect(sets.length, 1);
      expect(sets[0].setNumber, 1);
      expect(sets[0].id, 's-2');
    });

    test('updateSetType changes type', () async {
      when(() => mockWorkoutRepo.getById('w-1')).thenAnswer((_) async => workout);
      when(() => mockWorkoutRepo.update(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.updateSetType('w-1', 'ex-1', 0, SetType.dropSet);

      final captured = verify(() => mockWorkoutRepo.update(captureAny())).captured;
      final updated = captured.first as Workout;
      expect(updated.exercises.first.sets[0].setType, SetType.dropSet);
    });
  });

  group('WorkoutHomeController - exercise operations', () {
    late ProviderContainer container;
    late MockWorkoutRepository mockWorkoutRepo;

    final exercise = TestFixtures.createExercise(
      id: 'ex-1',
      workoutId: 'w-1',
      sets: [
        TestFixtures.createExerciseSet(
          id: 's-1',
          setNumber: 1,
          weight: 100,
          reps: '10',
          isLogged: true,
        ),
        TestFixtures.createExerciseSet(
          id: 's-2',
          setNumber: 2,
          weight: 80,
          reps: '8',
        ),
      ],
    );
    final workout = TestFixtures.createWorkout(
      id: 'w-1',
      exercises: [exercise],
    );

    setUp(() {
      mockWorkoutRepo = MockWorkoutRepository();
      container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(mockWorkoutRepo),
        ],
      );
      container.read(workoutHomeControllerProvider);
    });

    tearDown(() => container.dispose());

    test('deleteExercise removes exercise from workout', () async {
      when(() => mockWorkoutRepo.getById('w-1')).thenAnswer((_) async => workout);
      when(() => mockWorkoutRepo.update(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.deleteExercise('w-1', 'ex-1');

      final captured = verify(() => mockWorkoutRepo.update(captureAny())).captured;
      final updated = captured.first as Workout;
      expect(updated.exercises, isEmpty);
    });

    test('skipExerciseSets marks unlogged sets as skipped', () async {
      when(() => mockWorkoutRepo.getById('w-1')).thenAnswer((_) async => workout);
      when(() => mockWorkoutRepo.update(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.skipExerciseSets('w-1', 'ex-1');

      final captured = verify(() => mockWorkoutRepo.update(captureAny())).captured;
      final updated = captured.first as Workout;
      final sets = updated.exercises.first.sets;
      // s-1 was already logged — should stay logged, not skipped
      expect(sets[0].isLogged, true);
      expect(sets[0].isSkipped, false);
      // s-2 was not logged — should be skipped
      expect(sets[1].isSkipped, true);
    });

    test('updateExerciseNote sets the note', () async {
      when(() => mockWorkoutRepo.getById('w-1')).thenAnswer((_) async => workout);
      when(() => mockWorkoutRepo.update(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.updateExerciseNote('w-1', 'ex-1', 'Go heavier');

      final captured = verify(() => mockWorkoutRepo.update(captureAny())).captured;
      final updated = captured.first as Workout;
      expect(updated.exercises.first.notes, 'Go heavier');
    });
  });

  group('WorkoutHomeController - workout operations', () {
    late ProviderContainer container;
    late MockWorkoutRepository mockWorkoutRepo;
    late MockFinishWorkoutUseCase mockFinishUseCase;
    late MockResetWorkoutUseCase mockResetUseCase;

    setUp(() {
      mockWorkoutRepo = MockWorkoutRepository();
      mockFinishUseCase = MockFinishWorkoutUseCase();
      mockResetUseCase = MockResetWorkoutUseCase();
      container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(mockWorkoutRepo),
          finishWorkoutUseCaseProvider.overrideWithValue(mockFinishUseCase),
          resetWorkoutUseCaseProvider.overrideWithValue(mockResetUseCase),
          currentTrainingCycleProvider.overrideWith(
            (ref) => TestFixtures.createTrainingCycle(
              id: 'tc-1',
              status: TrainingCycleStatus.current,
            ),
          ),
        ],
      );
      container.read(workoutHomeControllerProvider);
    });

    tearDown(() => container.dispose());

    test('finishWorkout returns false for empty workouts', () async {
      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      final result = await controller.finishWorkout([], 5);
      expect(result, false);
    });

    test('finishWorkout navigates to next day on success', () async {
      final workouts = [
        TestFixtures.createWorkout(
          id: 'w-1',
          periodNumber: 1,
          dayNumber: 2,
        ),
      ];
      when(
        () => mockFinishUseCase.execute(
          workouts: any(named: 'workouts'),
          daysPerPeriod: any(named: 'daysPerPeriod'),
          trainingCycleId: any(named: 'trainingCycleId'),
        ),
      ).thenAnswer(
        (_) async => const FinishWorkoutResult(
          cycleCompleted: false,
          nextPeriod: 1,
          nextDay: 3,
        ),
      );

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      final result = await controller.finishWorkout(workouts, 5);

      expect(result, false);
      final state = container.read(workoutHomeControllerProvider);
      expect(state.selectedPeriod, 1);
      expect(state.selectedDay, 3);
    });

    test('finishWorkout returns true when cycle completes', () async {
      final workouts = [TestFixtures.createWorkout(id: 'w-1')];
      when(
        () => mockFinishUseCase.execute(
          workouts: any(named: 'workouts'),
          daysPerPeriod: any(named: 'daysPerPeriod'),
          trainingCycleId: any(named: 'trainingCycleId'),
        ),
      ).thenAnswer(
        (_) async => const FinishWorkoutResult(cycleCompleted: true),
      );

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      final result = await controller.finishWorkout(workouts, 5);
      expect(result, true);
    });

    test('resetWorkout delegates to use case', () async {
      final workouts = [TestFixtures.createWorkout(id: 'w-1')];
      when(() => mockResetUseCase.execute(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.resetWorkout(workouts);

      verify(() => mockResetUseCase.execute(workouts)).called(1);
    });
  });

  group('WorkoutHomeController - cycle operations', () {
    late ProviderContainer container;
    late MockWorkoutRepository mockWorkoutRepo;
    late MockTrainingCycleRepository mockCycleRepo;
    late MockEndTrainingCycleUseCase mockEndUseCase;

    setUp(() {
      mockWorkoutRepo = MockWorkoutRepository();
      mockCycleRepo = MockTrainingCycleRepository();
      mockEndUseCase = MockEndTrainingCycleUseCase();
      container = ProviderContainer(
        overrides: [
          workoutRepositoryProvider.overrideWithValue(mockWorkoutRepo),
          trainingCycleRepositoryProvider.overrideWithValue(mockCycleRepo),
          endTrainingCycleUseCaseProvider.overrideWithValue(mockEndUseCase),
        ],
      );
      container.read(workoutHomeControllerProvider);
    });

    tearDown(() => container.dispose());

    test('renameTrainingCycle updates cycle name', () async {
      final cycle = TestFixtures.createTrainingCycle(
        id: 'tc-1',
        name: 'Old Name',
      );
      when(() => mockCycleRepo.update(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.renameTrainingCycle(cycle, 'New Name');

      final captured = verify(() => mockCycleRepo.update(captureAny())).captured;
      final updated = captured.first as TrainingCycle;
      expect(updated.name, 'New Name');
    });

    test('endTrainingCycle delegates to use case', () async {
      final cycle = TestFixtures.createTrainingCycle(id: 'tc-1');
      when(() => mockEndUseCase.execute(any())).thenAnswer((_) async {});

      final controller = container.read(
        workoutHomeControllerProvider.notifier,
      );
      await controller.endTrainingCycle(cycle);

      verify(() => mockEndUseCase.execute(cycle)).called(1);
    });
  });
}
