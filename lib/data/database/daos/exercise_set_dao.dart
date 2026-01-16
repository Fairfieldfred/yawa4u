import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'exercise_set_dao.g.dart';

/// Data Access Object for ExerciseSets table
@DriftAccessor(tables: [ExerciseSets])
class ExerciseSetDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseSetDaoMixin {
  ExerciseSetDao(super.db);

  /// Get all sets
  Future<List<ExerciseSet>> getAll() {
    return select(exerciseSets).get();
  }

  /// Watch all sets for reactive updates
  Stream<List<ExerciseSet>> watchAll() {
    return select(exerciseSets).watch();
  }

  /// Get sets by exercise UUID
  Future<List<ExerciseSet>> getByExerciseUuid(String exerciseUuid) {
    return (select(exerciseSets)
          ..where((s) => s.exerciseUuid.equals(exerciseUuid))
          ..orderBy([(s) => OrderingTerm.asc(s.setNumber)]))
        .get();
  }

  /// Watch sets by exercise UUID
  Stream<List<ExerciseSet>> watchByExerciseUuid(String exerciseUuid) {
    return (select(exerciseSets)
          ..where((s) => s.exerciseUuid.equals(exerciseUuid))
          ..orderBy([(s) => OrderingTerm.asc(s.setNumber)]))
        .watch();
  }

  /// Get a single set by UUID
  Future<ExerciseSet?> getByUuid(String uuid) {
    return (select(
      exerciseSets,
    )..where((s) => s.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Insert a new set
  Future<int> insertSet(ExerciseSetsCompanion set) {
    return into(exerciseSets).insert(set);
  }

  /// Insert multiple sets in a batch
  Future<void> insertAll(List<ExerciseSetsCompanion> setList) {
    return batch((b) {
      b.insertAll(exerciseSets, setList);
    });
  }

  /// Update an existing set
  Future<bool> updateSet(ExerciseSet set) {
    return update(exerciseSets).replace(set);
  }

  /// Update a set by UUID
  Future<int> updateByUuid(String uuid, ExerciseSetsCompanion set) {
    return (update(exerciseSets)..where((s) => s.uuid.equals(uuid))).write(set);
  }

  /// Delete a set by UUID
  Future<int> deleteByUuid(String uuid) {
    return (delete(exerciseSets)..where((s) => s.uuid.equals(uuid))).go();
  }

  /// Delete all sets for an exercise
  Future<int> deleteByExerciseUuid(String exerciseUuid) {
    return (delete(
      exerciseSets,
    )..where((s) => s.exerciseUuid.equals(exerciseUuid))).go();
  }

  /// Delete all sets
  Future<int> deleteAll() {
    return delete(exerciseSets).go();
  }
}
