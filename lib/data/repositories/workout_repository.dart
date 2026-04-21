import '../../core/constants/enums.dart';
import '../../core/constants/sports.dart';
import '../database/daos/exercise_dao.dart';
import '../models/exercise.dart' as model;
import '../models/session.dart';
import '../models/workout.dart';
import 'session_repository.dart';

/// Phase 6 facade.
///
/// Historically this repository owned the `workouts` table end-to-end
/// — its own DAO, its own mapper, its own hierarchy-loading logic. As
/// of Phase 6 the strength data lives in the `sessions` table
/// (alongside cardio) and this class becomes a thin adapter that
/// exposes the old Workout-shaped API on top of [SessionRepository].
///
/// Why keep it around at all? Every strength UI screen takes a
/// dependency on this class or its providers. Rewriting 20+ call sites
/// inside `workout_screen.dart` alone would be multi-session work with
/// high regression risk. A facade preserves the API and lets the UI
/// migrate at leisure (or never — the facade is a perfectly valid
/// long-term arrangement).
///
/// The underlying `workouts` table is no longer written-to by the app;
/// it holds only the v5 backfill snapshot. The v6 migration drops it.
/// The drop is safe because every read path routed through this class
/// now goes through SessionRepository and sessions is the source of
/// truth.
class WorkoutRepository {
  final SessionRepository _sessionRepository;
  final ExerciseDao _exerciseDao;

  WorkoutRepository(this._sessionRepository, this._exerciseDao);

  // ---------------------------------------------------------------------------
  // Session ↔ legacy Workout adapter helpers
  // ---------------------------------------------------------------------------

  Workout _toWorkout(StrengthSession s) {
    return Workout(
      id: s.id,
      trainingCycleId: s.trainingCycleId ?? '',
      periodNumber: s.periodNumber ?? 1,
      dayNumber: s.dayNumber ?? 1,
      dayName: s.dayName,
      label: s.label,
      status: s.status,
      scheduledDate: s.scheduledDate,
      completedDate: s.completedDate,
      startTime: s.startTime,
      endTime: s.endTime,
      notes: s.notes,
      exercises: s.exercises,
    );
  }

  StrengthSession _toStrengthSession(Workout w) {
    return StrengthSession(
      id: w.id,
      trainingCycleId: w.trainingCycleId.isEmpty ? null : w.trainingCycleId,
      source: SessionSource.userLogged,
      status: w.status,
      periodNumber: w.periodNumber,
      dayNumber: w.dayNumber,
      dayName: w.dayName,
      label: w.label,
      scheduledDate: w.scheduledDate,
      completedDate: w.completedDate,
      startTime: w.startTime,
      endTime: w.endTime,
      notes: w.notes,
      exercises: w.exercises,
    );
  }

  List<Workout> _strengthOnly(List<Session> list) => list
      .whereType<StrengthSession>()
      .map(_toWorkout)
      .toList();

  // ---------------------------------------------------------------------------
  // Reads — all via SessionRepository, filtered to strength.
  // ---------------------------------------------------------------------------

  /// Watch every strength workout reactively.
  Stream<List<Workout>> watchAll() {
    return _sessionRepository.watchAll().map(_strengthOnly);
  }

  /// Watch strength workouts for a specific training cycle.
  Stream<List<Workout>> watchByTrainingCycleId(String trainingCycleId) {
    return _sessionRepository
        .watchByTrainingCycleId(trainingCycleId)
        .map(_strengthOnly);
  }

  Future<List<Workout>> getAll() async {
    final sessions = await _sessionRepository.watchAll().first;
    return _strengthOnly(sessions);
  }

  Future<Workout?> getById(String id) async {
    final session = await _sessionRepository.getById(id);
    if (session is StrengthSession) return _toWorkout(session);
    return null;
  }

  Future<List<Workout>> getByTrainingCycleId(String trainingCycleId) async {
    final sessions =
        await _sessionRepository.watchByTrainingCycleId(trainingCycleId).first;
    return _strengthOnly(sessions);
  }

  Future<List<Workout>> getByStatus(WorkoutStatus status) async {
    final all = await getAll();
    return all.where((w) => w.status == status).toList();
  }

  Future<List<Workout>> getCompleted() => getByStatus(WorkoutStatus.completed);

  Future<List<Workout>> getIncomplete() =>
      getByStatus(WorkoutStatus.incomplete);

  Future<List<Workout>> getSkipped() => getByStatus(WorkoutStatus.skipped);

  Future<List<Workout>> getByPeriod(
    String trainingCycleId,
    int periodNumber,
  ) async {
    final workouts = await getByTrainingCycleId(trainingCycleId);
    final filtered = workouts.where((w) => w.periodNumber == periodNumber).toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
    return filtered;
  }

  Future<List<Workout>> getByPeriodAndDay(
    String trainingCycleId,
    int periodNumber,
    int dayNumber,
  ) async {
    final workouts = await getByTrainingCycleId(trainingCycleId);
    return workouts
        .where(
          (w) => w.periodNumber == periodNumber && w.dayNumber == dayNumber,
        )
        .toList();
  }

  Future<List<Workout>> getByDateRange(DateTime start, DateTime end) async {
    final sessions =
        await _sessionRepository.watchByDateRange(start, end).first;
    return _strengthOnly(sessions);
  }

  Future<List<Workout>> getUpcoming() async {
    final now = DateTime.now();
    final all = await getAll();
    return all
        .where(
          (w) =>
              w.status == WorkoutStatus.incomplete &&
              w.scheduledDate != null &&
              w.scheduledDate!.isAfter(now),
        )
        .toList()
      ..sort((a, b) => a.scheduledDate!.compareTo(b.scheduledDate!));
  }

  Future<List<Workout>> getToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return getByDateRange(start, end);
  }

  Future<int> count() async {
    final all = await getAll();
    return all.length;
  }

  // ---------------------------------------------------------------------------
  // Writes — delegated to SessionRepository's strength methods.
  // ---------------------------------------------------------------------------

  Future<void> create(Workout workout) async {
    await _sessionRepository.createStrength(_toStrengthSession(workout));
  }

  Future<void> update(Workout workout) async {
    await _sessionRepository.updateStrength(_toStrengthSession(workout));
  }

  Future<void> delete(String id) async {
    await _sessionRepository.deleteStrength(id);
  }

  Future<void> deleteByTrainingCycleId(String trainingCycleId) async {
    final workouts = await getByTrainingCycleId(trainingCycleId);
    for (final w in workouts) {
      await _sessionRepository.deleteStrength(w.id);
    }
  }

  Future<void> markAsCompleted(String id) async {
    final workout = await getById(id);
    if (workout == null) return;
    await update(workout.complete());
  }

  Future<void> markAsSkipped(String id) async {
    final workout = await getById(id);
    if (workout == null) return;
    await update(workout.skip());
  }

  Future<void> resetWorkout(String id) async {
    final workout = await getById(id);
    if (workout == null) return;
    await update(workout.reset());
  }

  Future<void> clear() async {
    final all = await getAll();
    for (final w in all) {
      await _sessionRepository.deleteStrength(w.id);
    }
  }

  Future<void> deleteAll() => clear();

  // ---------------------------------------------------------------------------
  // Stats — unchanged shape; math happens on the Workout-typed list.
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getStats() async {
    final all = await getAll();
    final completed = all.where((w) => w.isCompleted).length;
    final incomplete = all.where((w) => !w.isCompleted && !w.isSkipped).length;
    final skipped = all.where((w) => w.isSkipped).length;
    return {
      'total': all.length,
      'completed': completed,
      'incomplete': incomplete,
      'skipped': skipped,
    };
  }

  Future<Map<String, dynamic>> getStatsForTrainingCycle(
    String trainingCycleId,
  ) async {
    final workouts = await getByTrainingCycleId(trainingCycleId);
    final completed = workouts.where((w) => w.isCompleted).length;
    final skipped = workouts.where((w) => w.isSkipped).length;

    return {
      'total': workouts.length,
      'completed': completed,
      'skipped': skipped,
      'incomplete': workouts.length - completed - skipped,
      'completion_rate': workouts.isEmpty ? 0.0 : completed / workouts.length,
    };
  }

  // ---------------------------------------------------------------------------
  // Exercise-level helper.
  // ---------------------------------------------------------------------------

  /// Find the most recent pinned note for an exercise name, excluding
  /// a specific exercise UUID. The underlying ExerciseDao method is
  /// agnostic of workouts vs sessions (it queries the exercises table
  /// directly), so this passes through unchanged.
  Future<String?> findPinnedNoteByExerciseName(
    String name,
    String excludeExerciseId,
  ) {
    return _exerciseDao.findPinnedNoteByName(name, excludeExerciseId);
  }

  /// Unused after the facade rewrite — kept to satisfy any callers that
  /// still reference it. The session-based [getAll] is the right entry.
  Future<List<model.Exercise>> loadExercisesForWorkout(String workoutId) =>
      Future.value(const []);
}
