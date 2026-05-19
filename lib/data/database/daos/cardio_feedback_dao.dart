import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'cardio_feedback_dao.g.dart';

/// Data Access Object for the [CardioFeedback] table. Parallels
/// [ExerciseFeedbackDao] but with cardio-specific fields: RPE, breathing,
/// GI comfort, weather.
@DriftAccessor(tables: [CardioFeedback])
class CardioFeedbackDao extends DatabaseAccessor<AppDatabase> with _$CardioFeedbackDaoMixin {
  CardioFeedbackDao(super.db);

  Future<CardioFeedbackData?> getBySessionUuid(String sessionUuid) {
    return (select(
      cardioFeedback,
    )..where((f) => f.sessionUuid.equals(sessionUuid))).getSingleOrNull();
  }

  Stream<CardioFeedbackData?> watchBySessionUuid(String sessionUuid) {
    return (select(
      cardioFeedback,
    )..where((f) => f.sessionUuid.equals(sessionUuid))).watchSingleOrNull();
  }

  Future<int> upsert(CardioFeedbackCompanion row) {
    return into(
      cardioFeedback,
    ).insert(row, mode: InsertMode.insertOrReplace);
  }

  Future<int> deleteBySessionUuid(String sessionUuid) {
    return (delete(
      cardioFeedback,
    )..where((f) => f.sessionUuid.equals(sessionUuid))).go();
  }

  Future<int> deleteAll() => delete(cardioFeedback).go();
}
