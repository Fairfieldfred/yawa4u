import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'exercise_feedback_dao.g.dart';

/// Data Access Object for ExerciseFeedbacks table
@DriftAccessor(tables: [ExerciseFeedbacks])
class ExerciseFeedbackDao extends DatabaseAccessor<AppDatabase>
    with _$ExerciseFeedbackDaoMixin {
  ExerciseFeedbackDao(super.db);

  /// Get all feedback entries
  Future<List<ExerciseFeedback>> getAll() {
    return select(exerciseFeedbacks).get();
  }

  /// Watch all feedback entries for reactive updates
  Stream<List<ExerciseFeedback>> watchAll() {
    return select(exerciseFeedbacks).watch();
  }

  /// Get feedback by exercise UUID
  Future<ExerciseFeedback?> getByExerciseUuid(String exerciseUuid) {
    return (select(
      exerciseFeedbacks,
    )..where((f) => f.exerciseUuid.equals(exerciseUuid))).getSingleOrNull();
  }

  /// Watch feedback by exercise UUID
  Stream<ExerciseFeedback?> watchByExerciseUuid(String exerciseUuid) {
    return (select(
      exerciseFeedbacks,
    )..where((f) => f.exerciseUuid.equals(exerciseUuid))).watchSingleOrNull();
  }

  /// Insert or update feedback (upsert)
  Future<int> upsertFeedback(ExerciseFeedbacksCompanion feedback) {
    return into(exerciseFeedbacks).insertOnConflictUpdate(feedback);
  }

  /// Update feedback by exercise UUID
  Future<int> updateByExerciseUuid(
    String exerciseUuid,
    ExerciseFeedbacksCompanion feedback,
  ) {
    return (update(
      exerciseFeedbacks,
    )..where((f) => f.exerciseUuid.equals(exerciseUuid))).write(feedback);
  }

  /// Delete feedback by exercise UUID
  Future<int> deleteByExerciseUuid(String exerciseUuid) {
    return (delete(
      exerciseFeedbacks,
    )..where((f) => f.exerciseUuid.equals(exerciseUuid))).go();
  }

  /// Delete all feedback
  Future<int> deleteAll() {
    return delete(exerciseFeedbacks).go();
  }
}
