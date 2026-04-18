import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/sports.dart';
import '../app_database.dart';

/// Backfill step for the v4 → v5 multi-sport migration.
///
/// Runs after the v5 table / column creation inside [AppDatabase.migration].
/// Everything it does is additive: existing rows keep working, and the new
/// v5 rows are populated so Session-based readers can function the moment
/// the migration completes.
///
/// Idempotent by construction — every write either targets a newly-added
/// column (safe to set to a default) or inserts a row keyed off an
/// existing UUID (the INSERT uses `OR IGNORE` so a replay is a no-op).
///
/// No SharedPreferences dependency on purpose — this runs inside the DB
/// migration, which should be free of platform channels. The generated
/// local-user UUID is persisted on every user-owned row so the app can read
/// it back later by querying any of them.
class AppDatabaseV5Backfill {
  AppDatabaseV5Backfill(this._db, {String? localUserUuid})
    : _localUserUuid = localUserUuid ?? const Uuid().v4();

  final AppDatabase _db;
  final String _localUserUuid;

  /// The UUID used for creator/owner on every row touched by this backfill.
  /// Exposed mostly for tests.
  String get localUserUuid => _localUserUuid;

  Future<void> run() async {
    await _backfillTrainingCycles();
    await _copyWorkoutsIntoSessions();
    await _backfillExerciseSessionLinks();
    await _backfillExerciseFeedbackSessionLinks();
    await _generateCyclePeriods();
  }

  /// Sets `primary_sport = strength`, `creator_uuid`, and `owner_uuid` on
  /// every existing training cycle.
  Future<void> _backfillTrainingCycles() async {
    await _db.customStatement(
      'UPDATE training_cycles '
      'SET primary_sport = ?, creator_uuid = ?, owner_uuid = ? '
      'WHERE primary_sport IS NULL '
      '   OR creator_uuid IS NULL '
      '   OR owner_uuid IS NULL',
      <Object>[Sport.strength.index, _localUserUuid, _localUserUuid],
    );
  }

  /// Copies every `workouts` row into `sessions` as a strength session.
  ///
  /// Reuses the workout's UUID as the session UUID so existing
  /// `exercises.workout_uuid` values line up with the new session rows —
  /// the [_backfillExerciseSessionLinks] step exploits this.
  Future<void> _copyWorkoutsIntoSessions() async {
    await _db.customStatement(
      'INSERT OR IGNORE INTO sessions ('
      '  uuid, training_cycle_uuid, sport, source, '
      '  period_number, day_number, day_name, label, status, '
      '  scheduled_date, completed_date, start_time, end_time, notes, '
      '  external_id, creator_uuid, owner_uuid'
      ') '
      'SELECT '
      '  uuid, training_cycle_uuid, ?, ?, '
      '  period_number, day_number, day_name, label, status, '
      '  scheduled_date, completed_date, start_time, end_time, notes, '
      '  NULL, ?, ? '
      'FROM workouts',
      <Object>[
        Sport.strength.index,
        SessionSource.userLogged.index,
        _localUserUuid,
        _localUserUuid,
      ],
    );
  }

  /// Sets `exercises.session_uuid = exercises.workout_uuid` for every row.
  /// Valid because [_copyWorkoutsIntoSessions] keeps workout and session
  /// UUIDs in sync.
  Future<void> _backfillExerciseSessionLinks() async {
    await _db.customStatement(
      'UPDATE exercises '
      'SET session_uuid = workout_uuid '
      'WHERE session_uuid IS NULL',
    );
  }

  /// Populates `exercise_feedbacks.session_uuid` by joining through
  /// `exercises`. Session UUID == workout UUID for legacy rows.
  Future<void> _backfillExerciseFeedbackSessionLinks() async {
    await _db.customStatement(
      'UPDATE exercise_feedbacks '
      'SET session_uuid = ('
      '  SELECT e.workout_uuid '
      '  FROM exercises e '
      '  WHERE e.uuid = exercise_feedbacks.exercise_uuid'
      ') '
      'WHERE session_uuid IS NULL',
    );
  }

  /// Generates one [CyclePeriods] row per `(training_cycle, periodNumber)`
  /// for the full period range of each existing cycle. [phase] is left null
  /// — strength-only cycles don't use it; endurance plans will set it when
  /// the UI gains a phase picker in Phase 3.
  Future<void> _generateCyclePeriods() async {
    final cycles = await _db.customSelect(
      'SELECT uuid, periods_total FROM training_cycles',
    ).get();

    for (final row in cycles) {
      final cycleUuid = row.read<String>('uuid');
      final periodsTotal = row.read<int>('periods_total');
      for (var p = 1; p <= periodsTotal; p++) {
        await _db.customStatement(
          'INSERT OR IGNORE INTO cycle_periods ('
          '  uuid, training_cycle_uuid, period_number, phase, notes, '
          '  creator_uuid, owner_uuid'
          ') VALUES (?, ?, ?, NULL, NULL, ?, ?)',
          <Object>[
            const Uuid().v4(),
            cycleUuid,
            p,
            _localUserUuid,
            _localUserUuid,
          ],
        );
      }
    }
  }
}
