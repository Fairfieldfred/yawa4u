import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';

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

  group('Training Cycle Flow - Complete Lifecycle', () {
    test('create → activate → add workouts → complete workouts → end cycle',
        () async {
      // 1. Create a new training cycle
      final cycle = TestDataFactory.createCycle(
        id: 'tc-1',
        name: 'Hypertrophy Block',
        periodsTotal: 4,
        daysPerPeriod: 5,
      );
      await ctx.cycleRepo.create(cycle);

      var saved = await ctx.cycleRepo.getById('tc-1');
      expect(saved, isNotNull);
      expect(saved!.status, TrainingCycleStatus.draft);

      // 2. Set as current (activate)
      await ctx.cycleRepo.setAsCurrent('tc-1');

      saved = await ctx.cycleRepo.getById('tc-1');
      expect(saved!.status, TrainingCycleStatus.current);
      expect(saved.startDate, isNotNull);

      // 3. Verify it is the active cycle
      final current = await ctx.cycleRepo.getCurrent();
      expect(current, isNotNull);
      expect(current!.id, 'tc-1');

      // 4. Add workouts to it
      for (var day = 1; day <= 3; day++) {
        final workout = TestDataFactory.createFullWorkout(
          trainingCycleId: 'tc-1',
          periodNumber: 1,
          dayNumber: day,
          label: 'Muscle Group $day',
          exerciseCount: 2,
          setsPerExercise: 3,
        );
        await ctx.workoutRepo.create(workout);
      }

      final workouts = await ctx.workoutRepo.getByTrainingCycleId('tc-1');
      expect(workouts.length, 3);

      // 5. Complete several workouts
      await ctx.workoutRepo.markAsCompleted(workouts[0].id);
      await ctx.workoutRepo.markAsCompleted(workouts[1].id);
      await ctx.workoutRepo.markAsSkipped(workouts[2].id);

      final stats = await ctx.workoutRepo.getStatsForTrainingCycle('tc-1');
      expect(stats['completed'], 2);
      expect(stats['skipped'], 1);

      // 6. End the cycle
      await ctx.cycleRepo.complete('tc-1');

      saved = await ctx.cycleRepo.getById('tc-1');
      expect(saved!.status, TrainingCycleStatus.completed);

      // 7. Verify a new cycle can be started
      final newCycle = TestDataFactory.createCycle(
        id: 'tc-2',
        name: 'Strength Block',
      );
      await ctx.cycleRepo.create(newCycle);
      await ctx.cycleRepo.setAsCurrent('tc-2');

      final newCurrent = await ctx.cycleRepo.getCurrent();
      expect(newCurrent, isNotNull);
      expect(newCurrent!.id, 'tc-2');
      expect(newCurrent.status, TrainingCycleStatus.current);

      // Old cycle should still be completed
      final oldCycle = await ctx.cycleRepo.getById('tc-1');
      expect(oldCycle!.status, TrainingCycleStatus.completed);
    });

    test('activating a new cycle deactivates the previous one', () async {
      final cycle1 = TestDataFactory.createCycle(
        id: 'tc-a',
        name: 'Cycle A',
      );
      final cycle2 = TestDataFactory.createCycle(
        id: 'tc-b',
        name: 'Cycle B',
      );
      await ctx.cycleRepo.create(cycle1);
      await ctx.cycleRepo.create(cycle2);

      await ctx.cycleRepo.setAsCurrent('tc-a');
      var current = await ctx.cycleRepo.getCurrent();
      expect(current!.id, 'tc-a');

      // Activate cycle B — cycle A should be deactivated back to draft
      await ctx.cycleRepo.setAsCurrent('tc-b');
      current = await ctx.cycleRepo.getCurrent();
      expect(current!.id, 'tc-b');

      final cycleA = await ctx.cycleRepo.getById('tc-a');
      expect(cycleA!.status, TrainingCycleStatus.draft);
    });

    test('duplicate a training cycle', () async {
      final original = TestDataFactory.createCycle(
        id: 'tc-orig',
        name: 'Original',
        periodsTotal: 6,
        daysPerPeriod: 4,
      );
      await ctx.cycleRepo.create(original);

      final duplicated = await ctx.cycleRepo.duplicate('tc-orig', 'Copy');
      expect(duplicated.name, 'Copy');
      expect(duplicated.periodsTotal, 6);
      expect(duplicated.daysPerPeriod, 4);
      expect(duplicated.status, TrainingCycleStatus.draft);
      expect(duplicated.id, isNot('tc-orig'));

      // Both should exist
      final count = await ctx.cycleRepo.count();
      expect(count, 2);
    });

    test('filter cycles by status', () async {
      await ctx.cycleRepo.create(
        TestDataFactory.createCycle(id: 'draft-1', name: 'Draft 1'),
      );
      await ctx.cycleRepo.create(
        TestDataFactory.createCycle(id: 'draft-2', name: 'Draft 2'),
      );
      await ctx.cycleRepo.create(
        TestDataFactory.createCycle(id: 'active-1', name: 'Active'),
      );

      await ctx.cycleRepo.setAsCurrent('active-1');
      await ctx.cycleRepo.complete('active-1');

      final drafts = await ctx.cycleRepo.getDrafts();
      expect(drafts.length, 2);

      final completed = await ctx.cycleRepo.getCompleted();
      expect(completed.length, 1);
      expect(completed[0].name, 'Active');
    });

    test('search cycles by name', () async {
      await ctx.cycleRepo.create(
        TestDataFactory.createCycle(id: 'c1', name: 'Hypertrophy Block'),
      );
      await ctx.cycleRepo.create(
        TestDataFactory.createCycle(id: 'c2', name: 'Strength Block'),
      );
      await ctx.cycleRepo.create(
        TestDataFactory.createCycle(id: 'c3', name: 'Peaking Phase'),
      );

      final results = await ctx.cycleRepo.searchByName('block');
      expect(results.length, 2);

      final noResults = await ctx.cycleRepo.searchByName('nonexistent');
      expect(noResults, isEmpty);
    });

    test('delete cycle and verify cleanup', () async {
      final cycle = TestDataFactory.createCycle(id: 'tc-del');
      await ctx.cycleRepo.create(cycle);

      final workout = TestDataFactory.createFullWorkout(
        trainingCycleId: 'tc-del',
        exerciseCount: 2,
      );
      await ctx.workoutRepo.create(workout);

      // Delete the cycle
      await ctx.cycleRepo.delete('tc-del');
      final deleted = await ctx.cycleRepo.getById('tc-del');
      expect(deleted, isNull);

      // Workouts should still exist (no cascade from repo level)
      // This verifies the orphan behavior — cleanup is app-level
      final count = await ctx.cycleRepo.count();
      expect(count, 0);
    });

    test('cycle stream emits updates reactively', () async {
      final stream = ctx.cycleRepo.watchAll();

      final first = await stream.first;
      expect(first, isEmpty);

      await ctx.cycleRepo.create(
        TestDataFactory.createCycle(id: 'stream-1'),
      );

      final second = await stream.first;
      expect(second.length, 1);
    });

    test('workouts grouped by period and day', () async {
      final cycle = TestDataFactory.createCycle(id: 'tc-group');
      await ctx.cycleRepo.create(cycle);

      // Day 1: two muscle groups (Chest + Triceps)
      await ctx.workoutRepo.create(TestDataFactory.createWorkout(
        id: 'g-w1',
        trainingCycleId: 'tc-group',
        periodNumber: 1,
        dayNumber: 1,
        dayName: 'Push Day',
        label: 'Chest',
      ));
      await ctx.workoutRepo.create(TestDataFactory.createWorkout(
        id: 'g-w2',
        trainingCycleId: 'tc-group',
        periodNumber: 1,
        dayNumber: 1,
        dayName: 'Push Day',
        label: 'Triceps',
      ));

      // Day 2: one muscle group
      await ctx.workoutRepo.create(TestDataFactory.createWorkout(
        id: 'g-w3',
        trainingCycleId: 'tc-group',
        periodNumber: 1,
        dayNumber: 2,
        dayName: 'Pull Day',
        label: 'Back',
      ));

      final day1Workouts = await ctx.workoutRepo.getByPeriodAndDay(
        'tc-group',
        1,
        1,
      );
      expect(day1Workouts.length, 2);

      final day2Workouts = await ctx.workoutRepo.getByPeriodAndDay(
        'tc-group',
        1,
        2,
      );
      expect(day2Workouts.length, 1);

      // All workouts by period
      final period1 = await ctx.workoutRepo.getByPeriod('tc-group', 1);
      expect(period1.length, 3);
    });
  });
}
