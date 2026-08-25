// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cardio_feedback_dao.dart';

// ignore_for_file: type=lint
mixin _$CardioFeedbackDaoMixin on DatabaseAccessor<AppDatabase> {
  $TrainingCyclesTable get trainingCycles => attachedDatabase.trainingCycles;
  $SessionsTable get sessions => attachedDatabase.sessions;
  $CardioFeedbackTable get cardioFeedback => attachedDatabase.cardioFeedback;
  CardioFeedbackDaoManager get managers => CardioFeedbackDaoManager(this);
}

class CardioFeedbackDaoManager {
  final _$CardioFeedbackDaoMixin _db;
  CardioFeedbackDaoManager(this._db);
  $$TrainingCyclesTableTableManager get trainingCycles =>
      $$TrainingCyclesTableTableManager(
        _db.attachedDatabase,
        _db.trainingCycles,
      );
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db.attachedDatabase, _db.sessions);
  $$CardioFeedbackTableTableManager get cardioFeedback =>
      $$CardioFeedbackTableTableManager(
        _db.attachedDatabase,
        _db.cardioFeedback,
      );
}
