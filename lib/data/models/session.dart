import '../../core/constants/enums.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/constants/sports.dart';
import '../../l10n/app_localizations.dart';
import 'cardio_detail.dart';
import 'exercise.dart';
import 'session_interval.dart';
import 'session_sample.dart';

/// Polymorphic "training session".
///
/// Every training action — a lifting day, a run, a ride, a swim — is a
/// [Session]. The sport determines which subclass carries the sport-specific
/// payload:
///
///   * [StrengthSession] — wraps the existing [Exercise] / ExerciseSet
///     hierarchy. Semantics are unchanged from the legacy `Workout` model.
///   * [CardioSession] — carries a [CardioDetail], optional structured
///     [SessionInterval]s, and optional high-resolution [SessionSample]s.
///
/// Using a sealed class means every `switch (session)` in UI code is
/// checked for exhaustiveness at compile time, which is a lot of the
/// reason this refactor is worth doing.
sealed class Session {
  final String id;
  final String? trainingCycleId;
  final Sport sport;
  final SessionSource source;
  final int? periodNumber;
  final int? dayNumber;
  final String? dayName;
  final String? label;
  final WorkoutStatus status;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;

  /// External identifier (e.g. HealthKit / Strava record UUID). Used to
  /// de-dupe on re-import.
  final String? externalId;

  /// Coach-mode hooks. Defaults to the local user until coach features
  /// ship.
  final String? creatorUuid;
  final String? ownerUuid;

  const Session({
    required this.id,
    required this.trainingCycleId,
    required this.sport,
    required this.source,
    required this.status,
    this.periodNumber,
    this.dayNumber,
    this.dayName,
    this.label,
    this.scheduledDate,
    this.completedDate,
    this.startTime,
    this.endTime,
    this.notes,
    this.externalId,
    this.creatorUuid,
    this.ownerUuid,
  });

  bool get isCompleted => status == WorkoutStatus.completed;
  bool get isSkipped => status == WorkoutStatus.skipped;
  bool get isIncomplete => status == WorkoutStatus.incomplete;

  /// Imported sessions are considered read-only for aggregate data — only
  /// notes / feedback / rpe can be edited.
  bool get isReadOnly => source.isExternal;

  /// Wall-clock duration of this session if both start and end are known.
  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }

  /// Human-friendly label. Falls back to day name → "Day N" → sport name.
  String get displayName {
    if (label != null && label!.isNotEmpty) return label!;
    if (dayName != null && dayName!.isNotEmpty) return dayName!;
    if (dayNumber != null) return 'Day $dayNumber';
    return sport.displayName;
  }

  /// Format [duration] as "Xh Ym" or "Ym".
  String? get durationDisplay {
    final d = duration;
    if (d == null) return null;
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  Map<String, dynamic> toJson();
}

/// A strength-training session. Carries the same exercise list shape the
/// legacy `Workout` model uses.
class StrengthSession extends Session {
  final List<Exercise> exercises;

  const StrengthSession({
    required super.id,
    required super.trainingCycleId,
    required super.source,
    required super.status,
    super.periodNumber,
    super.dayNumber,
    super.dayName,
    super.label,
    super.scheduledDate,
    super.completedDate,
    super.startTime,
    super.endTime,
    super.notes,
    super.externalId,
    super.creatorUuid,
    super.ownerUuid,
    this.exercises = const [],
  }) : super(sport: Sport.strength);

  bool get hasMyorepSets => exercises.any((e) => e.hasMyorepSets);

  int get totalExercises => exercises.length;

  int get completedExercises => exercises.where((e) => e.isCompleted).length;

  double get completionPercentage => exercises.isEmpty ? 0.0 : completedExercises / totalExercises;

  StrengthSession copyWith({
    String? id,
    String? trainingCycleId,
    bool clearTrainingCycleId = false,
    SessionSource? source,
    WorkoutStatus? status,
    int? periodNumber,
    int? dayNumber,
    String? dayName,
    String? label,
    DateTime? scheduledDate,
    bool clearScheduledDate = false,
    DateTime? completedDate,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    String? externalId,
    String? creatorUuid,
    String? ownerUuid,
    List<Exercise>? exercises,
  }) {
    return StrengthSession(
      id: id ?? this.id,
      trainingCycleId: clearTrainingCycleId ? null : (trainingCycleId ?? this.trainingCycleId),
      source: source ?? this.source,
      status: status ?? this.status,
      periodNumber: periodNumber ?? this.periodNumber,
      dayNumber: dayNumber ?? this.dayNumber,
      dayName: dayName ?? this.dayName,
      label: label ?? this.label,
      scheduledDate: clearScheduledDate ? null : (scheduledDate ?? this.scheduledDate),
      completedDate: completedDate ?? this.completedDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      externalId: externalId ?? this.externalId,
      creatorUuid: creatorUuid ?? this.creatorUuid,
      ownerUuid: ownerUuid ?? this.ownerUuid,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'strength',
    'id': id,
    'trainingCycleId': trainingCycleId,
    'sport': sport.name,
    'source': source.name,
    'status': status.name,
    'periodNumber': periodNumber,
    'dayNumber': dayNumber,
    'dayName': dayName,
    'label': label,
    'scheduledDate': scheduledDate?.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'notes': notes,
    'externalId': externalId,
    'creatorUuid': creatorUuid,
    'ownerUuid': ownerUuid,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory StrengthSession.fromJson(Map<String, dynamic> json) {
    return StrengthSession(
      id: json['id'] as String,
      trainingCycleId: json['trainingCycleId'] as String?,
      source: SessionSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => SessionSource.userLogged,
      ),
      status: WorkoutStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkoutStatus.incomplete,
      ),
      periodNumber: json['periodNumber'] as int?,
      dayNumber: json['dayNumber'] as int?,
      dayName: json['dayName'] as String?,
      label: json['label'] as String?,
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate'] as String) : null,
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate'] as String) : null,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      notes: json['notes'] as String?,
      externalId: json['externalId'] as String?,
      creatorUuid: json['creatorUuid'] as String?,
      ownerUuid: json['ownerUuid'] as String?,
      exercises:
          (json['exercises'] as List?)?.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
    );
  }
}

/// A cardio session (run / bike / swim / other).
///
/// [detail] holds the flat aggregate metrics; [intervals] holds any
/// structured plan + actuals; [samples] holds high-resolution recorded
/// streams when available. [samples] is often null because loading samples
/// is gated behind an explicit opt-in at the repository layer.
class CardioSession extends Session {
  final CardioDetail? detail;
  final List<SessionInterval> intervals;
  final List<SessionSample>? samples;

  const CardioSession({
    required super.id,
    required super.trainingCycleId,
    required super.sport,
    required super.source,
    required super.status,
    super.periodNumber,
    super.dayNumber,
    super.dayName,
    super.label,
    super.scheduledDate,
    super.completedDate,
    super.startTime,
    super.endTime,
    super.notes,
    super.externalId,
    super.creatorUuid,
    super.ownerUuid,
    this.detail,
    this.intervals = const [],
    this.samples,
  }) : assert(sport != Sport.strength, 'CardioSession.sport must be cardio');

  bool get hasStructuredPlan => intervals.isNotEmpty;
  bool get hasSamples => samples != null && samples!.isNotEmpty;

  CardioSession copyWith({
    String? id,
    String? trainingCycleId,
    bool clearTrainingCycleId = false,
    Sport? sport,
    SessionSource? source,
    WorkoutStatus? status,
    int? periodNumber,
    int? dayNumber,
    String? dayName,
    String? label,
    DateTime? scheduledDate,
    bool clearScheduledDate = false,
    DateTime? completedDate,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    String? externalId,
    String? creatorUuid,
    String? ownerUuid,
    CardioDetail? detail,
    List<SessionInterval>? intervals,
    List<SessionSample>? samples,
  }) {
    return CardioSession(
      id: id ?? this.id,
      trainingCycleId: clearTrainingCycleId ? null : (trainingCycleId ?? this.trainingCycleId),
      sport: sport ?? this.sport,
      source: source ?? this.source,
      status: status ?? this.status,
      periodNumber: periodNumber ?? this.periodNumber,
      dayNumber: dayNumber ?? this.dayNumber,
      dayName: dayName ?? this.dayName,
      label: label ?? this.label,
      scheduledDate: clearScheduledDate ? null : (scheduledDate ?? this.scheduledDate),
      completedDate: completedDate ?? this.completedDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      externalId: externalId ?? this.externalId,
      creatorUuid: creatorUuid ?? this.creatorUuid,
      ownerUuid: ownerUuid ?? this.ownerUuid,
      detail: detail ?? this.detail,
      intervals: intervals ?? this.intervals,
      samples: samples ?? this.samples,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'cardio',
    'id': id,
    'trainingCycleId': trainingCycleId,
    'sport': sport.name,
    'source': source.name,
    'status': status.name,
    'periodNumber': periodNumber,
    'dayNumber': dayNumber,
    'dayName': dayName,
    'label': label,
    'scheduledDate': scheduledDate?.toIso8601String(),
    'completedDate': completedDate?.toIso8601String(),
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'notes': notes,
    'externalId': externalId,
    'creatorUuid': creatorUuid,
    'ownerUuid': ownerUuid,
    'detail': detail?.toJson(),
    'intervals': intervals.map((i) => i.toJson()).toList(),
    // Samples intentionally excluded from default JSON — too large for
    // routine export. The dedicated backup pipeline includes them when
    // asked.
  };

  factory CardioSession.fromJson(Map<String, dynamic> json) {
    return CardioSession(
      id: json['id'] as String,
      trainingCycleId: json['trainingCycleId'] as String?,
      sport: Sport.values.firstWhere(
        (e) => e.name == json['sport'],
        orElse: () => Sport.other,
      ),
      source: SessionSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => SessionSource.userLogged,
      ),
      status: WorkoutStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkoutStatus.incomplete,
      ),
      periodNumber: json['periodNumber'] as int?,
      dayNumber: json['dayNumber'] as int?,
      dayName: json['dayName'] as String?,
      label: json['label'] as String?,
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate'] as String) : null,
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate'] as String) : null,
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      notes: json['notes'] as String?,
      externalId: json['externalId'] as String?,
      creatorUuid: json['creatorUuid'] as String?,
      ownerUuid: json['ownerUuid'] as String?,
      detail: json['detail'] != null ? CardioDetail.fromJson(json['detail'] as Map<String, dynamic>) : null,
      intervals:
          (json['intervals'] as List?)?.map((i) => SessionInterval.fromJson(i as Map<String, dynamic>)).toList() ??
          const [],
    );
  }
}

/// Entry-point factory that picks the correct subclass based on the
/// "kind" discriminator in stored JSON.
Session sessionFromJson(Map<String, dynamic> json) {
  final kind = json['kind'] as String?;
  if (kind == 'cardio') return CardioSession.fromJson(json);
  return StrengthSession.fromJson(json);
}

/// Display-time localization for [Session.displayName].
///
/// Stored labels stay canonical English (auto-generated strength labels hold a
/// [MuscleGroup] displayName that ScheduleService matches on); this maps them —
/// and the "Day N" / sport-name fallbacks — to the active locale. User-edited
/// labels pass through unchanged.
extension SessionLocalizedDisplay on Session {
  String localizedDisplayName(AppLocalizations l10n) {
    final label = this.label;
    if (label != null && label.isNotEmpty) return MuscleGroups.localizedLabel(l10n, label);
    final dayName = this.dayName;
    if (dayName != null && dayName.isNotEmpty) return dayName;
    final dayNumber = this.dayNumber;
    if (dayNumber != null) return l10n.sessionDayFallback(dayNumber);
    return sport.localizedName(l10n);
  }
}
