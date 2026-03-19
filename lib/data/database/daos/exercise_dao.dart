import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'exercise_dao.g.dart';

/// Data Access Object for Exercises table
@DriftAccessor(tables: [Exercises])
class ExerciseDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseDaoMixin {
  ExerciseDao(super.db);

  /// Get all exercises
  Future<List<Exercise>> getAll() {
    return select(exercises).get();
  }

  /// Watch all exercises for reactive updates
  Stream<List<Exercise>> watchAll() {
    return select(exercises).watch();
  }

  /// Get exercises by workout UUID
  Future<List<Exercise>> getByWorkoutUuid(String workoutUuid) {
    return (select(exercises)
          ..where((e) => e.workoutUuid.equals(workoutUuid))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .get();
  }

  /// Watch exercises by workout UUID
  Stream<List<Exercise>> watchByWorkoutUuid(String workoutUuid) {
    return (select(exercises)
          ..where((e) => e.workoutUuid.equals(workoutUuid))
          ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
        .watch();
  }

  /// Get a single exercise by UUID
  Future<Exercise?> getByUuid(String uuid) {
    return (select(
      exercises,
    )..where((e) => e.uuid.equals(uuid))).getSingleOrNull();
  }

  /// Watch a single exercise by UUID
  Stream<Exercise?> watchByUuid(String uuid) {
    return (select(
      exercises,
    )..where((e) => e.uuid.equals(uuid))).watchSingleOrNull();
  }

  /// Get exercises by name (for history lookup)
  Future<List<Exercise>> getByName(String name) {
    return (select(exercises)
          ..where((e) => e.name.equals(name))
          ..orderBy([(e) => OrderingTerm.desc(e.lastPerformed)]))
        .get();
  }

  /// Insert a new exercise
  Future<int> insertExercise(ExercisesCompanion exercise) {
    return into(exercises).insert(exercise);
  }

  /// Insert multiple exercises in a batch
  Future<void> insertAll(List<ExercisesCompanion> exerciseList) {
    return batch((b) {
      b.insertAll(exercises, exerciseList);
    });
  }

  /// Update an existing exercise
  Future<bool> updateExercise(Exercise exercise) {
    return update(exercises).replace(exercise);
  }

  /// Update an exercise by UUID
  Future<int> updateByUuid(String uuid, ExercisesCompanion exercise) {
    return (update(
      exercises,
    )..where((e) => e.uuid.equals(uuid))).write(exercise);
  }

  /// Delete an exercise by UUID
  Future<int> deleteByUuid(String uuid) {
    return (delete(exercises)..where((e) => e.uuid.equals(uuid))).go();
  }

  /// Delete all exercises for a workout
  Future<int> deleteByWorkoutUuid(String workoutUuid) {
    return (delete(
      exercises,
    )..where((e) => e.workoutUuid.equals(workoutUuid))).go();
  }

  /// Find the most recent pinned note for an exercise name, excluding a
  /// specific exercise UUID. Returns only the note text.
  Future<String?> findPinnedNoteByName(
    String name,
    String excludeUuid,
  ) async {
    final query = select(exercises)
      ..where(
        (e) =>
            e.name.collate(Collate.noCase).equals(name) &
            e.uuid.equals(excludeUuid).not() &
            e.isNotePinned.equals(true) &
            e.notes.isNotNull(),
      )
      ..orderBy([(e) => OrderingTerm.desc(e.lastPerformed)])
      ..limit(1);
    final result = await query.getSingleOrNull();
    if (result == null) return null;
    final note = result.notes;
    return (note != null && note.isNotEmpty) ? note : null;
  }

  /// Delete all exercises
  Future<int> deleteAll() {
    return delete(exercises).go();
  }
}
