import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'training_cycle_dao.g.dart';

/// Data Access Object for TrainingCycles table
@DriftAccessor(tables: [TrainingCycles])
class TrainingCycleDao extends DatabaseAccessor<AppDatabase>
    with _$TrainingCycleDaoMixin {
  TrainingCycleDao(super.db);

  /// Get all training cycles ordered by creation date descending
  Future<List<TrainingCycle>> getAllSorted() {
    return (select(
      trainingCycles,
    )..orderBy([(t) => OrderingTerm.desc(t.createdDate)])).get();
  }

  /// Watch all training cycles for reactive updates
  Stream<List<TrainingCycle>> watchAllSorted() {
    return (select(
      trainingCycles,
    )..orderBy([(t) => OrderingTerm.desc(t.createdDate)])).watch();
  }

  /// Get a single training cycle by UUID
  Future<TrainingCycle?> getByUuid(String uuid) {
    return (select(
      trainingCycles,
    )..where((t) => t.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Watch a single training cycle by UUID
  Stream<TrainingCycle?> watchByUuid(String uuid) {
    return (select(
      trainingCycles,
    )..where((t) => t.uuid.equals(uuid))).watchSingleOrNull();
  }

  /// Get the current/active training cycle
  Future<TrainingCycle?> getCurrent() {
    return (select(trainingCycles)..where(
          (t) => t.status.equals(1),
        ) // TrainingCycleStatus.current.index
        )
        .getSingleOrNull();
  }

  /// Watch the current/active training cycle
  Stream<TrainingCycle?> watchCurrent() {
    return (select(
      trainingCycles,
    )..where((t) => t.status.equals(1))).watchSingleOrNull();
  }

  /// Insert a new training cycle
  Future<int> insertCycle(TrainingCyclesCompanion cycle) {
    return into(trainingCycles).insert(cycle);
  }

  /// Update an existing training cycle
  Future<bool> updateCycle(TrainingCycle cycle) {
    return update(trainingCycles).replace(cycle);
  }

  /// Update a training cycle by UUID
  Future<int> updateByUuid(String uuid, TrainingCyclesCompanion cycle) {
    return (update(
      trainingCycles,
    )..where((t) => t.uuid.equals(uuid))).write(cycle);
  }

  /// Delete a training cycle by UUID
  Future<int> deleteByUuid(String uuid) {
    return (delete(trainingCycles)..where((t) => t.uuid.equals(uuid))).go();
  }

  /// Get training cycles by status
  Future<List<TrainingCycle>> getByStatus(int status) {
    return (select(trainingCycles)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.desc(t.createdDate)]))
        .get();
  }

  /// Search training cycles by name (case-insensitive partial match)
  Future<List<TrainingCycle>> searchByName(String query) {
    return (select(trainingCycles)
          ..where(
            (t) => t.name.collate(Collate.noCase).like('%$query%'),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdDate)]))
        .get();
  }

  /// Get training cycles by template name
  Future<List<TrainingCycle>> getByTemplateName(String templateName) {
    return (select(trainingCycles)
          ..where((t) => t.templateName.equals(templateName))
          ..orderBy([(t) => OrderingTerm.desc(t.createdDate)]))
        .get();
  }

  /// Deactivate all current training cycles (set status to draft=0)
  Future<int> deactivateAllCurrent() {
    return (update(trainingCycles)..where((t) => t.status.equals(1)))
        .write(const TrainingCyclesCompanion(status: Value(0)));
  }

  /// Get count of training cycles
  Future<int> countRows() async {
    final countExp = trainingCycles.id.count();
    final query = selectOnly(trainingCycles)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp)!;
  }

  /// Delete all training cycles
  Future<int> deleteAll() {
    return delete(trainingCycles).go();
  }
}
