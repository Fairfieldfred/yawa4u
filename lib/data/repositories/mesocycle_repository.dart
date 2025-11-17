import 'package:hive/hive.dart';
import '../models/mesocycle.dart';
import '../../core/constants/enums.dart';

/// Repository for Mesocycle CRUD operations
class MesocycleRepository {
  final Box<Mesocycle> _box;

  MesocycleRepository(this._box);

  /// Get the underlying Hive box (for watching changes)
  Box<Mesocycle> get box => _box;

  /// Get all mesocycles
  List<Mesocycle> getAll() {
    return _box.values.toList();
  }

  /// Get mesocycles by status
  List<Mesocycle> getByStatus(MesocycleStatus status) {
    return _box.values.where((m) => m.status == status).toList();
  }

  /// Get current (active) mesocycle
  Mesocycle? getCurrent() {
    try {
      return _box.values.firstWhere((m) => m.status == MesocycleStatus.current);
    } catch (e) {
      return null;
    }
  }

  /// Get draft mesocycles
  List<Mesocycle> getDrafts() {
    return getByStatus(MesocycleStatus.draft);
  }

  /// Get completed mesocycles
  List<Mesocycle> getCompleted() {
    return getByStatus(MesocycleStatus.completed);
  }

  /// Get mesocycle by ID
  Mesocycle? getById(String id) {
    return _box.get(id);
  }

  /// Create a new mesocycle
  Future<void> create(Mesocycle mesocycle) async {
    await _box.put(mesocycle.id, mesocycle);
  }

  /// Update an existing mesocycle
  Future<void> update(Mesocycle mesocycle) async {
    await _box.put(mesocycle.id, mesocycle);
  }

  /// Delete a mesocycle
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Set a mesocycle as current (and deactivate others)
  Future<void> setAsCurrent(String id) async {
    final mesocycle = getById(id);
    if (mesocycle == null) return;

    // Deactivate all other mesocycles
    final all = getAll();
    for (final m in all) {
      if (m.id != id && m.status == MesocycleStatus.current) {
        await update(m.copyWith(status: MesocycleStatus.draft));
      }
    }

    // Activate the selected mesocycle
    await update(mesocycle.start());
  }

  /// Complete a mesocycle
  Future<void> complete(String id) async {
    final mesocycle = getById(id);
    if (mesocycle == null) return;

    await update(mesocycle.complete());
  }

  /// Duplicate a mesocycle
  Future<Mesocycle> duplicate(String id, String newName) async {
    final original = getById(id);
    if (original == null) {
      throw ArgumentError('Mesocycle not found: $id');
    }

    final duplicated = Mesocycle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: newName,
      weeksTotal: original.weeksTotal,
      daysPerWeek: original.daysPerWeek,
      deloadWeek: original.deloadWeek,
      gender: original.gender,
      muscleGroupPriorities: original.muscleGroupPriorities,
      templateName: original.templateName,
      notes: original.notes,
      status: MesocycleStatus.draft,
      // Don't copy workouts - user will need to generate new ones
    );

    await create(duplicated);
    return duplicated;
  }

  /// Get total count
  int get count => _box.length;

  /// Check if any mesocycle exists
  bool get isEmpty => _box.isEmpty;

  /// Check if any mesocycles exist
  bool get isNotEmpty => _box.isNotEmpty;

  /// Clear all mesocycles (use with caution!)
  Future<void> clear() async {
    await _box.clear();
  }

  /// Get mesocycles sorted by creation date (newest first)
  List<Mesocycle> getAllSorted() {
    final all = getAll();
    all.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return all;
  }

  /// Search mesocycles by name
  List<Mesocycle> searchByName(String query) {
    if (query.isEmpty) return getAll();

    final lowerQuery = query.toLowerCase();
    return _box.values
        .where((m) => m.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get mesocycles by template name
  List<Mesocycle> getByTemplate(String templateName) {
    return _box.values
        .where((m) => m.templateName == templateName)
        .toList();
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
