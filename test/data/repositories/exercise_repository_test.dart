import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/exercise_repository.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late ExerciseRepository repo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ExerciseRepository(db.exerciseDao, db.exerciseSetDao);
  });

  tearDown(() async {
    await db.close();
  });

  /// Insert prerequisite rows (cycle + workout) so FK constraints pass.
  Future<void> insertPrerequisites(String workoutUuid) async {
    const cycleUuid = 'cycle-1';
    await db.trainingCycleDao.insertCycle(
      TrainingCyclesCompanion.insert(
        uuid: cycleUuid,
        name: 'Test Cycle',
        periodsTotal: 4,
        daysPerPeriod: 5,
        recoveryPeriod: 4,
        status: 0,
        createdDate: DateTime.now(),
      ),
    );
    await db.workoutDao.insertWorkout(
      WorkoutsCompanion.insert(
        uuid: workoutUuid,
        trainingCycleUuid: cycleUuid,
        periodNumber: 1,
        dayNumber: 1,
        status: 0,
      ),
    );
  }

  group('ExerciseRepository CRUD', () {
    test('create and getById returns exercise with sets', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      final exercise = TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        name: 'Bench Press',
        muscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.barbell,
        sets: [
          TestFixtures.createExerciseSet(
            id: 'es1',
            weight: 135,
            reps: '10',
            setNumber: 1,
          ),
          TestFixtures.createExerciseSet(
            id: 'es2',
            weight: 135,
            reps: '8',
            setNumber: 2,
          ),
        ],
      );

      await repo.create(exercise);
      final fetched = await repo.getById('e1');

      expect(fetched, isNotNull);
      expect(fetched!.name, 'Bench Press');
      expect(fetched.muscleGroup, MuscleGroup.chest);
      expect(fetched.sets.length, 2);
      expect(fetched.sets[0].weight, 135);
    });

    test('getById returns null for non-existent id', () async {
      expect(await repo.getById('non-existent'), isNull);
    });

    test('getAll returns all exercises', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      await repo.create(TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        sets: [],
      ));
      await repo.create(TestFixtures.createExercise(
        id: 'e2',
        workoutId: workoutId,
        sets: [],
      ));

      final all = await repo.getAll();
      expect(all.length, 2);
    });

    test('update modifies exercise and sets', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      final exercise = TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        name: 'Bench Press',
        sets: [
          TestFixtures.createExerciseSet(id: 'es1', weight: 100, setNumber: 1),
        ],
      );
      await repo.create(exercise);

      final updated = exercise.copyWith(
        notes: 'Good form today',
        sets: [
          exercise.sets.first.copyWith(weight: 110),
          TestFixtures.createExerciseSet(id: 'es2', weight: 110, setNumber: 2),
        ],
      );
      await repo.update(updated);

      final fetched = await repo.getById('e1');
      expect(fetched!.notes, 'Good form today');
      expect(fetched.sets.length, 2);
      expect(fetched.sets[0].weight, 110);
    });

    test('update removes deleted sets', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      final exercise = TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        sets: [
          TestFixtures.createExerciseSet(id: 'es1', setNumber: 1),
          TestFixtures.createExerciseSet(id: 'es2', setNumber: 2),
        ],
      );
      await repo.create(exercise);

      final updated = exercise.copyWith(sets: [exercise.sets.first]);
      await repo.update(updated);

      final fetched = await repo.getById('e1');
      expect(fetched!.sets.length, 1);
    });

    test('delete removes exercise and sets', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      await repo.create(TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        sets: [TestFixtures.createExerciseSet(id: 'es1')],
      ));

      await repo.delete('e1');
      expect(await repo.getById('e1'), isNull);
      expect(await repo.count(), 0);
    });
  });

  group('ExerciseRepository queries', () {
    late String workoutId;

    setUp(() async {
      workoutId = 'w1';
      await insertPrerequisites(workoutId);

      await repo.create(TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        name: 'Bench Press',
        muscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.barbell,
        orderIndex: 0,
        sets: [],
      ));
      await repo.create(TestFixtures.createExercise(
        id: 'e2',
        workoutId: workoutId,
        name: 'Lat Pulldown',
        muscleGroup: MuscleGroup.back,
        equipmentType: EquipmentType.cable,
        orderIndex: 1,
        sets: [],
      ));
      await repo.create(TestFixtures.createExercise(
        id: 'e3',
        workoutId: workoutId,
        name: 'Incline Bench Press',
        muscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.barbell,
        orderIndex: 2,
        sets: [],
      ));
    });

    test('getByWorkoutId returns exercises sorted by orderIndex', () async {
      final exercises = await repo.getByWorkoutId(workoutId);
      expect(exercises.length, 3);
      expect(exercises[0].orderIndex, 0);
      expect(exercises[1].orderIndex, 1);
      expect(exercises[2].orderIndex, 2);
    });

    test('getByMuscleGroup filters correctly', () async {
      final chest = await repo.getByMuscleGroup(MuscleGroup.chest);
      expect(chest.length, 2);
      expect(chest.every((e) => e.muscleGroup == MuscleGroup.chest), true);

      final back = await repo.getByMuscleGroup(MuscleGroup.back);
      expect(back.length, 1);
    });

    test('getByEquipmentType filters correctly', () async {
      final barbell = await repo.getByEquipmentType(EquipmentType.barbell);
      expect(barbell.length, 2);

      final cable = await repo.getByEquipmentType(EquipmentType.cable);
      expect(cable.length, 1);
    });

    test('getByName matches case-insensitively', () async {
      final result = await repo.getByName('bench press');
      expect(result.length, 1);
      expect(result.first.name, 'Bench Press');
    });

    test('searchByName returns partial matches', () async {
      final result = await repo.searchByName('bench');
      expect(result.length, 2);
    });

    test('searchByName with empty query returns all', () async {
      final result = await repo.searchByName('');
      expect(result.length, 3);
    });

    test('searchByName is case-insensitive', () async {
      final result = await repo.searchByName('BENCH');
      expect(result.length, 2);
    });
  });

  group('ExerciseRepository status queries', () {
    test('getCompleted returns exercises with all sets logged', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      await repo.create(TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        sets: [
          TestFixtures.createExerciseSet(id: 'es1', isLogged: true),
          TestFixtures.createExerciseSet(id: 'es2', isLogged: true),
        ],
      ));
      await repo.create(TestFixtures.createExercise(
        id: 'e2',
        workoutId: workoutId,
        sets: [
          TestFixtures.createExerciseSet(id: 'es3', isLogged: true),
          TestFixtures.createExerciseSet(id: 'es4', isLogged: false),
        ],
      ));

      final completed = await repo.getCompleted();
      expect(completed.length, 1);
      expect(completed.first.id, 'e1');
    });

    test('getIncomplete returns exercises with unlogged sets', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      await repo.create(TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        sets: [
          TestFixtures.createExerciseSet(id: 'es1', isLogged: false),
        ],
      ));

      final incomplete = await repo.getIncomplete();
      expect(incomplete.length, 1);
    });

    test('getWithMyorepSets returns exercises with myorep sets', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      await repo.create(TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        sets: [
          TestFixtures.createExerciseSet(id: 'es1', setType: SetType.myorep),
        ],
      ));
      await repo.create(TestFixtures.createExercise(
        id: 'e2',
        workoutId: workoutId,
        sets: [
          TestFixtures.createExerciseSet(id: 'es2', setType: SetType.regular),
        ],
      ));

      final myorep = await repo.getWithMyorepSets();
      expect(myorep.length, 1);
      expect(myorep.first.id, 'e1');
    });
  });

  group('ExerciseRepository bulk operations', () {
    test('deleteAll removes everything', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      await repo.create(TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        sets: [TestFixtures.createExerciseSet(id: 'es1')],
      ));

      await repo.deleteAll();
      expect(await repo.count(), 0);
    });

    test('deleteByWorkoutId removes exercises for specific workout', () async {
      const workoutId1 = 'w1';
      await insertPrerequisites(workoutId1);

      await repo.create(TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId1,
        sets: [],
      ));

      await repo.deleteByWorkoutId(workoutId1);
      expect(await repo.count(), 0);
    });

    test('count returns correct number', () async {
      const workoutId = 'w1';
      await insertPrerequisites(workoutId);

      await repo.create(TestFixtures.createExercise(
        id: 'e1',
        workoutId: workoutId,
        sets: [],
      ));
      await repo.create(TestFixtures.createExercise(
        id: 'e2',
        workoutId: workoutId,
        sets: [],
      ));

      expect(await repo.count(), 2);
    });
  });
}
