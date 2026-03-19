import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/training_cycle_repository.dart';
import 'package:yawa4u/data/repositories/workout_repository.dart';
import 'package:yawa4u/domain/use_cases/add_exercise_set_use_case.dart';
import 'package:yawa4u/domain/use_cases/end_training_cycle_use_case.dart';
import 'package:yawa4u/domain/use_cases/finish_workout_use_case.dart';
import 'package:yawa4u/domain/use_cases/reset_workout_use_case.dart';
import 'package:yawa4u/domain/use_cases/skip_workout_use_case.dart';
import 'package:yawa4u/domain/use_cases/start_training_cycle_use_case.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository workoutRepo;
  late TrainingCycleRepository cycleRepo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    workoutRepo = WorkoutRepository(
      db.workoutDao,
      db.exerciseDao,
      db.exerciseSetDao,
    );
    cycleRepo = TrainingCycleRepository(db.trainingCycleDao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertTrainingCycle(String uuid, {
    TrainingCycleStatus status = TrainingCycleStatus.draft,
  }) async {
    await db.trainingCycleDao.insertCycle(
      TrainingCyclesCompanion.insert(
        uuid: uuid,
        name: 'Test Cycle',
        periodsTotal: 4,
        daysPerPeriod: 5,
        recoveryPeriod: 4,
        status: status.index,
        createdDate: DateTime.now(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FinishWorkoutUseCase
  // ---------------------------------------------------------------------------
  group('FinishWorkoutUseCase', () {
    late FinishWorkoutUseCase useCase;

    setUp(() {
      useCase = FinishWorkoutUseCase(workoutRepo, cycleRepo);
    });

    test('returns null for empty workouts list', () async {
      final result = await useCase.execute(
        workouts: [],
        daysPerPeriod: 5,
        trainingCycleId: 'cycle-1',
      );
      expect(result, isNull);
    });

    test('marks all workouts as completed', () async {
      const cycleId = 'cycle-finish-1';
      await insertTrainingCycle(cycleId);

      final w1 = TestFixtures.createWorkout(
        id: 'fw1',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 1,
        label: 'Chest',
      );
      final w2 = TestFixtures.createWorkout(
        id: 'fw2',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 1,
        label: 'Triceps',
      );
      // Add another day so cycle isn't complete
      final w3 = TestFixtures.createWorkout(
        id: 'fw3',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 2,
        label: 'Back',
      );

      await workoutRepo.create(w1);
      await workoutRepo.create(w2);
      await workoutRepo.create(w3);

      final result = await useCase.execute(
        workouts: [w1, w2],
        daysPerPeriod: 5,
        trainingCycleId: cycleId,
      );

      expect(result, isNotNull);
      expect(result!.cycleCompleted, false);
      expect(result.nextPeriod, 1);
      expect(result.nextDay, 2);

      // Verify workouts are marked completed
      final fetched1 = await workoutRepo.getById('fw1');
      final fetched2 = await workoutRepo.getById('fw2');
      expect(fetched1!.status, WorkoutStatus.completed);
      expect(fetched2!.status, WorkoutStatus.completed);
      expect(fetched1.completedDate, isNotNull);
    });

    test('completes cycle when all workouts done', () async {
      const cycleId = 'cycle-finish-all';
      await insertTrainingCycle(cycleId, status: TrainingCycleStatus.current);

      final w1 = TestFixtures.createWorkout(
        id: 'fwa1',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 1,
        label: 'Chest',
      );

      await workoutRepo.create(w1);

      final result = await useCase.execute(
        workouts: [w1],
        daysPerPeriod: 5,
        trainingCycleId: cycleId,
      );

      expect(result!.cycleCompleted, true);

      final cycle = await cycleRepo.getById(cycleId);
      expect(cycle!.status, TrainingCycleStatus.completed);
    });

    test('wraps to next period when day exceeds daysPerPeriod', () async {
      const cycleId = 'cycle-finish-wrap';
      await insertTrainingCycle(cycleId);

      final w1 = TestFixtures.createWorkout(
        id: 'fww1',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 3, // Last day (daysPerPeriod=3)
        label: 'Chest',
      );
      // Need another workout so cycle isn't complete
      final w2 = TestFixtures.createWorkout(
        id: 'fww2',
        trainingCycleId: cycleId,
        periodNumber: 2,
        dayNumber: 1,
        label: 'Back',
      );

      await workoutRepo.create(w1);
      await workoutRepo.create(w2);

      final result = await useCase.execute(
        workouts: [w1],
        daysPerPeriod: 3,
        trainingCycleId: cycleId,
      );

      expect(result!.cycleCompleted, false);
      expect(result.nextPeriod, 2);
      expect(result.nextDay, 1);
    });
  });

  // ---------------------------------------------------------------------------
  // SkipWorkoutUseCase
  // ---------------------------------------------------------------------------
  group('SkipWorkoutUseCase', () {
    late SkipWorkoutUseCase useCase;

    setUp(() {
      useCase = SkipWorkoutUseCase(workoutRepo);
    });

    test('marks workout as skipped', () async {
      const cycleId = 'cycle-skip-1';
      await insertTrainingCycle(cycleId);

      final workout = TestFixtures.createWorkout(
        id: 'sw1',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 1,
      );
      await workoutRepo.create(workout);

      await useCase.execute('sw1');

      final fetched = await workoutRepo.getById('sw1');
      expect(fetched!.status, WorkoutStatus.skipped);
    });
  });

  // ---------------------------------------------------------------------------
  // ResetWorkoutUseCase
  // ---------------------------------------------------------------------------
  group('ResetWorkoutUseCase', () {
    late ResetWorkoutUseCase useCase;

    setUp(() {
      useCase = ResetWorkoutUseCase(workoutRepo);
    });

    test('resets all sets to unlogged and clears weight/reps', () async {
      const cycleId = 'cycle-reset-1';
      await insertTrainingCycle(cycleId);

      final workout = TestFixtures.createWorkout(
        id: 'rw1',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 1,
        status: WorkoutStatus.completed,
        completedDate: DateTime.now(),
        exercises: [
          TestFixtures.createExercise(
            id: 'rw1e1',
            workoutId: 'rw1',
            sets: [
              TestFixtures.createExerciseSet(
                id: 'rw1s1',
                weight: 100,
                reps: '10',
                isLogged: true,
              ),
              TestFixtures.createExerciseSet(
                id: 'rw1s2',
                setNumber: 2,
                weight: 110,
                reps: '8',
                isLogged: true,
              ),
            ],
          ),
        ],
      );
      await workoutRepo.create(workout);

      await useCase.execute([workout]);

      final fetched = await workoutRepo.getById('rw1');
      expect(fetched!.status, WorkoutStatus.incomplete);

      for (final exercise in fetched.exercises) {
        for (final set in exercise.sets) {
          expect(set.isLogged, false);
          expect(set.reps, '');
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // AddExerciseSetUseCase
  // ---------------------------------------------------------------------------
  group('AddExerciseSetUseCase', () {
    late AddExerciseSetUseCase useCase;

    setUp(() {
      useCase = AddExerciseSetUseCase(workoutRepo);
    });

    test('adds a new set to an exercise', () async {
      const cycleId = 'cycle-add-set-1';
      await insertTrainingCycle(cycleId);

      final workout = TestFixtures.createWorkout(
        id: 'as1',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 1,
        exercises: [
          TestFixtures.createExercise(
            id: 'as1e1',
            workoutId: 'as1',
            sets: [
              TestFixtures.createExerciseSet(
                id: 'as1s1',
                weight: 100,
                reps: '10',
              ),
            ],
          ),
        ],
      );
      await workoutRepo.create(workout);

      await useCase.execute('as1e1', 'as1');

      final fetched = await workoutRepo.getById('as1');
      expect(fetched!.exercises.first.sets.length, 2);

      final newSet = fetched.exercises.first.sets.last;
      expect(newSet.setNumber, 2);
      expect(newSet.reps, '');
      expect(newSet.setType, SetType.regular);
    });

    test('does nothing for non-existent workout', () async {
      await useCase.execute('nonexistent-exercise', 'nonexistent-workout');
      // Should not throw
    });

    test('does nothing for non-existent exercise in workout', () async {
      const cycleId = 'cycle-add-set-2';
      await insertTrainingCycle(cycleId);

      final workout = TestFixtures.createWorkout(
        id: 'as2',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 1,
      );
      await workoutRepo.create(workout);

      await useCase.execute('nonexistent-exercise', 'as2');

      final fetched = await workoutRepo.getById('as2');
      expect(fetched!.exercises, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // EndTrainingCycleUseCase
  // ---------------------------------------------------------------------------
  group('EndTrainingCycleUseCase', () {
    late EndTrainingCycleUseCase useCase;

    setUp(() {
      useCase = EndTrainingCycleUseCase(cycleRepo);
    });

    test('marks training cycle as completed with end date', () async {
      const cycleId = 'cycle-end-1';
      await insertTrainingCycle(cycleId, status: TrainingCycleStatus.current);

      final cycle = await cycleRepo.getById(cycleId);
      await useCase.execute(cycle!);

      final updated = await cycleRepo.getById(cycleId);
      expect(updated!.status, TrainingCycleStatus.completed);
      expect(updated.endDate, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // StartTrainingCycleUseCase
  // ---------------------------------------------------------------------------
  group('StartTrainingCycleUseCase', () {
    late StartTrainingCycleUseCase useCase;

    setUp(() {
      useCase = StartTrainingCycleUseCase(cycleRepo);
    });

    test('activates a draft training cycle', () async {
      const cycleId = 'cycle-start-1';
      await insertTrainingCycle(cycleId);

      final cycle = await cycleRepo.getById(cycleId);
      await useCase.execute(cycle!);

      final updated = await cycleRepo.getById(cycleId);
      expect(updated!.status, TrainingCycleStatus.current);
      expect(updated.startDate, isNotNull);
    });

    test('deactivates other current cycles', () async {
      const cycleId1 = 'cycle-start-2a';
      const cycleId2 = 'cycle-start-2b';
      await insertTrainingCycle(cycleId1, status: TrainingCycleStatus.current);
      await insertTrainingCycle(cycleId2);

      final cycle2 = await cycleRepo.getById(cycleId2);
      await useCase.execute(cycle2!);

      final updated1 = await cycleRepo.getById(cycleId1);
      final updated2 = await cycleRepo.getById(cycleId2);
      expect(updated1!.status, TrainingCycleStatus.draft);
      expect(updated2!.status, TrainingCycleStatus.current);
    });
  });
}
