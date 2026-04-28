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
import '../models/exercise.dart' as exercise_model;
import '../models/session.dart';
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
///   * As of Phase 6c, this repository is the single source of truth for
///     every session — strength and cardio. The [WorkoutRepository]
///     facade delegates here for all strength reads and writes, so the
///     legacy `workouts` table is no longer written-to by the app. It
///     still exists on disk with the v5 backfill snapshot; the v6
///     migration drops it.
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

  // ---------------------------------------------------------------------------
  // Strength session writes.
  //
  // Sessions are now the single source of truth for strength data.
  // [WorkoutRepository] is a facade that funnels every legacy
  // `Workout`-shaped call site into these three methods.
  //
  // Child reconciliation (exercises + sets) happens in
  // [_writeStrengthChildren]. The shape matches the previous
  // WorkoutRepository diff logic — insert new rows, update existing ones
  // in place, cascade-delete anything the new session no longer contains.
  // ---------------------------------------------------------------------------

  /// Create a strength session and its full child hierarchy (exercises +
  /// sets).
  Future<void> createStrength(StrengthSession session) async {
    if (session.sport != Sport.strength) {
      throw StateError('createStrength requires Sport.strength');
    }
    await _sessionDao.transaction(() async {
      await _sessionDao.insertSession(SessionMapper.toCompanion(session));
      await _writeStrengthChildren(session, isUpdate: false);
    });
  }

  /// Update a strength session and reconcile its exercise/set children.
  /// Exercises or sets no longer present in [session] are cascade-deleted.
  ///
  /// Wrapped in a transaction so that Drift stream watchers fire only after
  /// both the session row and its exercise/set children have been written.
  /// Without this, the `sessions` stream fires on the session-row update
  /// before the exercises are reconciled, causing listeners to hydrate
  /// stale exercise data.
  Future<void> updateStrength(StrengthSession session) async {
    if (session.sport != Sport.strength) {
      throw StateError('updateStrength requires Sport.strength');
    }
    await _sessionDao.transaction(() async {
      await _sessionDao.updateByUuid(
        session.id,
        SessionMapper.toCompanion(session),
      );
      await _writeStrengthChildren(session, isUpdate: true);
    });
  }

  Future<void> _writeStrengthChildren(
    StrengthSession session, {
    required bool isUpdate,
  }) async {
    // Query even on create — the initial list is empty so the cost is
    // negligible and the single code path keeps this method readable.
    final existingExercises =
        await _exerciseDao.getByWorkoutUuid(session.id);
    final existingExerciseIds = existingExercises.map((e) => e.uuid).toSet();
    final newExerciseIds = session.exercises.map((e) => e.id).toSet();

    // Remove exercises no longer in the session.
    if (isUpdate) {
      for (final ex in existingExercises) {
        if (!newExerciseIds.contains(ex.uuid)) {
          await _exerciseDao.cascadeDeleteByUuid(ex.uuid);
        }
      }
    }

    for (final exercise in session.exercises) {
      final companion = ExerciseMapper.toCompanion(
        exercise.copyWith(workoutId: session.id),
      );
      if (existingExerciseIds.contains(exercise.id)) {
        await _exerciseDao.updateByUuid(exercise.id, companion);
      } else {
        // Check cross-workout existence for moved exercises.
        final global = await _exerciseDao.getByUuid(exercise.id);
        if (global != null) {
          await _exerciseDao.updateByUuid(exercise.id, companion);
        } else {
          await _exerciseDao.insertExercise(companion);
        }
      }

      // Reconcile sets.
      final existingSets =
          await _exerciseSetDao.getByExerciseUuid(exercise.id);
      final existingSetIds = existingSets.map((s) => s.uuid).toSet();
      final newSetIds = exercise.sets.map((s) => s.id).toSet();
      if (isUpdate) {
        for (final set in existingSets) {
          if (!newSetIds.contains(set.uuid)) {
            await _exerciseSetDao.deleteByUuid(set.uuid);
          }
        }
      }
      for (final set in exercise.sets) {
        final setCompanion = ExerciseSetMapper.toCompanion(set, exercise.id);
        if (existingSetIds.contains(set.id)) {
          await _exerciseSetDao.updateByUuid(set.id, setCompanion);
        } else {
          await _exerciseSetDao.insertSet(setCompanion);
        }
      }
    }
  }

  /// Cascade-delete a strength session — SessionDao handles session_cardio
  /// / session_intervals / session_samples (no-op for strength) plus the
  /// session row itself, while the exercises/sets/feedbacks that hang off
  /// the session by `session_uuid` are removed via ExerciseDao's cascade
  /// per-exercise.
  Future<void> deleteStrength(String sessionId) async {
    final existingExercises = await _exerciseDao.getByWorkoutUuid(sessionId);
    for (final ex in existingExercises) {
      await _exerciseDao.cascadeDeleteByUuid(ex.uuid);
    }
    await _sessionDao.cascadeDeleteByUuid(sessionId);
  }
}
