import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yawa4u/core/constants/enums.dart';
import 'package:yawa4u/data/database/database.dart';
import 'package:yawa4u/data/repositories/cycle_period_repository.dart';

import '../../helpers/test_fixtures.dart';

void main() {
  late AppDatabase db;
  late CyclePeriodRepository repo;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CyclePeriodRepository(db.cyclePeriodDao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertTrainingCycle(String uuid) async {
    await db.trainingCycleDao.insertCycle(
      TrainingCyclesCompanion.insert(
        uuid: uuid,
        name: 'Test Cycle',
        periodsTotal: 4,
        daysPerPeriod: 5,
        recoveryPeriod: 4,
        status: 0,
        createdDate: DateTime.now(),
      ),
    );
  }

  group('CRUD', () {
    test('create and getByTrainingCycleId', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(
        TestFixtures.createCyclePeriod(
          id: 'p1',
          trainingCycleId: cycleId,
          periodNumber: 1,
          phase: TrainingPhase.base,
        ),
      );
      await repo.create(
        TestFixtures.createCyclePeriod(
          id: 'p2',
          trainingCycleId: cycleId,
          periodNumber: 2,
          phase: TrainingPhase.build,
        ),
      );

      final periods = await repo.getByTrainingCycleId(cycleId);
      expect(periods, hasLength(2));
    });

    test('getByCycleAndPeriod returns specific period', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(
        TestFixtures.createCyclePeriod(
          id: 'p1',
          trainingCycleId: cycleId,
          periodNumber: 1,
          phase: TrainingPhase.base,
        ),
      );
      await repo.create(
        TestFixtures.createCyclePeriod(
          id: 'p2',
          trainingCycleId: cycleId,
          periodNumber: 2,
          phase: TrainingPhase.build,
        ),
      );

      final period = await repo.getByCycleAndPeriod(cycleId, 2);
      expect(period, isNotNull);
      expect(period!.phase, equals(TrainingPhase.build));
      expect(period.periodNumber, equals(2));
    });

    test('getByCycleAndPeriod returns null for nonexistent', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      final period = await repo.getByCycleAndPeriod(cycleId, 99);
      expect(period, isNull);
    });

    test('update modifies period', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      final period = TestFixtures.createCyclePeriod(
        id: 'p1',
        trainingCycleId: cycleId,
        periodNumber: 1,
        phase: TrainingPhase.base,
      );
      await repo.create(period);

      await repo.update(period.copyWith(phase: TrainingPhase.peak));
      final loaded = await repo.getByCycleAndPeriod(cycleId, 1);
      expect(loaded!.phase, equals(TrainingPhase.peak));
    });

    test('delete removes period', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(
        TestFixtures.createCyclePeriod(
          id: 'p1',
          trainingCycleId: cycleId,
          periodNumber: 1,
        ),
      );
      await repo.delete('p1');

      final periods = await repo.getByTrainingCycleId(cycleId);
      expect(periods, isEmpty);
    });
  });

  group('Phase assignment', () {
    test('strength cycles can have null phase', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      await repo.create(
        TestFixtures.createCyclePeriod(
          id: 'p1',
          trainingCycleId: cycleId,
          periodNumber: 1,
        ),
      );

      final loaded = await repo.getByCycleAndPeriod(cycleId, 1);
      expect(loaded!.phase, isNull);
    });

    test('cardio cycles can have all TrainingPhase values', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      for (var i = 0; i < TrainingPhase.values.length; i++) {
        await repo.create(
          TestFixtures.createCyclePeriod(
            id: 'p${i + 1}',
            trainingCycleId: cycleId,
            periodNumber: i + 1,
            phase: TrainingPhase.values[i],
          ),
        );
      }

      final periods = await repo.getByTrainingCycleId(cycleId);
      expect(periods, hasLength(TrainingPhase.values.length));
    });
  });

  group('Stream', () {
    test('watchByTrainingCycleId emits on changes', () async {
      final cycleId = 'cycle-1';
      await insertTrainingCycle(cycleId);

      final stream = repo.watchByTrainingCycleId(cycleId);
      expect(await stream.first, isEmpty);

      await repo.create(
        TestFixtures.createCyclePeriod(
          id: 'p1',
          trainingCycleId: cycleId,
          periodNumber: 1,
        ),
      );

      final result = await stream.first;
      expect(result, hasLength(1));
    });
  });
}
