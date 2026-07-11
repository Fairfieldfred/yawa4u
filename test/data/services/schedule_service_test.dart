import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/sports.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/session_repository.dart';
import 'package:yawa4u/data/repositories/training_cycle_repository.dart';
import 'package:yawa4u/data/repositories/workout_repository.dart';
import 'package:yawa4u/data/services/schedule_service.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late TrainingCycleRepository cycleRepo;
  late WorkoutRepository workoutRepo;
  late SessionRepository sessionRepo;
  late ScheduleService service;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    cycleRepo = TrainingCycleRepository(db.trainingCycleDao);
    sessionRepo = SessionRepository(
      db.sessionDao,
      db.exerciseDao,
      db.exerciseSetDao,
      db.sessionCardioDao,
      db.sessionIntervalDao,
      db.sessionSampleDao,
      db.cardioFeedbackDao,
    );
    workoutRepo = WorkoutRepository(sessionRepo, db.exerciseDao);
    service = ScheduleService(
      cycleRepository: cycleRepo,
      workoutRepository: workoutRepo,
      sessionRepository: sessionRepo,
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
    await workoutRepo.create(
      TestFixtures.createWorkout(
        id: id,
        trainingCycleId: cycleId,
        periodNumber: period,
        dayNumber: day,
        scheduledDate: scheduledDate,
        exercises: [],
      ),
    );
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

  group('removeRestDay', () {
    test('shifts workouts after rest day backward by one day', () async {
      final startDate = DateTime(2024, 3, 1);
      await insertCycle(startDate: startDate, daysPerPeriod: 4);

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
        scheduledDate: DateTime(2024, 3, 3), // gap on Mar 2
      );
      await insertWorkout(
        id: 'w3',
        period: 1,
        day: 3,
        scheduledDate: DateTime(2024, 3, 4),
      );

      // Remove the rest day on March 2 — w2 and w3 should shift back
      await service.removeRestDay(
        cycleId: 'cycle-1',
        restDayDate: DateTime(2024, 3, 2),
      );

      final w1 = await workoutRepo.getById('w1');
      final w2 = await workoutRepo.getById('w2');
      final w3 = await workoutRepo.getById('w3');

      // w1 is on or before the rest day — unchanged
      expect(w1!.scheduledDate, DateTime(2024, 3, 1));
      // w2 and w3 shift backward by 1
      expect(w2!.scheduledDate, DateTime(2024, 3, 2));
      expect(w3!.scheduledDate, DateTime(2024, 3, 3));
    });

    test('leaves earlier workouts untouched', () async {
      final startDate = DateTime(2024, 3, 1);
      await insertCycle(startDate: startDate, daysPerPeriod: 4);

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

      // Remove a rest day on March 5 — no workouts are after it
      await service.removeRestDay(
        cycleId: 'cycle-1',
        restDayDate: DateTime(2024, 3, 5),
      );

      final w1 = await workoutRepo.getById('w1');
      final w2 = await workoutRepo.getById('w2');

      expect(w1!.scheduledDate, DateTime(2024, 3, 1));
      expect(w2!.scheduledDate, DateTime(2024, 3, 2));
    });

    test('returns snapshot for undo', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 3);
      await insertWorkout(
        id: 'w1',
        period: 1,
        day: 1,
        scheduledDate: DateTime(2024, 3, 1),
      );

      final snapshot = await service.removeRestDay(
        cycleId: 'cycle-1',
        restDayDate: DateTime(2024, 3, 2),
      );

      expect(snapshot.cycleStartDate, DateTime(2024, 3, 1));
      expect(snapshot.workoutSnapshots.length, 1);
      expect(snapshot.description, 'Removed rest day');
    });
  });

  group('moveCardioToDate', () {
    test('updates session date, period, and day', () async {
      final startDate = DateTime(2024, 3, 1);
      await insertCycle(startDate: startDate, daysPerPeriod: 5);

      final cardio = TestFixtures.createCardioSession(
        id: 'cardio-1',
        trainingCycleId: 'cycle-1',
        sport: Sport.run,
        periodNumber: 1,
        dayNumber: 1,
        scheduledDate: DateTime(2024, 3, 1),
      );
      await sessionRepo.createCardio(cardio);

      // Move to March 8 → period 2, day 3 (0-indexed: day 7 from start)
      // daysFromStart=7, period=(7~/5)+1=2, day=(7%5)+1=3
      await service.moveCardioToDate(
        cycleId: 'cycle-1',
        session: cardio,
        targetDate: DateTime(2024, 3, 8),
      );

      final updated = await sessionRepo.getById('cardio-1');
      expect(updated, isNotNull);
      expect(updated!.scheduledDate, DateTime(2024, 3, 8));
      expect(updated.periodNumber, 2);
      expect(updated.dayNumber, 3);
    });

    test('falls back to createdDate when cycle has no startDate', () async {
      // Insert cycle without start date — moveCardioToDate uses
      // cycle.startDate ?? cycle.createdDate as the anchor.
      await insertCycle(startDate: null, daysPerPeriod: 5);

      // We need to fetch the cycle to get its createdDate
      final cycle = await cycleRepo.getById('cycle-1');
      final createdDate = cycle!.createdDate;

      final cardio = TestFixtures.createCardioSession(
        id: 'cardio-2',
        trainingCycleId: 'cycle-1',
        sport: Sport.bike,
        periodNumber: 1,
        dayNumber: 1,
      );
      await sessionRepo.createCardio(cardio);

      // Target 10 days after createdDate
      final target = DateTime(
        createdDate.year,
        createdDate.month,
        createdDate.day + 10,
      );

      await service.moveCardioToDate(
        cycleId: 'cycle-1',
        session: cardio,
        targetDate: target,
      );

      final updated = await sessionRepo.getById('cardio-2');
      expect(updated, isNotNull);
      // period = (10 ~/ 5) + 1 = 3, day = (10 % 5) + 1 = 1
      expect(updated!.periodNumber, 3);
      expect(updated.dayNumber, 1);
    });
  });

  group('drag-drop undo snapshots', () {
    test('multi-cycle undo restores exact prior scheduledDates for every stacked cycle', () async {
      // Two stacked cycles active over the same dates.
      await insertCycle(id: 'cycle-a', startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);
      await insertCycle(id: 'cycle-b', startDate: DateTime(2024, 3, 2), daysPerPeriod: 7);

      final wA = TestFixtures.createWorkout(
        id: 'w-a',
        trainingCycleId: 'cycle-a',
        periodNumber: 1,
        dayNumber: 3,
        scheduledDate: DateTime(2024, 3, 3),
      );
      final wB = TestFixtures.createWorkout(
        id: 'w-b',
        trainingCycleId: 'cycle-b',
        periodNumber: 1,
        dayNumber: 2,
        scheduledDate: DateTime(2024, 3, 3),
      );
      await workoutRepo.create(wA);
      await workoutRepo.create(wB);

      // Insert a rest day before March 3 in BOTH cycles (what the calendar
      // does for stacked cycles), keeping one snapshot per cycle.
      final snapA = await service.insertDayBeforeDate(cycleId: 'cycle-a', restDayDate: DateTime(2024, 3, 3));
      final snapB = await service.insertDayBeforeDate(cycleId: 'cycle-b', restDayDate: DateTime(2024, 3, 3));
      expect(snapA, isNotNull);
      expect(snapB, isNotNull);

      // Both workouts shifted off March 3.
      expect((await workoutRepo.getById('w-a'))!.scheduledDate, isNot(DateTime(2024, 3, 3)));
      expect((await workoutRepo.getById('w-b'))!.scheduledDate, isNot(DateTime(2024, 3, 3)));

      // Undo both (what CalendarUndoNotifier.undo does).
      await service.restoreSnapshot('cycle-a', snapA!);
      await service.restoreSnapshot('cycle-b', snapB!);

      expect((await workoutRepo.getById('w-a'))!.scheduledDate, DateTime(2024, 3, 3));
      expect((await workoutRepo.getById('w-b'))!.scheduledDate, DateTime(2024, 3, 3));
    });

    test('moveCardioToDate returns a snapshot that restores the prior schedule', () async {
      final startDate = DateTime(2024, 3, 1);
      await insertCycle(startDate: startDate, daysPerPeriod: 5);

      final cardio = TestFixtures.createCardioSession(
        id: 'cardio-undo',
        trainingCycleId: 'cycle-1',
        sport: Sport.run,
        periodNumber: 1,
        dayNumber: 2,
        scheduledDate: DateTime(2024, 3, 2),
      );
      await sessionRepo.createCardio(cardio);

      final snapshot = await service.moveCardioToDate(
        cycleId: 'cycle-1',
        session: cardio,
        targetDate: DateTime(2024, 3, 8),
      );

      var moved = await sessionRepo.getById('cardio-undo');
      expect(moved!.scheduledDate, DateTime(2024, 3, 8));

      await service.restoreSnapshot('cycle-1', snapshot);

      moved = await sessionRepo.getById('cardio-undo');
      expect(moved!.scheduledDate, DateTime(2024, 3, 2));
      expect(moved.periodNumber, 1);
      expect(moved.dayNumber, 2);
    });

    test('moveExerciseToDate snapshot restores the exercise to its source workout', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);

      final exercise = TestFixtures.createExercise(
        id: 'ex-undo',
        workoutId: 'w-src',
        name: 'Bench Press',
        orderIndex: 0,
      );
      final source = TestFixtures.createWorkout(
        id: 'w-src',
        trainingCycleId: 'cycle-1',
        periodNumber: 1,
        dayNumber: 1,
        scheduledDate: DateTime(2024, 3, 1),
        exercises: [exercise],
      );
      await workoutRepo.create(source);

      final snapshot = await service.moveExerciseToDate(
        cycleId: 'cycle-1',
        sourceWorkoutId: 'w-src',
        exerciseId: 'ex-undo',
        targetDate: DateTime(2024, 3, 4),
      );

      var sourceNow = await workoutRepo.getById('w-src');
      expect(sourceNow!.exercises, isEmpty);

      await service.restoreSnapshot('cycle-1', snapshot);

      sourceNow = await workoutRepo.getById('w-src');
      expect(sourceNow!.exercises.map((e) => e.id), ['ex-undo']);
    });
  });

  group('reorderExerciseWithinDay', () {
    test('reorders exercises across workouts on the same day', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);

      // Create two workouts on day 1 with exercises
      final w1 = TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: 'cycle-1',
        periodNumber: 1,
        dayNumber: 1,
        exercises: [
          TestFixtures.createExercise(
            id: 'e1',
            workoutId: 'w1',
            name: 'Bench Press',
            orderIndex: 0,
          ),
          TestFixtures.createExercise(
            id: 'e2',
            workoutId: 'w1',
            name: 'Incline Press',
            orderIndex: 1,
          ),
        ],
      );
      await workoutRepo.create(w1);

      final w2 = TestFixtures.createWorkout(
        id: 'w2',
        trainingCycleId: 'cycle-1',
        periodNumber: 1,
        dayNumber: 1,
        label: 'Triceps',
        exercises: [
          TestFixtures.createExercise(
            id: 'e3',
            workoutId: 'w2',
            name: 'Tricep Pushdown',
            orderIndex: 0,
          ),
        ],
      );
      await workoutRepo.create(w2);

      // Flat list: [e1(0), e2(1), e3(2)]
      // Move e3 (index 2) to index 0 → [e3(0), e1(1), e2(2)]
      await service.reorderExerciseWithinDay(
        cycleId: 'cycle-1',
        periodNumber: 1,
        dayNumber: 1,
        oldIndex: 2,
        newIndex: 0,
      );

      final updatedW1 = await workoutRepo.getById('w1');
      final updatedW2 = await workoutRepo.getById('w2');

      // e1 should now be at orderIndex 1, e2 at 2 (within w1)
      final e1 = updatedW1!.exercises.firstWhere((e) => e.id == 'e1');
      final e2 = updatedW1.exercises.firstWhere((e) => e.id == 'e2');
      expect(e1.orderIndex, 1);
      expect(e2.orderIndex, 2);

      // e3 stays in w2 but gets orderIndex 0
      final e3 = updatedW2!.exercises.firstWhere((e) => e.id == 'e3');
      expect(e3.orderIndex, 0);
    });

    test('no-op when indices are out of bounds', () async {
      await insertCycle(startDate: DateTime(2024, 3, 1), daysPerPeriod: 5);

      final w1 = TestFixtures.createWorkout(
        id: 'w1',
        trainingCycleId: 'cycle-1',
        periodNumber: 1,
        dayNumber: 1,
        exercises: [
          TestFixtures.createExercise(
            id: 'e1',
            workoutId: 'w1',
            name: 'Squat',
            orderIndex: 0,
          ),
        ],
      );
      await workoutRepo.create(w1);

      // Out-of-bounds oldIndex — should return without error
      await service.reorderExerciseWithinDay(
        cycleId: 'cycle-1',
        periodNumber: 1,
        dayNumber: 1,
        oldIndex: 5,
        newIndex: 0,
      );

      final updated = await workoutRepo.getById('w1');
      final e1 = updated!.exercises.firstWhere((e) => e.id == 'e1');
      expect(e1.orderIndex, 0); // unchanged
    });
  });
}
