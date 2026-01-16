import '../database/daos/custom_exercise_dao.dart';
import '../database/mappers/secondary_mappers.dart';
import '../models/custom_exercise_definition.dart';

/// Repository for custom exercise definition CRUD operations using Drift
class CustomExerciseRepository {
  final CustomExerciseDao _dao;

  CustomExerciseRepository(this._dao);

  /// Watch all custom exercises (for reactive UI updates)
  Stream<List<CustomExerciseDefinition>> watchAll() {
    return _dao.watchAllSorted().map(
      (rows) => rows.map((row) => CustomExerciseMapper.fromRow(row)).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase())),
    );
  }

  /// Get all custom exercises
  Future<List<CustomExerciseDefinition>> getAll() async {
    final rows = await _dao.getAllSorted();
    final exercises = rows
        .map((row) => CustomExerciseMapper.fromRow(row))
        .toList();
    exercises.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return exercises;
  }

  /// Get custom exercise by ID
  Future<CustomExerciseDefinition?> getById(String id) async {
    final row = await _dao.getByUuid(id);
    return row != null ? CustomExerciseMapper.fromRow(row) : null;
  }

  /// Get custom exercise by name (case-insensitive)
  Future<CustomExerciseDefinition?> getByName(String name) async {
    final all = await getAll();
    try {
      return all.firstWhere((e) => e.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Check if an exercise with this name exists
  Future<bool> existsByName(String name) async {
    final exercise = await getByName(name);
    return exercise != null;
  }

  /// Add a new custom exercise
  Future<void> add(CustomExerciseDefinition exercise) async {
    final companion = CustomExerciseMapper.toCompanion(exercise);
    await _dao.insertExercise(companion);
  }

  /// Update an existing custom exercise
  Future<void> update(CustomExerciseDefinition exercise) async {
    final companion = CustomExerciseMapper.toCompanion(exercise);
    final existing = await _dao.getByUuid(exercise.id);
    if (existing != null) {
      // Update using the existing row's id
      await ((_dao as dynamic).update(_dao.customExerciseDefinitions)
            ..where((c) => (c as dynamic).uuid.equals(exercise.id)))
          .write(companion);
    }
  }

  /// Delete a custom exercise by ID
  Future<void> delete(String id) async {
    await _dao.deleteByUuid(id);
  }

  /// Delete all custom exercises
  Future<void> deleteAll() async {
    await _dao.deleteAll();
  }

  /// Get count of custom exercises
  Future<int> count() async {
    final all = await getAll();
    return all.length;
  }
}
