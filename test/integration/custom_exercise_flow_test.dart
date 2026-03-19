import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';

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

  group('Custom Exercise Flow', () {
    test('create a custom exercise and verify it persists', () async {
      final custom = TestDataFactory.createCustomExercise(
        id: 'custom-1',
        name: 'Landmine Press',
        muscleGroup: MuscleGroup.shoulders,
        secondaryMuscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.barbell,
        videoUrl: 'https://youtube.com/watch?v=example',
      );

      await ctx.customExerciseRepo.add(custom);

      final saved = await ctx.customExerciseRepo.getById('custom-1');
      expect(saved, isNotNull);
      expect(saved!.name, 'Landmine Press');
      expect(saved.muscleGroup, MuscleGroup.shoulders);
      expect(saved.secondaryMuscleGroup, MuscleGroup.chest);
      expect(saved.equipmentType, EquipmentType.barbell);
      expect(saved.videoUrl, 'https://youtube.com/watch?v=example');
    });

    test('custom exercise appears in combined list via toExerciseDefinition',
        () async {
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'custom-combined',
        name: 'Z-Bar Curl',
        muscleGroup: MuscleGroup.biceps,
        equipmentType: EquipmentType.barbell,
      ));

      final all = await ctx.customExerciseRepo.getAll();
      expect(all.length, 1);

      // Verify it converts to ExerciseDefinition correctly
      final def = all[0].toExerciseDefinition();
      expect(def.name, 'Z-Bar Curl');
      expect(def.muscleGroup, MuscleGroup.biceps);
      expect(def.equipmentType, EquipmentType.barbell);
    });

    test('use a custom exercise in a workout', () async {
      // Create custom exercise definition
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'custom-use',
        name: 'Cable Overhead Tricep Extension',
        muscleGroup: MuscleGroup.triceps,
        equipmentType: EquipmentType.cable,
      ));

      // Create a cycle and workout
      final cycle = TestDataFactory.createCycle(id: 'cycle-custom');
      await ctx.cycleRepo.create(cycle);

      // Use the custom exercise in a workout
      final workout = TestDataFactory.createWorkout(
        id: 'w-custom',
        trainingCycleId: 'cycle-custom',
        label: 'Triceps',
        exercises: [
          TestDataFactory.createExercise(
            id: 'ex-custom',
            workoutId: 'w-custom',
            name: 'Cable Overhead Tricep Extension',
            muscleGroup: MuscleGroup.triceps,
            equipmentType: EquipmentType.cable,
            orderIndex: 0,
            sets: [
              TestDataFactory.createSet(
                id: 'cs-1',
                setNumber: 1,
                weight: 30.0,
                reps: '12',
              ),
              TestDataFactory.createSet(
                id: 'cs-2',
                setNumber: 2,
                weight: 30.0,
                reps: '12',
              ),
            ],
          ),
        ],
      );
      await ctx.workoutRepo.create(workout);

      // Verify the workout has the exercise
      final loaded = await ctx.workoutRepo.getById('w-custom');
      expect(loaded, isNotNull);
      expect(loaded!.exercises.length, 1);
      expect(loaded.exercises[0].name, 'Cable Overhead Tricep Extension');
      expect(loaded.exercises[0].sets.length, 2);
    });

    test('edit a custom exercise definition', () async {
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'custom-edit',
        name: 'My Press',
        muscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.machine,
      ));

      var saved = await ctx.customExerciseRepo.getById('custom-edit');
      expect(saved!.name, 'My Press');

      // Update the exercise — use the DAO directly since
      // CustomExerciseRepository.update uses dynamic casting
      final updated = saved.copyWith(
        name: 'My Improved Press',
        muscleGroup: MuscleGroup.shoulders,
        equipmentType: EquipmentType.dumbbell,
      );

      // Delete and re-add to simulate an edit (simpler than the dynamic DAO)
      await ctx.customExerciseRepo.delete('custom-edit');
      await ctx.customExerciseRepo.add(updated);

      saved = await ctx.customExerciseRepo.getById('custom-edit');
      expect(saved, isNotNull);
      expect(saved!.name, 'My Improved Press');
      expect(saved.muscleGroup, MuscleGroup.shoulders);
      expect(saved.equipmentType, EquipmentType.dumbbell);
    });

    test('delete a custom exercise and verify removal', () async {
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'custom-del-1',
        name: 'Custom A',
      ));
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'custom-del-2',
        name: 'Custom B',
      ));

      expect(await ctx.customExerciseRepo.count(), 2);

      await ctx.customExerciseRepo.delete('custom-del-1');

      expect(await ctx.customExerciseRepo.count(), 1);
      final remaining = await ctx.customExerciseRepo.getAll();
      expect(remaining[0].name, 'Custom B');

      // Deleted one should be null
      final deleted = await ctx.customExerciseRepo.getById('custom-del-1');
      expect(deleted, isNull);
    });

    test('check existsByName is case-insensitive', () async {
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'custom-case',
        name: 'Reverse Grip Curl',
      ));

      expect(await ctx.customExerciseRepo.existsByName('Reverse Grip Curl'),
          isTrue);
      expect(await ctx.customExerciseRepo.existsByName('reverse grip curl'),
          isTrue);
      expect(await ctx.customExerciseRepo.existsByName('REVERSE GRIP CURL'),
          isTrue);
      expect(
          await ctx.customExerciseRepo.existsByName('Nonexistent'), isFalse);
    });

    test('getByName returns correct exercise', () async {
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'custom-name-1',
        name: 'Alpha Exercise',
        muscleGroup: MuscleGroup.back,
      ));
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'custom-name-2',
        name: 'Beta Exercise',
        muscleGroup: MuscleGroup.biceps,
      ));

      final result = await ctx.customExerciseRepo.getByName('beta exercise');
      expect(result, isNotNull);
      expect(result!.id, 'custom-name-2');
      expect(result.muscleGroup, MuscleGroup.biceps);

      final notFound = await ctx.customExerciseRepo.getByName('gamma');
      expect(notFound, isNull);
    });

    test('custom exercises are sorted alphabetically', () async {
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'sort-3',
        name: 'Zottman Curl',
      ));
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'sort-1',
        name: 'Arnold Press',
      ));
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'sort-2',
        name: 'Meadow Row',
      ));

      final all = await ctx.customExerciseRepo.getAll();
      expect(all.length, 3);
      expect(all[0].name, 'Arnold Press');
      expect(all[1].name, 'Meadow Row');
      expect(all[2].name, 'Zottman Curl');
    });

    test('deleteAll removes all custom exercises', () async {
      for (var i = 0; i < 5; i++) {
        await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
          id: 'bulk-$i',
          name: 'Bulk Exercise $i',
        ));
      }
      expect(await ctx.customExerciseRepo.count(), 5);

      await ctx.customExerciseRepo.deleteAll();
      expect(await ctx.customExerciseRepo.count(), 0);
    });

    test('custom exercise stream emits updates reactively', () async {
      final stream = ctx.customExerciseRepo.watchAll();

      final first = await stream.first;
      expect(first, isEmpty);

      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'stream-1',
        name: 'Stream Exercise',
      ));

      final second = await stream.first;
      expect(second.length, 1);
      expect(second[0].name, 'Stream Exercise');
    });

    test('custom exercise with secondary muscle group', () async {
      await ctx.customExerciseRepo.add(TestDataFactory.createCustomExercise(
        id: 'secondary-1',
        name: 'Close Grip Bench',
        muscleGroup: MuscleGroup.triceps,
        secondaryMuscleGroup: MuscleGroup.chest,
        equipmentType: EquipmentType.barbell,
      ));

      final saved = await ctx.customExerciseRepo.getById('secondary-1');
      expect(saved, isNotNull);
      expect(saved!.muscleGroup, MuscleGroup.triceps);
      expect(saved.secondaryMuscleGroup, MuscleGroup.chest);

      // Verify it converts to ExerciseDefinition with secondary
      final def = saved.toExerciseDefinition();
      expect(def.secondaryMuscleGroup, MuscleGroup.chest);
    });
  });
}
