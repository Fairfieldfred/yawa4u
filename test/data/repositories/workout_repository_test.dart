import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/workout_repository.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository repo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = WorkoutRepository(db.workoutDao, db.exerciseDao, db.exerciseSetDao);
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper: insert a training cycle row into the database.
  Future<void> insertTrainingCycle(String uuid) async {
    await db.trainingCycleDao.insertCycle(
      TrainingCyclesCompanion.insert(
        uuid: uuid,
        name: 'Test Cycle',
        periodsTotal: 4,
        daysPerPeriod: 5,
        recoveryPeriod: 4,
        status: 0, // draft
        createdDate: DateTime.now(),
      ),
    );
  }

  group('WorkoutRepository CRUD', () {
    test('create and getById returns workout with exercises and sets', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      final workout = TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 1,
        label: 'Chest',
        exercises: [
          TestFixtures.createExercise(
            id: 'e1',
            workoutId: 'w1',
            name: 'Bench Press',
            sets: [
              TestFixtures.createExerciseSet(
                id: 'es1',
                weight: 100,
                reps: '10',
                setNumber: 1,
              ),
            ],
          ),
        ],
      );

      await repo.create(workout);
      final fetched = await repo.getById('w1');

      expect(fetched, isNotNull);
      expect(fetched!.id, 'w1');
      expect(fetched.trainingCycleId, cycleId);
      expect(fetched.periodNumber, 1);
      expect(fetched.dayNumber, 1);
      expect(fetched.exercises.length, 1);
      expect(fetched.exercises.first.name, 'Bench Press');
      expect(fetched.exercises.first.sets.length, 1);
      expect(fetched.exercises.first.sets.first.weight, 100);
    });

    test('getById returns null for non-existent id', () async {
      final result = await repo.getById('non-existent');
      expect(result, isNull);
    });

    test('getAll returns all workouts', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        exercises: [],
      ));
      await repo.create(TestFixtures.createWorkout(
        id: 'w2',
        trainingCycleId: cycleId,
        exercises: [],
      ));

      final all = await repo.getAll();
      expect(all.length, 2);
    });

    test('update modifies workout and exercises', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      final workout = TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        dayName: 'Push Day',
        exercises: [
          TestFixtures.createExercise(
            id: 'e1',
            workoutId: 'w1',
            name: 'Bench Press',
            sets: [
              TestFixtures.createExerciseSet(id: 'es1', setNumber: 1),
            ],
          ),
        ],
      );
      await repo.create(workout);

      final updated = workout.copyWith(
        notes: 'Updated note',
        exercises: [
          workout.exercises.first.copyWith(
            sets: [
              workout.exercises.first.sets.first,
              TestFixtures.createExerciseSet(
                id: 'es2',
                setNumber: 2,
                weight: 110,
              ),
            ],
          ),
        ],
      );
      await repo.update(updated);

      final fetched = await repo.getById('w1');
      expect(fetched!.notes, 'Updated note');
      expect(fetched.exercises.first.sets.length, 2);
    });

    test('delete removes workout and all related data', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        exercises: [
          TestFixtures.createExercise(
            id: 'e1',
            workoutId: 'w1',
            sets: [TestFixtures.createExerciseSet(id: 'es1')],
          ),
        ],
      ));

      await repo.delete('w1');
      expect(await repo.getById('w1'), isNull);
      expect(await repo.count(), 0);
    });
  });

  group('WorkoutRepository queries', () {
    late String cycleId;

    setUp(() async {
      cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 1,
        status: WorkoutStatus.completed,
        exercises: [],
      ));
      await repo.create(TestFixtures.createWorkout(
        id: 'w2',
        trainingCycleId: cycleId,
        periodNumber: 1,
        dayNumber: 2,
        status: WorkoutStatus.incomplete,
        exercises: [],
      ));
      await repo.create(TestFixtures.createWorkout(
        id: 'w3',
        trainingCycleId: cycleId,
        periodNumber: 2,
        dayNumber: 1,
        status: WorkoutStatus.skipped,
        exercises: [],
      ));
    });

    test('getByTrainingCycleId returns workouts sorted by period and day',
        () async {
      final workouts = await repo.getByTrainingCycleId(cycleId);
      expect(workouts.length, 3);
      expect(workouts[0].periodNumber, 1);
      expect(workouts[0].dayNumber, 1);
      expect(workouts[1].periodNumber, 1);
      expect(workouts[1].dayNumber, 2);
      expect(workouts[2].periodNumber, 2);
    });

    test('getByPeriod returns workouts for specific period', () async {
      final period1 = await repo.getByPeriod(cycleId, 1);
      expect(period1.length, 2);
      final period2 = await repo.getByPeriod(cycleId, 2);
      expect(period2.length, 1);
    });

    test('getByPeriodAndDay returns workouts for specific day', () async {
      final dayWorkouts = await repo.getByPeriodAndDay(cycleId, 1, 1);
      expect(dayWorkouts.length, 1);
      expect(dayWorkouts.first.id, 'w1');
    });

    test('getCompleted returns only completed workouts', () async {
      final completed = await repo.getCompleted();
      expect(completed.length, 1);
      expect(completed.first.status, WorkoutStatus.completed);
    });

    test('getIncomplete returns only incomplete workouts', () async {
      final incomplete = await repo.getIncomplete();
      expect(incomplete.length, 1);
      expect(incomplete.first.status, WorkoutStatus.incomplete);
    });

    test('getSkipped returns only skipped workouts', () async {
      final skipped = await repo.getSkipped();
      expect(skipped.length, 1);
      expect(skipped.first.status, WorkoutStatus.skipped);
    });
  });

  group('WorkoutRepository status operations', () {
    test('markAsCompleted changes status', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        status: WorkoutStatus.incomplete,
        exercises: [],
      ));

      await repo.markAsCompleted('w1');
      final fetched = await repo.getById('w1');
      expect(fetched!.status, WorkoutStatus.completed);
      expect(fetched.completedDate, isNotNull);
    });

    test('markAsSkipped changes status', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        status: WorkoutStatus.incomplete,
        exercises: [],
      ));

      await repo.markAsSkipped('w1');
      final fetched = await repo.getById('w1');
      expect(fetched!.status, WorkoutStatus.skipped);
    });

    test('resetWorkout resets to incomplete', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        status: WorkoutStatus.completed,
        exercises: [],
      ));

      await repo.resetWorkout('w1');
      final fetched = await repo.getById('w1');
      expect(fetched!.status, WorkoutStatus.incomplete);
    });
  });

  group('WorkoutRepository stats', () {
    test('getStats returns correct counts', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        status: WorkoutStatus.completed,
        exercises: [],
      ));
      await repo.create(TestFixtures.createWorkout(
        id: 'w2',
        trainingCycleId: cycleId,
        status: WorkoutStatus.incomplete,
        exercises: [],
      ));
      await repo.create(TestFixtures.createWorkout(
        id: 'w3',
        trainingCycleId: cycleId,
        status: WorkoutStatus.skipped,
        exercises: [],
      ));

      final stats = await repo.getStats();
      expect(stats['total'], 3);
      expect(stats['completed'], 1);
      expect(stats['incomplete'], 1);
      expect(stats['skipped'], 1);
    });

    test('getStatsForTrainingCycle returns cycle-specific stats', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        status: WorkoutStatus.completed,
        exercises: [],
      ));
      await repo.create(TestFixtures.createWorkout(
        id: 'w2',
        trainingCycleId: cycleId,
        status: WorkoutStatus.incomplete,
        exercises: [],
      ));

      final stats = await repo.getStatsForTrainingCycle(cycleId);
      expect(stats['total'], 2);
      expect(stats['completed'], 1);
      expect(stats['incomplete'], 1);
      expect(stats['completion_rate'], 0.5);
    });

    test('count returns total count', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        exercises: [],
      ));
      expect(await repo.count(), 1);
    });

    test('clear removes all workouts', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        exercises: [],
      ));
      await repo.clear();
      expect(await repo.count(), 0);
    });
  });

  group('WorkoutRepository streams', () {
    test('watchAll emits updated list on changes', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      final stream = repo.watchAll();

      // First emission should be empty
      expect(await stream.first, isEmpty);

      // Create a workout and check the stream emits it
      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        exercises: [],
      ));

      final workouts = await stream.first;
      expect(workouts.length, 1);
    });

    test('watchByTrainingCycleId filters by cycle', () async {
      final cycleId1 = 'cycle-1';
      final cycleId2 = 'cycle-2';
      await insertTrainingCycle(cycleId1);
      await insertTrainingCycle(cycleId2);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId1,
        exercises: [],
      ));
      await repo.create(TestFixtures.createWorkout(
        id: 'w2',
        trainingCycleId: cycleId2,
        exercises: [],
      ));

      final stream = repo.watchByTrainingCycleId(cycleId1);
      final workouts = await stream.first;
      expect(workouts.length, 1);
      expect(workouts.first.trainingCycleId, cycleId1);
    });
  });

  group('WorkoutRepository deleteByTrainingCycleId', () {
    test('deletes all workouts for a cycle', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: cycleId,
        exercises: [],
      ));
      await repo.create(TestFixtures.createWorkout(
        id: 'w2',
        trainingCycleId: cycleId,
        exercises: [],
      ));

      await repo.deleteByTrainingCycleId(cycleId);
      expect(await repo.count(), 0);
    });
  });
}
