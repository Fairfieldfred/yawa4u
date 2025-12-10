import 'package:hive/hive.dart';

import '../models/custom_exercise_definition.dart';

/// Repository for custom exercise definition CRUD operations
class CustomExerciseRepository {
  final Box<CustomExerciseDefinition> _box;

  CustomExerciseRepository(this._box);

  /// Get the underlying Hive box (for watching changes)
  Box<CustomExerciseDefinition> get box => _box;

  /// Get all custom exercises
  List<CustomExerciseDefinition> getAll() {
    return _box.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Get custom exercise by ID
  CustomExerciseDefinition? getById(String id) {
    return _box.get(id);
  }

  /// Get custom exercise by name (case-insensitive)
  CustomExerciseDefinition? getByName(String name) {
    try {
      return _box.values.firstWhere(
        (e) => e.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if an exercise with this name exists
  bool existsByName(String name) {
    return getByName(name) != null;
  }

  /// Add a new custom exercise
  Future<void> add(CustomExerciseDefinition exercise) async {
    await _box.put(exercise.id, exercise);
  }

  /// Update an existing custom exercise
  Future<void> update(CustomExerciseDefinition exercise) async {
    await _box.put(exercise.id, exercise);
  }

  /// Delete a custom exercise by ID
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Delete all custom exercises
  Future<void> deleteAll() async {
    await _box.clear();
  }

  /// Get count of custom exercises
  int get count => _box.length;
}
