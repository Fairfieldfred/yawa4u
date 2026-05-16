import '../../core/constants/enums.dart';
import '../database/daos/training_cycle_dao.dart';
import '../database/mappers/entity_mappers.dart';
import '../models/training_cycle.dart';

/// Repository for TrainingCycle CRUD operations using Drift
class TrainingCycleRepository {
  final TrainingCycleDao _dao;

  TrainingCycleRepository(this._dao);

  /// Watch all training cycles (for reactive UI updates)
  Stream<List<TrainingCycle>> watchAll() {
    return _dao.watchAllSorted().map(
      (rows) => rows.map((row) => TrainingCycleMapper.fromRow(row)).toList(),
    );
  }

  /// Get all trainingCycles
  Future<List<TrainingCycle>> getAll() async {
    final rows = await _dao.getAllSorted();
    return rows.map((row) => TrainingCycleMapper.fromRow(row)).toList();
  }

  /// Get trainingCycles by status (uses indexed DB query)
  Future<List<TrainingCycle>> getByStatus(TrainingCycleStatus status) async {
    final rows = await _dao.getByStatus(status.index);
    return rows.map((row) => TrainingCycleMapper.fromRow(row)).toList();
  }

  /// Get current (active) trainingCycle
  Future<TrainingCycle?> getCurrent() async {
    final row = await _dao.getCurrent();
    return row != null ? TrainingCycleMapper.fromRow(row) : null;
  }

  /// Get draft trainingCycles
  Future<List<TrainingCycle>> getDrafts() async {
    return getByStatus(TrainingCycleStatus.draft);
  }

  /// Get completed trainingCycles
  Future<List<TrainingCycle>> getCompleted() async {
    return getByStatus(TrainingCycleStatus.completed);
  }

  /// Get trainingCycle by ID
  Future<TrainingCycle?> getById(String id) async {
    final row = await _dao.getByUuid(id);
    return row != null ? TrainingCycleMapper.fromRow(row) : null;
  }

  /// Create a new trainingCycle
  Future<void> create(TrainingCycle trainingCycle) async {
    final companion = TrainingCycleMapper.toCompanion(trainingCycle);
    await _dao.insertCycle(companion);
  }

  /// Update an existing trainingCycle
  Future<void> update(TrainingCycle trainingCycle) async {
    final companion = TrainingCycleMapper.toCompanion(trainingCycle);
    await _dao.updateByUuid(trainingCycle.id, companion);
  }

  /// Delete a trainingCycle
  Future<void> delete(String id) async {
    await _dao.deleteByUuid(id);
  }

  /// Delete all trainingCycles
  Future<void> deleteAll() async {
    await _dao.deleteAll();
  }

  /// Set a trainingCycle as current (and deactivate others).
  /// Use this for the "replace" flow where only one cycle should be active.
  Future<void> setAsCurrent(String id) async {
    final trainingCycle = await getById(id);
    if (trainingCycle == null) return;

    // Deactivate all current trainingCycles in one query
    await _dao.deactivateAllCurrent();

    // Activate the selected trainingCycle
    await update(trainingCycle.start());
  }

  /// Activate a trainingCycle WITHOUT deactivating other current cycles.
  /// Use this for the "stack alongside" flow where multiple cycles run
  /// simultaneously.
  Future<void> stackAsCurrent(String id) async {
    final trainingCycle = await getById(id);
    if (trainingCycle == null) return;

    await update(trainingCycle.start());
  }

  /// Complete a trainingCycle
  Future<void> complete(String id) async {
    final trainingCycle = await getById(id);
    if (trainingCycle == null) return;

    await update(trainingCycle.complete());
  }

  /// Duplicate a trainingCycle
  Future<TrainingCycle> duplicate(String id, String newName) async {
    final original = await getById(id);
    if (original == null) {
      throw ArgumentError('TrainingCycle not found: $id');
    }

    final duplicated = TrainingCycle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      periodsTotal: original.periodsTotal,
      daysPerPeriod: original.daysPerPeriod,
      recoveryPeriod: original.recoveryPeriod,
      gender: original.gender,
      muscleGroupPriorities: original.muscleGroupPriorities,
      templateName: original.templateName,
      notes: original.notes,
      status: TrainingCycleStatus.draft,
    );

    await create(duplicated);
    return duplicated;
  }

  /// Get total count (uses SQL COUNT instead of loading all rows)
  Future<int> count() async {
    return _dao.countRows();
  }

  /// Clear all trainingCycles (use with caution!)
  Future<void> clear() async {
    await _dao.deleteAll();
  }

  /// Get trainingCycles sorted by creation date (newest first)
  ///
  /// Note: [getAll] already returns sorted results from the DAO.
  Future<List<TrainingCycle>> getAllSorted() => getAll();

  /// Search trainingCycles by name (uses indexed DB query)
  Future<List<TrainingCycle>> searchByName(String query) async {
    if (query.isEmpty) return getAll();
    final rows = await _dao.searchByName(query);
    return rows.map((row) => TrainingCycleMapper.fromRow(row)).toList();
  }

  /// Get trainingCycles by template name (uses DB query)
  Future<List<TrainingCycle>> getByTemplate(String templateName) async {
    final rows = await _dao.getByTemplateName(templateName);
    return rows.map((row) => TrainingCycleMapper.fromRow(row)).toList();
  }
}
