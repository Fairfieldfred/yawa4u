import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'custom_exercise_dao.g.dart';

/// Data Access Object for CustomExerciseDefinitions table
@DriftAccessor(tables: [CustomExerciseDefinitions])
class CustomExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$CustomExerciseDaoMixin {
  CustomExerciseDao(super.db);

  /// Get all custom exercises sorted by name
  Future<List<CustomExerciseDefinition>> getAllSorted() {
    return (select(
      customExerciseDefinitions,
    )..orderBy([(c) => OrderingTerm.asc(c.name)])).get();
  }

  /// Watch all custom exercises for reactive updates
  Stream<List<CustomExerciseDefinition>> watchAllSorted() {
    return (select(
      customExerciseDefinitions,
    )..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();
  }

  /// Get a custom exercise by UUID
  Future<CustomExerciseDefinition?> getByUuid(String uuid) {
    return (select(
      customExerciseDefinitions,
    )..where((c) => c.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Get a custom exercise by name
  Future<CustomExerciseDefinition?> getByName(String name) {
    return (select(
      customExerciseDefinitions,
    )..where((c) => c.name.equals(name))).getSingleOrNull();
  }

  /// Check if a custom exercise exists by name
  Future<bool> existsByName(String name) async {
    final result = await getByName(name);
    return result != null;
  }

  /// Insert a new custom exercise
  Future<int> insertExercise(CustomExerciseDefinitionsCompanion exercise) {
    return into(customExerciseDefinitions).insert(exercise);
  }

  /// Update an existing custom exercise
  Future<bool> updateExercise(CustomExerciseDefinition exercise) {
    return update(customExerciseDefinitions).replace(exercise);
  }

  /// Delete a custom exercise by UUID
  Future<int> deleteByUuid(String uuid) {
    return (delete(
      customExerciseDefinitions,
    )..where((c) => c.uuid.equals(uuid))).go();
  }

  /// Delete all custom exercises
  Future<int> deleteAll() {
    return delete(customExerciseDefinitions).go();
  }
}
