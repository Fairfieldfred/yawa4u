import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/models/exercise.dart';

import 'helpers/integration_test_helpers.dart';

void main() {
  late IntegrationTestContext ctx;

  setUp(() async {
    TestDataFactory.reset();
    ctx = IntegrationTestContext();
    await ctx.initialize();
  });

  tearDown(() async {
    await ctx.dispose();
  });

  group('Exercise Management Flow', () {
    /// Helper: set up a cycle + workout and return the workout ID.
    Future<String> seedWorkout() async {
      final cycle = TestDataFactory.createCycle(id: 'cycle-em');
      await ctx.cycleRepo.create(cycle);

      final workout = TestDataFactory.createWorkout(
        id: 'workout-em',
        trainingCycleId: 'cycle-em',
      );
      await ctx.workoutRepo.create(workout);
      return 'workout-em';
    }

    test('add exercises to a workout and verify order', () async {
      final workoutId = await seedWorkout();

      // Add three exercises with explicit order
      final ex1 = TestDataFactory.createExercise(
        id: 'ex-1',
        workoutId: workoutId,
        name: 'Bench Press',
        muscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.barbell,
        orderIndex: 0,
        sets: [TestDataFactory.createSet(id: 's1', setNumber: 1)],
      );
      final ex2 = TestDataFactory.createExercise(
        id: 'ex-2',
        workoutId: workoutId,
        name: 'Incline DB Press',
        muscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.dumbbell,
        orderIndex: 1,
        sets: [TestDataFactory.createSet(id: 's2', setNumber: 1)],
      );
      final ex3 = TestDataFactory.createExercise(
        id: 'ex-3',
        workoutId: workoutId,
        name: 'Cable Fly',
        muscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.cable,
        orderIndex: 2,
        sets: [TestDataFactory.createSet(id: 's3', setNumber: 1)],
      );

      await ctx.exerciseRepo.create(ex1);
      await ctx.exerciseRepo.create(ex2);
      await ctx.exerciseRepo.create(ex3);

      final exercises = await ctx.exerciseRepo.getByWorkoutId(workoutId);
      expect(exercises.length, 3);
      expect(exercises[0].name, 'Bench Press');
      expect(exercises[1].name, 'Incline DB Press');
      expect(exercises[2].name, 'Cable Fly');
      expect(exercises[0].orderIndex, 0);
      expect(exercises[1].orderIndex, 1);
      expect(exercises[2].orderIndex, 2);
    });

    test('reorder exercises (move down) and verify persistence', () async {
      final workoutId = await seedWorkout();

      // Create exercises: A(0), B(1), C(2)
      for (var i = 0; i < 3; i++) {
        await ctx.exerciseRepo.create(TestDataFactory.createExercise(
          id: 'reorder-$i',
          workoutId: workoutId,
          name: 'Exercise ${String.fromCharCode(65 + i)}',
          orderIndex: i,
          sets: [
            TestDataFactory.createSet(id: 'rs-$i', setNumber: 1),
          ],
        ));
      }

      // Move A (index 0) to position 2: new order B(0), C(1), A(2)
      var exercises = await ctx.exerciseRepo.getByWorkoutId(workoutId);
      final exerciseA = exercises[0];
      final exerciseB = exercises[1];
      final exerciseC = exercises[2];

      // Update order indices
      await ctx.exerciseRepo.update(Exercise(
        id: exerciseB.id,
        workoutId: workoutId,
        name: exerciseB.name,
        muscleGroup: exerciseB.muscleGroup,
        equipmentType: exerciseB.equipmentType,
        orderIndex: 0,
        sets: exerciseB.sets,
      ));
      await ctx.exerciseRepo.update(Exercise(
        id: exerciseC.id,
        workoutId: workoutId,
        name: exerciseC.name,
        muscleGroup: exerciseC.muscleGroup,
        equipmentType: exerciseC.equipmentType,
        orderIndex: 1,
        sets: exerciseC.sets,
      ));
      await ctx.exerciseRepo.update(Exercise(
        id: exerciseA.id,
        workoutId: workoutId,
        name: exerciseA.name,
        muscleGroup: exerciseA.muscleGroup,
        equipmentType: exerciseA.equipmentType,
        orderIndex: 2,
        sets: exerciseA.sets,
      ));

      exercises = await ctx.exerciseRepo.getByWorkoutId(workoutId);
      expect(exercises[0].name, 'Exercise B');
      expect(exercises[1].name, 'Exercise C');
      expect(exercises[2].name, 'Exercise A');
    });

    test('reorder exercises (move up) and verify persistence', () async {
      final workoutId = await seedWorkout();

      for (var i = 0; i < 3; i++) {
        await ctx.exerciseRepo.create(TestDataFactory.createExercise(
          id: 'up-$i',
          workoutId: workoutId,
          name: 'Exercise ${String.fromCharCode(65 + i)}',
          orderIndex: i,
          sets: [TestDataFactory.createSet(id: 'us-$i', setNumber: 1)],
        ));
      }

      // Move C (index 2) to position 0: new order C(0), A(1), B(2)
      var exercises = await ctx.exerciseRepo.getByWorkoutId(workoutId);

      await ctx.exerciseRepo.update(Exercise(
        id: exercises[2].id,
        workoutId: workoutId,
        name: exercises[2].name,
        muscleGroup: exercises[2].muscleGroup,
        equipmentType: exercises[2].equipmentType,
        orderIndex: 0,
        sets: exercises[2].sets,
      ));
      await ctx.exerciseRepo.update(Exercise(
        id: exercises[0].id,
        workoutId: workoutId,
        name: exercises[0].name,
        muscleGroup: exercises[0].muscleGroup,
        equipmentType: exercises[0].equipmentType,
        orderIndex: 1,
        sets: exercises[0].sets,
      ));
      await ctx.exerciseRepo.update(Exercise(
        id: exercises[1].id,
        workoutId: workoutId,
        name: exercises[1].name,
        muscleGroup: exercises[1].muscleGroup,
        equipmentType: exercises[1].equipmentType,
        orderIndex: 2,
        sets: exercises[1].sets,
      ));

      exercises = await ctx.exerciseRepo.getByWorkoutId(workoutId);
      expect(exercises[0].name, 'Exercise C');
      expect(exercises[1].name, 'Exercise A');
      expect(exercises[2].name, 'Exercise B');
    });

    test('replace an exercise and verify sets are updated', () async {
      final workoutId = await seedWorkout();

      // Create an exercise
      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'replace-1',
        workoutId: workoutId,
        name: 'Flat Bench Press',
        muscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.barbell,
        orderIndex: 0,
        sets: [
          TestDataFactory.createSet(id: 'rset-1', setNumber: 1, weight: 135.0),
          TestDataFactory.createSet(id: 'rset-2', setNumber: 2, weight: 135.0),
        ],
      ));

      // Delete the old exercise
      await ctx.exerciseRepo.delete('replace-1');

      // Add a replacement exercise at the same position
      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'replace-2',
        workoutId: workoutId,
        name: 'Dumbbell Bench Press',
        muscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.dumbbell,
        orderIndex: 0,
        sets: [
          TestDataFactory.createSet(id: 'rset-3', setNumber: 1, weight: 50.0),
          TestDataFactory.createSet(id: 'rset-4', setNumber: 2, weight: 50.0),
          TestDataFactory.createSet(id: 'rset-5', setNumber: 3, weight: 50.0),
        ],
      ));

      final exercises = await ctx.exerciseRepo.getByWorkoutId(workoutId);
      expect(exercises.length, 1);
      expect(exercises[0].name, 'Dumbbell Bench Press');
      expect(exercises[0].equipmentType, EquipmentType.dumbbell);
      expect(exercises[0].sets.length, 3);
      expect(exercises[0].sets[0].weight, 50.0);

      // Old exercise should be gone
      final old = await ctx.exerciseRepo.getById('replace-1');
      expect(old, isNull);
    });

    test('delete an exercise and verify order is preserved', () async {
      final workoutId = await seedWorkout();

      // Create A(0), B(1), C(2)
      for (var i = 0; i < 3; i++) {
        await ctx.exerciseRepo.create(TestDataFactory.createExercise(
          id: 'del-$i',
          workoutId: workoutId,
          name: 'Exercise ${String.fromCharCode(65 + i)}',
          orderIndex: i,
          sets: [TestDataFactory.createSet(id: 'ds-$i', setNumber: 1)],
        ));
      }

      // Delete B (middle)
      await ctx.exerciseRepo.delete('del-1');

      var exercises = await ctx.exerciseRepo.getByWorkoutId(workoutId);
      expect(exercises.length, 2);
      expect(exercises[0].name, 'Exercise A');
      expect(exercises[1].name, 'Exercise C');

      // Verify sets for deleted exercise are also gone
      final deletedExercise = await ctx.exerciseRepo.getById('del-1');
      expect(deletedExercise, isNull);
    });

    test('deleting exercise cascades to its sets', () async {
      final workoutId = await seedWorkout();

      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'cascade-1',
        workoutId: workoutId,
        name: 'Heavy Squat',
        orderIndex: 0,
        sets: [
          TestDataFactory.createSet(id: 'cs-1', setNumber: 1),
          TestDataFactory.createSet(id: 'cs-2', setNumber: 2),
          TestDataFactory.createSet(id: 'cs-3', setNumber: 3),
        ],
      ));

      // Verify sets exist
      var exercise = await ctx.exerciseRepo.getById('cascade-1');
      expect(exercise!.sets.length, 3);

      // Delete the exercise
      await ctx.exerciseRepo.delete('cascade-1');

      // Exercise and all sets should be gone
      exercise = await ctx.exerciseRepo.getById('cascade-1');
      expect(exercise, isNull);

      // Total exercise count should be 0
      final count = await ctx.exerciseRepo.count();
      expect(count, 0);
    });

    test('filter exercises by muscle group and equipment type', () async {
      final workoutId = await seedWorkout();

      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'f1',
        workoutId: workoutId,
        name: 'Barbell Squat',
        muscleGroup: MuscleGroup.quads,
        equipmentType: EquipmentType.barbell,
        orderIndex: 0,
        sets: [TestDataFactory.createSet(id: 'fs1', setNumber: 1)],
      ));
      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'f2',
        workoutId: workoutId,
        name: 'Leg Press',
        muscleGroup: MuscleGroup.quads,
        equipmentType: EquipmentType.machine,
        orderIndex: 1,
        sets: [TestDataFactory.createSet(id: 'fs2', setNumber: 1)],
      ));
      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'f3',
        workoutId: workoutId,
        name: 'Barbell Curl',
        muscleGroup: MuscleGroup.biceps,
        equipmentType: EquipmentType.barbell,
        orderIndex: 2,
        sets: [TestDataFactory.createSet(id: 'fs3', setNumber: 1)],
      ));

      final quads = await ctx.exerciseRepo.getByMuscleGroup(MuscleGroup.quads);
      expect(quads.length, 2);

      final barbells =
          await ctx.exerciseRepo.getByEquipmentType(EquipmentType.barbell);
      expect(barbells.length, 2);

      final machines =
          await ctx.exerciseRepo.getByEquipmentType(EquipmentType.machine);
      expect(machines.length, 1);
      expect(machines[0].name, 'Leg Press');
    });

    test('update exercise sets (add and remove sets)', () async {
      final workoutId = await seedWorkout();

      // Create with 2 sets
      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'set-mgmt',
        workoutId: workoutId,
        name: 'Deadlift',
        orderIndex: 0,
        sets: [
          TestDataFactory.createSet(id: 'sm-1', setNumber: 1, weight: 315.0),
          TestDataFactory.createSet(id: 'sm-2', setNumber: 2, weight: 315.0),
        ],
      ));

      var exercise = await ctx.exerciseRepo.getById('set-mgmt');
      expect(exercise!.sets.length, 2);

      // Update: remove set 2, add set 3 and set 4
      await ctx.exerciseRepo.update(Exercise(
        id: 'set-mgmt',
        workoutId: workoutId,
        name: 'Deadlift',
        muscleGroup: exercise.muscleGroup,
        equipmentType: exercise.equipmentType,
        orderIndex: 0,
        sets: [
          exercise.sets[0], // keep set 1
          TestDataFactory.createSet(id: 'sm-3', setNumber: 2, weight: 335.0),
          TestDataFactory.createSet(id: 'sm-4', setNumber: 3, weight: 355.0),
        ],
      ));

      exercise = await ctx.exerciseRepo.getById('set-mgmt');
      expect(exercise!.sets.length, 3);
      expect(exercise.sets[0].weight, 315.0); // original set 1
      expect(exercise.sets[1].weight, 335.0); // new set
      expect(exercise.sets[2].weight, 355.0); // new set
    });

    test('search exercises by name', () async {
      final workoutId = await seedWorkout();

      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'search-1',
        workoutId: workoutId,
        name: 'Barbell Bench Press',
        orderIndex: 0,
        sets: [TestDataFactory.createSet(id: 'ss1', setNumber: 1)],
      ));
      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'search-2',
        workoutId: workoutId,
        name: 'Dumbbell Bench Press',
        orderIndex: 1,
        sets: [TestDataFactory.createSet(id: 'ss2', setNumber: 1)],
      ));
      await ctx.exerciseRepo.create(TestDataFactory.createExercise(
        id: 'search-3',
        workoutId: workoutId,
        name: 'Squat',
        orderIndex: 2,
        sets: [TestDataFactory.createSet(id: 'ss3', setNumber: 1)],
      ));

      final results = await ctx.exerciseRepo.searchByName('bench');
      expect(results.length, 2);

      final exact = await ctx.exerciseRepo.getByName('squat');
      expect(exact.length, 1);
      expect(exact[0].name, 'Squat');
    });
  });
}
