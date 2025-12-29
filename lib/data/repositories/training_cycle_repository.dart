import 'package:hive/hive.dart';

import '../../core/constants/enums.dart';
import '../models/training_cycle.dart';

/// Repository for TrainingCycle CRUD operations
class TrainingCycleRepository {
  final Box<TrainingCycle> _box;

  TrainingCycleRepository(this._box);

  /// Get the underlying Hive box (for watching changes)
  Box<TrainingCycle> get box => _box;

  /// Get all trainingCycles
  List<TrainingCycle> getAll() {
    return _box.values.toList();
  }

  /// Get trainingCycles by status
  List<TrainingCycle> getByStatus(TrainingCycleStatus status) {
    return _box.values.where((m) => m.status == status).toList();
  }

  /// Get current (active) trainingCycle
  TrainingCycle? getCurrent() {
    try {
      return _box.values.firstWhere(
        (m) => m.status == TrainingCycleStatus.current,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get draft trainingCycles
  List<TrainingCycle> getDrafts() {
    return getByStatus(TrainingCycleStatus.draft);
  }

  /// Get completed trainingCycles
  List<TrainingCycle> getCompleted() {
    return getByStatus(TrainingCycleStatus.completed);
  }

  /// Get trainingCycle by ID
  TrainingCycle? getById(String id) {
    return _box.get(id);
  }

  /// Create a new trainingCycle
  Future<void> create(TrainingCycle trainingCycle) async {
    await _box.put(trainingCycle.id, trainingCycle);
  }

  /// Update an existing trainingCycle
  Future<void> update(TrainingCycle trainingCycle) async {
    await _box.put(trainingCycle.id, trainingCycle);
  }

  /// Delete a trainingCycle
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Set a trainingCycle as current (and deactivate others)
  Future<void> setAsCurrent(String id) async {
    final trainingCycle = getById(id);
    if (trainingCycle == null) return;

    // Deactivate all other trainingCycles
    final all = getAll();
    for (final m in all) {
      if (m.id != id && m.status == TrainingCycleStatus.current) {
        await update(m.copyWith(status: TrainingCycleStatus.draft));
      }
    }

    // Activate the selected trainingCycle
    await update(trainingCycle.start());
  }

  /// Complete a trainingCycle
  Future<void> complete(String id) async {
    final trainingCycle = getById(id);
    if (trainingCycle == null) return;

    await update(trainingCycle.complete());
  }

  /// Duplicate a trainingCycle
  Future<TrainingCycle> duplicate(String id, String newName) async {
    final original = getById(id);
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
      // Don't copy workouts - user will need to generate new ones
    );

    await create(duplicated);
    return duplicated;
  }

  /// Get total count
  int get count => _box.length;

  /// Check if any trainingCycle exists
  bool get isEmpty => _box.isEmpty;

  /// Check if any trainingCycles exist
  bool get isNotEmpty => _box.isNotEmpty;

  /// Clear all trainingCycles (use with caution!)
  Future<void> clear() async {
    await _box.clear();
  }

  /// Get trainingCycles sorted by creation date (newest first)
  List<TrainingCycle> getAllSorted() {
    final all = getAll();
    all.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return all;
  }

  /// Search trainingCycles by name
  List<TrainingCycle> searchByName(String query) {
    if (query.isEmpty) return getAll();

    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((m) => m.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get trainingCycles by template name
  List<TrainingCycle> getByTemplate(String templateName) {
    return _box.values.where((m) => m.templateName == templateName).toList();
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    final all = getAll();
    return {
      'total': all.length,
      'draft': getDrafts().length,
      'current': getCurrent() != null ? 1 : 0,
      'completed': getCompleted().length,
    };
  }
}
