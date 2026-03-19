import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/training_cycle_repository.dart';
import 'package:yawa4u/data/repositories/workout_repository.dart';
import 'package:yawa4u/data/services/schedule_service.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late TrainingCycleRepository cycleRepo;
  late WorkoutRepository workoutRepo;
  late ScheduleService service;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cycleRepo = TrainingCycleRepository(db.trainingCycleDao);
    workoutRepo = WorkoutRepository(
      db.workoutDao,
      db.exerciseDao,
      db.exerciseSetDao,
    );
    service = ScheduleService(
      cycleRepository: cycleRepo,
      workoutRepository: workoutRepo,
    );
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper: insert a training cycle with a start date.
  Future<void> insertCycle({
    String id = 'cycle-1',
    DateTime? startDate,
    int periodsTotal = 4,
    int daysPerPeriod = 5,
  }) async {
    await db.trainingCycleDao.insertCycle(
      TrainingCyclesCompanion.insert(
        uuid: id,
        name: 'Test Cycle',
        periodsTotal: periodsTotal,
        daysPerPeriod: daysPerPeriod,
        recoveryPeriod: periodsTotal,
        status: 1, // current
        createdDate: DateTime.now(),
        startDate: Value(startDate),
      ),
    );
  }

  /// Helper: insert a workout using the repository.
  Future<void> insertWorkout({
    required String id,
    String cycleId = 'cycle-1',
    required int period,
    required int day,
    DateTime? scheduledDate,
  }) async {
    await workoutRepo.create(TestFixtures.createWorkout(
      id: id,
      trainingCycleId: cycleId,
      periodNumber: period,
      dayNumber: day,
      scheduledDate: scheduledDate,
      exercises: [],
    ));
  }

  group('shiftTrainingCycleStart', () {
    test('shifts cycle start date forward', () async {
      final startDate = DateTime(2024, 3, 1);
      await insertCycle(startDate: startDate);
      await insertWorkout(id: 'w1', period: 1, day: 1);

      final snapshot = await service.shiftTrainingCycleStart('cycle-1', 3);

      // Snapshot should contain original state
      expect(snapshot.cycleStartDate, startDate);
      expect(snapshot.workoutSnapshots.length, 1);

      // Cycle start date should be shifted
      final cycle = await cycleRepo.getById('cycle-1');
      expect(cycle!.startDate, DateTime(2024, 3, 4));
    });

    test('shifts cycle start date backward', () async {
      final startDate = DateTime(2024, 3, 10);
      await insertCycle(startDate: startDate);

      await service.shiftTrainingCycleStart('cycle-1', -5);

      final cycle = await cycleRepo.getById('cycle-1');
      expect(cycle!.startDate, DateTime(2024, 3, 5));
    });

    test('throws for non-existent cycle', () async {
      expect(
        () => service.shiftTrainingCycleStart('non-existent', 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('moveWorkout', () {
    test('swap mode swaps two workout positions', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);

      await insertWorkout(id: 'w1', period: 1, day: 1);
      await insertWorkout(id: 'w2', period: 1, day: 2);

      await service.moveWorkout(
        cycleId: 'cycle-1',
        sourcePeriod: 1,
        sourceDay: 1,
        targetPeriod: 1,
        targetDay: 2,
        mode: MoveMode.swap,
      );

      final w1 = await workoutRepo.getById('w1');
      final w2 = await workoutRepo.getById('w2');

      // They should be swapped
      expect(w1!.periodNumber, 1);
      expect(w1.dayNumber, 2);
      expect(w2!.periodNumber, 1);
      expect(w2.dayNumber, 1);
    });

    test('single mode moves only selected workout', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);

      await insertWorkout(id: 'w1', period: 1, day: 1);
      await insertWorkout(id: 'w2', period: 1, day: 2);

      await service.moveWorkout(
        cycleId: 'cycle-1',
        sourcePeriod: 1,
        sourceDay: 1,
        targetPeriod: 2,
        targetDay: 3,
        mode: MoveMode.single,
      );

      final w1 = await workoutRepo.getById('w1');
      final w2 = await workoutRepo.getById('w2');

      expect(w1!.periodNumber, 2);
      expect(w1.dayNumber, 3);
      // w2 should not have moved
      expect(w2!.periodNumber, 1);
      expect(w2.dayNumber, 2);
    });

    test('shift mode moves source and shifts intermediate workouts', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);

      await insertWorkout(id: 'w1', period: 1, day: 1);
      await insertWorkout(id: 'w2', period: 1, day: 2);
      await insertWorkout(id: 'w3', period: 1, day: 3);

      // Move w1 from P1D1 to P1D3
      await service.moveWorkout(
        cycleId: 'cycle-1',
        sourcePeriod: 1,
        sourceDay: 1,
        targetPeriod: 1,
        targetDay: 3,
        mode: MoveMode.shiftSubsequent,
      );

      final w1 = await workoutRepo.getById('w1');
      final w2 = await workoutRepo.getById('w2');
      final w3 = await workoutRepo.getById('w3');

      // w1 should be at P1D3
      expect(w1!.periodNumber, 1);
      expect(w1.dayNumber, 3);
      // w2 and w3 should have shifted back
      expect(w2!.dayNumber, 1);
      expect(w3!.dayNumber, 2);
    });

    test('returns snapshot for undo', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);
      await insertWorkout(id: 'w1', period: 1, day: 1);

      final snapshot = await service.moveWorkout(
        cycleId: 'cycle-1',
        sourcePeriod: 1,
        sourceDay: 1,
        targetPeriod: 1,
        targetDay: 3,
        mode: MoveMode.single,
      );

      expect(snapshot.workoutSnapshots.length, 1);
      expect(snapshot.workoutSnapshots.first.periodNumber, 1);
      expect(snapshot.workoutSnapshots.first.dayNumber, 1);
    });

    test('throws for non-existent source workouts', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);

      expect(
        () => service.moveWorkout(
          cycleId: 'cycle-1',
          sourcePeriod: 1,
          sourceDay: 1,
          targetPeriod: 1,
          targetDay: 2,
          mode: MoveMode.swap,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('insertDayBefore', () {
    test('shifts workout scheduled dates forward by one day', () async {
      final startDate = DateTime(2024, 3, 1);
      await insertCycle(startDate: startDate, daysPerPeriod: 3);

      await insertWorkout(
        id: 'w1',
        period: 1,
        day: 1,
        scheduledDate: DateTime(2024, 3, 1),
      );
      await insertWorkout(
        id: 'w2',
        period: 1,
        day: 2,
        scheduledDate: DateTime(2024, 3, 2),
      );
      await insertWorkout(
        id: 'w3',
        period: 1,
        day: 3,
        scheduledDate: DateTime(2024, 3, 3),
      );

      // Insert rest day before P1D2 — should shift w2 and w3
      await service.insertDayBefore(
        cycleId: 'cycle-1',
        fromPeriod: 1,
        fromDay: 2,
      );

      final w1 = await workoutRepo.getById('w1');
      final w2 = await workoutRepo.getById('w2');
      final w3 = await workoutRepo.getById('w3');

      // w1 is before the insertion point — should not change
      expect(w1!.scheduledDate, DateTime(2024, 3, 1));
      // w2 and w3 shift forward by 1
      expect(w2!.scheduledDate, DateTime(2024, 3, 3));
      expect(w3!.scheduledDate, DateTime(2024, 3, 4));

      // Period/day numbers should NOT change
      expect(w2.periodNumber, 1);
      expect(w2.dayNumber, 2);
    });

    test('throws when cycle has no start date', () async {
      await insertCycle(startDate: null);

      expect(
        () => service.insertDayBefore(
          cycleId: 'cycle-1',
          fromPeriod: 1,
          fromDay: 1,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('restoreSnapshot', () {
    test('restores workout positions from snapshot', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);
      await insertWorkout(id: 'w1', period: 1, day: 1);

      // Move the workout
      final snapshot = await service.moveWorkout(
        cycleId: 'cycle-1',
        sourcePeriod: 1,
        sourceDay: 1,
        targetPeriod: 2,
        targetDay: 3,
        mode: MoveMode.single,
      );

      // Verify it moved
      final moved = await workoutRepo.getById('w1');
      expect(moved!.periodNumber, 2);
      expect(moved.dayNumber, 3);

      // Restore from snapshot
      await service.restoreSnapshot('cycle-1', snapshot);

      final restored = await workoutRepo.getById('w1');
      expect(restored!.periodNumber, 1);
      expect(restored.dayNumber, 1);
    });
  });

  group('ScheduleSnapshot', () {
    test('has timestamp and description', () {
      final snapshot = ScheduleSnapshot(
        cycleStartDate: DateTime(2024, 3, 1),
        workoutSnapshots: [],
        description: 'Test snapshot',
      );
      expect(snapshot.timestamp, isNotNull);
      expect(snapshot.description, 'Test snapshot');
    });
  });

  group('WorkoutSnapshot', () {
    test('fromWorkout captures state', () {
      final workout = TestFixtures.createWorkout(
        id: 'w1',
        periodNumber: 2,
        dayNumber: 3,
        scheduledDate: DateTime(2024, 3, 5),
      );

      final snapshot = WorkoutSnapshot.fromWorkout(workout);
      expect(snapshot.id, 'w1');
      expect(snapshot.periodNumber, 2);
      expect(snapshot.dayNumber, 3);
      expect(snapshot.scheduledDate, DateTime(2024, 3, 5));
    });
  });
}
