import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/core/constants/equipment_types.dart';
import 'package:yawa4u/core/constants/muscle_groups.dart';
import 'package:yawa4u/data/models/exercise.dart';
import 'package:yawa4u/data/models/exercise_set.dart';

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

  group('Workout Flow - Complete Lifecycle', () {
    test('create cycle → add workout → add exercises → log sets → complete',
        () async {
      // 1. Create a training cycle
      final cycle = TestDataFactory.createCycle(
        id: 'cycle-1',
        name: 'Push Pull Legs',
      );
      await ctx.cycleRepo.create(cycle);

      final savedCycle = await ctx.cycleRepo.getById('cycle-1');
      expect(savedCycle, isNotNull);
      expect(savedCycle!.name, 'Push Pull Legs');
      expect(savedCycle.status, TrainingCycleStatus.draft);

      // 2. Create a workout with exercises and sets
      final workout = TestDataFactory.createFullWorkout(
        id: 'workout-1',
        trainingCycleId: 'cycle-1',
        periodNumber: 1,
        dayNumber: 1,
        label: 'Chest',
        exerciseCount: 2,
        setsPerExercise: 3,
      );
      await ctx.workoutRepo.create(workout);

      // 3. Verify workout was saved with exercises and sets
      final savedWorkout = await ctx.workoutRepo.getById('workout-1');
      expect(savedWorkout, isNotNull);
      expect(savedWorkout!.exercises.length, 2);
      expect(savedWorkout.exercises[0].sets.length, 3);
      expect(savedWorkout.exercises[1].sets.length, 3);
      expect(savedWorkout.status, WorkoutStatus.incomplete);

      // 4. Log sets (update weight, reps, mark as logged)
      final exercise = savedWorkout.exercises[0];
      final updatedSets = exercise.sets
          .map(
            (s) => ExerciseSet(
              id: s.id,
              setNumber: s.setNumber,
              weight: 135.0,
              reps: '8',
              setType: s.setType,
              isLogged: true,
            ),
          )
          .toList();

      final updatedExercise = Exercise(
        id: exercise.id,
        workoutId: exercise.workoutId,
        name: exercise.name,
        muscleGroup: exercise.muscleGroup,
        equipmentType: exercise.equipmentType,
        orderIndex: exercise.orderIndex,
        sets: updatedSets,
      );
      await ctx.exerciseRepo.update(updatedExercise);

      // Verify sets are updated
      final reloadedExercise =
          await ctx.exerciseRepo.getById(exercise.id);
      expect(reloadedExercise, isNotNull);
      expect(reloadedExercise!.sets.every((s) => s.isLogged), isTrue);
      expect(reloadedExercise.sets.every((s) => s.weight == 135.0), isTrue);
      expect(reloadedExercise.sets.every((s) => s.reps == '8'), isTrue);

      // 5. Mark workout as completed
      await ctx.workoutRepo.markAsCompleted('workout-1');

      final completedWorkout = await ctx.workoutRepo.getById('workout-1');
      expect(completedWorkout!.status, WorkoutStatus.completed);
      expect(completedWorkout.completedDate, isNotNull);

      // 6. Verify it appears in completed list
      final completedList = await ctx.workoutRepo.getCompleted();
      expect(completedList.length, 1);
      expect(completedList[0].id, 'workout-1');

      // 7. Verify stats update
      final stats = await ctx.workoutRepo.getStats();
      expect(stats['total'], 1);
      expect(stats['completed'], 1);
      expect(stats['incomplete'], 0);
    });

    test('log sets across multiple exercises and verify stats', () async {
      final cycle = TestDataFactory.createCycle(id: 'cycle-stats');
      await ctx.cycleRepo.create(cycle);

      // Create two workouts
      final workout1 = TestDataFactory.createFullWorkout(
        id: 'w1',
        trainingCycleId: 'cycle-stats',
        periodNumber: 1,
        dayNumber: 1,
        exerciseCount: 2,
        setsPerExercise: 2,
      );
      final workout2 = TestDataFactory.createFullWorkout(
        id: 'w2',
        trainingCycleId: 'cycle-stats',
        periodNumber: 1,
        dayNumber: 2,
        exerciseCount: 1,
        setsPerExercise: 2,
      );
      await ctx.workoutRepo.create(workout1);
      await ctx.workoutRepo.create(workout2);

      // Complete first, skip second
      await ctx.workoutRepo.markAsCompleted('w1');
      await ctx.workoutRepo.markAsSkipped('w2');

      final stats =
          await ctx.workoutRepo.getStatsForTrainingCycle('cycle-stats');
      expect(stats['total'], 2);
      expect(stats['completed'], 1);
      expect(stats['skipped'], 1);
      expect(stats['incomplete'], 0);
    });

    test('workout hierarchy loads correctly through repository', () async {
      final cycle = TestDataFactory.createCycle(id: 'cycle-hierarchy');
      await ctx.cycleRepo.create(cycle);

      final workout = TestDataFactory.createWorkout(
        id: 'wh-1',
        trainingCycleId: 'cycle-hierarchy',
        exercises: [
          TestDataFactory.createExercise(
            id: 'ex-1',
            workoutId: 'wh-1',
            name: 'Squat',
            muscleGroup: MuscleGroup.quads,
            equipmentType: EquipmentType.barbell,
            orderIndex: 0,
            sets: [
              TestDataFactory.createSet(
                id: 'set-1',
                setNumber: 1,
                weight: 225.0,
                reps: '5',
              ),
              TestDataFactory.createSet(
                id: 'set-2',
                setNumber: 2,
                weight: 225.0,
                reps: '5',
              ),
            ],
          ),
        ],
      );
      await ctx.workoutRepo.create(workout);

      // Load via workout repo — should include full hierarchy
      final loaded = await ctx.workoutRepo.getById('wh-1');
      expect(loaded, isNotNull);
      expect(loaded!.exercises.length, 1);
      expect(loaded.exercises[0].name, 'Squat');
      expect(loaded.exercises[0].sets.length, 2);
      expect(loaded.exercises[0].sets[0].weight, 225.0);

      // Also verify via getByTrainingCycleId
      final cycleWorkouts =
          await ctx.workoutRepo.getByTrainingCycleId('cycle-hierarchy');
      expect(cycleWorkouts.length, 1);
      expect(cycleWorkouts[0].exercises[0].sets.length, 2);
    });

    test('reset completed workout back to incomplete', () async {
      final cycle = TestDataFactory.createCycle(id: 'cycle-reset');
      await ctx.cycleRepo.create(cycle);

      final workout = TestDataFactory.createFullWorkout(
        id: 'w-reset',
        trainingCycleId: 'cycle-reset',
      );
      await ctx.workoutRepo.create(workout);

      await ctx.workoutRepo.markAsCompleted('w-reset');
      var loaded = await ctx.workoutRepo.getById('w-reset');
      expect(loaded!.status, WorkoutStatus.completed);

      await ctx.workoutRepo.resetWorkout('w-reset');
      loaded = await ctx.workoutRepo.getById('w-reset');
      expect(loaded!.status, WorkoutStatus.incomplete);
    });

    test('exercise history service finds previous performance', () async {
      final cycle = TestDataFactory.createCycle(id: 'cycle-history');
      await ctx.cycleRepo.create(cycle);

      // First workout with Bench Press — logged
      final workout1 = TestDataFactory.createWorkout(
        id: 'wh-old',
        trainingCycleId: 'cycle-history',
        periodNumber: 1,
        dayNumber: 1,
        exercises: [
          TestDataFactory.createExercise(
            id: 'ex-old',
            workoutId: 'wh-old',
            name: 'Bench Press',
            orderIndex: 0,
            sets: [
              TestDataFactory.createSet(
                id: 'set-old-1',
                setNumber: 1,
                weight: 135.0,
                reps: '8',
                isLogged: true,
              ),
            ],
          ),
        ],
      );
      await ctx.workoutRepo.create(workout1);
      await ctx.workoutRepo.markAsCompleted('wh-old');

      // Second workout with Bench Press — current, not logged yet
      final workout2 = TestDataFactory.createWorkout(
        id: 'wh-new',
        trainingCycleId: 'cycle-history',
        periodNumber: 2,
        dayNumber: 1,
        exercises: [
          TestDataFactory.createExercise(
            id: 'ex-new',
            workoutId: 'wh-new',
            name: 'Bench Press',
            orderIndex: 0,
            sets: [
              TestDataFactory.createSet(id: 'set-new-1', setNumber: 1),
            ],
          ),
        ],
      );
      await ctx.workoutRepo.create(workout2);

      // ExerciseHistoryService should find the old performance
      final previous = await ctx.historyService.getPreviousPerformance(
        'Bench Press',
        'ex-new',
      );
      expect(previous, isNotNull);
      expect(previous!.name, 'Bench Press');
      expect(previous.sets.isNotEmpty, isTrue);
      expect(previous.sets[0].weight, 135.0);
    });

    test('workout stream emits updates reactively', () async {
      final cycle = TestDataFactory.createCycle(id: 'cycle-stream');
      await ctx.cycleRepo.create(cycle);

      final stream = ctx.workoutRepo.watchByTrainingCycleId('cycle-stream');

      // First emission should be empty
      final first = await stream.first;
      expect(first, isEmpty);

      // Create a workout and wait for the next emission
      final workout = TestDataFactory.createFullWorkout(
        id: 'ws-1',
        trainingCycleId: 'cycle-stream',
      );
      await ctx.workoutRepo.create(workout);

      final second = await stream.first;
      expect(second.length, 1);
      expect(second[0].id, 'ws-1');
    });
  });
}
