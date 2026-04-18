import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'cycle_period_dao.g.dart';

/// Data Access Object for the [CyclePeriods] table.
///
/// One row per (trainingCycle, periodNumber). Holds the cardio
/// [TrainingPhase] per period and the natural home for future coach notes.
@DriftAccessor(tables: [CyclePeriods])
class CyclePeriodDao extends DatabaseAccessor<AppDatabase>
    with _$CyclePeriodDaoMixin {
  CyclePeriodDao(super.db);

  Future<List<CyclePeriod>> getAll() => select(cyclePeriods).get();

  Stream<List<CyclePeriod>> watchAll() => select(cyclePeriods).watch();

  Future<List<CyclePeriod>> getByTrainingCycleUuid(String trainingCycleUuid) {
    return (select(cyclePeriods)
          ..where((p) => p.trainingCycleUuid.equals(trainingCycleUuid))
          ..orderBy([(p) => OrderingTerm.asc(p.periodNumber)]))
        .get();
  }

  Stream<List<CyclePeriod>> watchByTrainingCycleUuid(
    String trainingCycleUuid,
  ) {
    return (select(cyclePeriods)
          ..where((p) => p.trainingCycleUuid.equals(trainingCycleUuid))
          ..orderBy([(p) => OrderingTerm.asc(p.periodNumber)]))
        .watch();
  }

  /// Returns the single cycle-period row for the given (cycle, periodNumber)
  /// or null if none exists yet.
  Future<CyclePeriod?> getByCycleAndPeriod(
    String trainingCycleUuid,
    int periodNumber,
  ) {
    return (select(cyclePeriods)..where(
          (p) =>
              p.trainingCycleUuid.equals(trainingCycleUuid) &
              p.periodNumber.equals(periodNumber),
        ))
        .getSingleOrNull();
  }

  Future<CyclePeriod?> getByUuid(String uuid) {
    return (select(
      cyclePeriods,
    )..where((p) => p.uuid.equals(uuid))).getSingleOrNull();
  }

  Future<int> insertPeriod(CyclePeriodsCompanion row) {
    return into(cyclePeriods).insert(row);
  }

  Future<void> insertAll(List<CyclePeriodsCompanion> rows) {
    return batch((b) {
      b.insertAll(cyclePeriods, rows);
    });
  }

  Future<int> updateByUuid(String uuid, CyclePeriodsCompanion row) {
    return (update(
      cyclePeriods,
    )..where((p) => p.uuid.equals(uuid))).write(row);
  }

  Future<int> deleteByUuid(String uuid) {
    return (delete(cyclePeriods)..where((p) => p.uuid.equals(uuid))).go();
  }

  Future<int> deleteByTrainingCycleUuid(String trainingCycleUuid) {
    return (delete(
      cyclePeriods,
    )..where((p) => p.trainingCycleUuid.equals(trainingCycleUuid))).go();
  }

  Future<int> deleteAll() => delete(cyclePeriods).go();
}
