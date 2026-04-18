import '../../core/constants/enums.dart';
import '../../core/constants/sports.dart';
import '../database/daos/cardio_feedback_dao.dart';
import '../database/daos/exercise_dao.dart';
import '../database/daos/exercise_set_dao.dart';
import '../database/daos/session_cardio_dao.dart';
import '../database/daos/session_dao.dart';
import '../database/daos/session_interval_dao.dart';
import '../database/daos/session_sample_dao.dart';
import '../database/mappers/entity_mappers.dart';
import '../database/mappers/session_mappers.dart';
import '../models/cardio_detail.dart';
import '../models/exercise.dart' as exercise_model;
import '../models/session.dart';
import '../models/session_interval.dart';
import '../models/session_sample.dart';

/// Repository for [Session] CRUD operations.
///
/// Handles the full session hierarchy:
///   * [StrengthSession] → loads exercises + sets (via [ExerciseDao] /
///     [ExerciseSetDao]).
///   * [CardioSession]   → loads cardio detail + intervals (and optionally
///     samples) from their dedicated DAOs.
///
/// Design notes:
///   * This repository reads the sessions table only. The legacy
///     `workouts` table still exists and is still the write path used by
///     the existing lifting code — this repo is intentionally additive and
///     does not mutate workouts. Once Phase 3 UI is wired up to sessions
///     directly, the workouts table becomes redundant and is dropped in v6.
///   * For strength sessions, exercises are found by
///     `exercises.session_uuid` (populated by the v5 backfill). Legacy rows
///     that were written before v5 but never migrated are effectively
///     invisible here — that shouldn't happen in practice because the
///     backfill covers every existing row.
class SessionRepository {
  final SessionDao _sessionDao;
  final ExerciseDao _exerciseDao;
  final ExerciseSetDao _exerciseSetDao;
  final SessionCardioDao _cardioDao;
  final SessionIntervalDao _intervalDao;
  final SessionSampleDao _sampleDao;
  // ignore: unused_field
  final CardioFeedbackDao _feedbackDao;

  SessionRepository(
    this._sessionDao,
    this._exerciseDao,
    this._exerciseSetDao,
    this._cardioDao,
    this._intervalDao,
    this._sampleDao,
    this._feedbackDao,
  );

  // ---------------------------------------------------------------------------
  // Reads — hierarchical load.
  // ---------------------------------------------------------------------------

  /// Load a single session by ID with all appropriate children.
  ///
  /// Pass [includeSamples] to additionally load [SessionSample] rows for a
  /// cardio session. Off by default because sample rows can be large (a
  /// 2-hour ride at 1 Hz has ~7200 samples).
  Future<Session?> getById(
    String id, {
    bool includeSamples = false,
  }) async {
    final row = await _sessionDao.getByUuid(id);
    if (row == null) return null;
    return _hydrate(row, includeSamples: includeSamples);
  }

  /// Watch sessions for a training cycle. Children are loaded per-session
  /// on each emit; upstream consumers typically filter by sport before
  /// rendering.
  Stream<List<Session>> watchByTrainingCycleId(String trainingCycleId) {
    return _sessionDao.watchByTrainingCycleUuid(trainingCycleId).asyncMap(
      _hydrateMany,
    );
  }

  Stream<List<Session>> watchAll() {
    return _sessionDao.watchAll().asyncMap(_hydrateMany);
  }

  /// Stream sessions filtered to a given sport. Useful for the stats-tab
  /// per-sport charts.
  Stream<List<Session>> watchBySport(Sport sport) {
    return _sessionDao.watchBySport(sport.index).asyncMap(_hydrateMany);
  }

  /// Stream cardio sessions only (every non-strength sport).
  Stream<List<Session>> watchCardio() {
    return _sessionDao.watchCardio().asyncMap(_hydrateMany);
  }

  /// Cardio sessions inside `[start, end]` — both-inclusive — used by the
  /// weekly-volume widgets.
  Stream<List<Session>> watchByDateRange(DateTime start, DateTime end) {
    return _sessionDao
        .watchByDateRange(start, end)
        .asyncMap(_hydrateMany);
  }

  /// Is there already a session with this external identifier?
  /// Used by the health-sync service to de-dupe imports.
  Future<Session?> getByExternalId(String externalId) async {
    final row = await _sessionDao.getByExternalId(externalId);
    if (row == null) return null;
    return _hydrate(row);
  }

  Future<List<Session>> _hydrateMany(List rows) async {
    final out = <Session>[];
    for (final row in rows) {
      out.add(await _hydrate(row));
    }
    return out;
  }

  Future<Session> _hydrate(
    dynamic row, {
    bool includeSamples = false,
  }) async {
    final sport = Sport.values[row.sport as int];
    if (sport == Sport.strength) {
      final exercises = await _loadExercisesForSession(row.uuid as String);
      return SessionMapper.strengthFromRow(row, exercises: exercises);
    }
    return _loadCardio(row, includeSamples: includeSamples);
  }

  Future<List<exercise_model.Exercise>> _loadExercisesForSession(
    String sessionUuid,
  ) async {
    // Exercises still carry workoutUuid (legacy) alongside sessionUuid. For
    // strength sessions the two are equal, so querying by workoutUuid is
    // correct and reuses the existing DAO method.
    final rows = await _exerciseDao.getByWorkoutUuid(sessionUuid);
    final out = <exercise_model.Exercise>[];
    for (final r in rows) {
      final sets = await _exerciseSetDao.getByExerciseUuid(r.uuid);
      out.add(
        ExerciseMapper.fromRow(
          r,
          sets: sets.map(ExerciseSetMapper.fromRow).toList(),
        ),
      );
    }
    return out;
  }

  Future<CardioSession> _loadCardio(
    dynamic row, {
    bool includeSamples = false,
  }) async {
    final sessionUuid = row.uuid as String;
    final cardioRow = await _cardioDao.getBySessionUuid(sessionUuid);
    final detail = cardioRow != null
        ? CardioDetailMapper.fromRow(cardioRow)
        : null;

    final intervalRows = await _intervalDao.getBySessionUuid(sessionUuid);
    final intervals = intervalRows.map(SessionIntervalMapper.fromRow).toList();

    List<SessionSample>? samples;
    if (includeSamples) {
      final sampleRows = await _sampleDao.getBySessionUuid(sessionUuid);
      samples = sampleRows.map(SessionSampleMapper.fromRow).toList();
    }

    return SessionMapper.cardioFromRow(
      row,
      detail: detail,
      intervals: intervals,
      samples: samples,
    );
  }

  // ---------------------------------------------------------------------------
  // Writes — non-exhaustive in v1. Just what's needed for cardio creation
  // and status transitions. Strength writes still go through the existing
  // WorkoutRepository until the UI migrates in Phase 3.
  // ---------------------------------------------------------------------------

  /// Insert a cardio session with its detail and any structured intervals.
  /// Throws if [session] is a [StrengthSession] — those should still be
  /// written via [WorkoutRepository] in this phase.
  Future<void> createCardio(CardioSession session) async {
    if (session.sport == Sport.strength) {
      throw StateError('Use WorkoutRepository for strength sessions in v5');
    }
    await _sessionDao.insertSession(SessionMapper.toCompanion(session));
    if (session.detail != null) {
      await _cardioDao.upsert(
        CardioDetailMapper.toCompanion(session.id, session.detail!),
      );
    }
    if (session.intervals.isNotEmpty) {
      await _intervalDao.insertAll(
        session.intervals.map(SessionIntervalMapper.toCompanion).toList(),
      );
    }
  }

  /// Update the shared session row (does not touch children).
  Future<void> updateSession(Session session) async {
    await _sessionDao.updateByUuid(
      session.id,
      SessionMapper.toCompanion(session),
    );
  }

  /// Update a cardio session's detail and intervals in one pass. Replaces
  /// the full interval list — easier than diffing for v1.
  Future<void> updateCardio(CardioSession session) async {
    await updateSession(session);
    if (session.detail != null) {
      await _cardioDao.upsert(
        CardioDetailMapper.toCompanion(session.id, session.detail!),
      );
    }
    await _intervalDao.deleteBySessionUuid(session.id);
    if (session.intervals.isNotEmpty) {
      await _intervalDao.insertAll(
        session.intervals.map(SessionIntervalMapper.toCompanion).toList(),
      );
    }
  }

  /// Mark a session completed. Sets completedDate/endTime on the session
  /// row — child data is not touched.
  Future<void> markAsCompleted(String id) async {
    final session = await _sessionDao.getByUuid(id);
    if (session == null) return;
    final now = DateTime.now();
    await _sessionDao.updateByUuid(
      id,
      SessionMapper.toCompanion(
        _shallowWithStatus(
          session,
          WorkoutStatus.completed,
          completedDate: now,
          endTimeIfMissing: now,
        ),
      ),
    );
  }

  Future<void> markAsSkipped(String id) async {
    final session = await _sessionDao.getByUuid(id);
    if (session == null) return;
    await _sessionDao.updateByUuid(
      id,
      SessionMapper.toCompanion(
        _shallowWithStatus(session, WorkoutStatus.skipped),
      ),
    );
  }

  Session _shallowWithStatus(
    dynamic row,
    WorkoutStatus status, {
    DateTime? completedDate,
    DateTime? endTimeIfMissing,
  }) {
    final sport = Sport.values[row.sport as int];
    final base = sport == Sport.strength
        ? SessionMapper.strengthFromRow(row)
        : SessionMapper.cardioFromRow(row);
    if (base is StrengthSession) {
      return base.copyWith(
        status: status,
        completedDate: completedDate,
        endTime: endTimeIfMissing ?? base.endTime,
      );
    }
    if (base is CardioSession) {
      return base.copyWith(
        status: status,
        completedDate: completedDate,
        endTime: endTimeIfMissing ?? base.endTime,
      );
    }
    return base;
  }

  /// Delete a session and every related row (cascades via the DAO).
  Future<void> delete(String id) async {
    await _sessionDao.cascadeDeleteByUuid(id);
  }
}
