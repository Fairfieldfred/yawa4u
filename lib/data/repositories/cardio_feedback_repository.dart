import '../database/daos/cardio_feedback_dao.dart';
import '../database/mappers/session_mappers.dart';
import '../models/cardio_feedback.dart';

/// Repository for post-cardio-session subjective feedback.
///
/// Mirrors the existing [ExerciseFeedback] flow for strength sessions.
/// Feedback is 1:1 with a session; an upsert call is sufficient for both
/// create and update.
class CardioFeedbackRepository {
  final CardioFeedbackDao _dao;

  CardioFeedbackRepository(this._dao);

  Future<CardioFeedback?> getForSession(String sessionId) async {
    final row = await _dao.getBySessionUuid(sessionId);
    return row != null ? CardioFeedbackMapper.fromRow(row) : null;
  }

  Stream<CardioFeedback?> watchForSession(String sessionId) {
    return _dao.watchBySessionUuid(sessionId).map(
      (row) => row != null ? CardioFeedbackMapper.fromRow(row) : null,
    );
  }

  Future<void> save(String sessionId, CardioFeedback feedback) async {
    await _dao.upsert(CardioFeedbackMapper.toCompanion(sessionId, feedback));
  }

  Future<void> delete(String sessionId) async {
    await _dao.deleteBySessionUuid(sessionId);
  }
}
