import '../../core/constants/sports.dart';

/// One step of a structured cardio workout.
///
/// The [targetKind] determines which target fields are meaningful. For
/// example, [IntervalTargetKind.durationSec] uses [targetDurationSec];
/// [IntervalTargetKind.hrZone] uses [targetHrZone] and optionally
/// [targetDurationSec] or [targetDistanceM] for the length of the step.
///
/// Repeat groups: a row with [intent] == [IntervalIntent.repeatGroup] and
/// a non-null [repeatCount] acts as a container. Child rows set their
/// [parentIntervalUuid] to the repeat group's UUID.
class SessionInterval {
  final String id;
  final String sessionId;
  final int orderIndex;
  final IntervalIntent intent;
  final IntervalTargetKind targetKind;

  // Target values (only one group populated per row).
  final int? targetDurationSec;
  final double? targetDistanceM;
  final int? targetHrZone;
  final int? targetPaceZone;
  final int? targetPowerZone;
  final double? targetValueMin;
  final double? targetValueMax;
  final String? targetFreeform;

  // Actual (executed) values.
  final int? actualDurationSec;
  final double? actualDistanceM;
  final int? actualAverageHr;
  final double? actualAveragePaceSecPerMeter;
  final double? actualAveragePowerWatts;

  // Repeat-group support.
  final int? repeatCount;
  final String? parentIntervalId;

  final String? notes;

  const SessionInterval({
    required this.id,
    required this.sessionId,
    required this.orderIndex,
    required this.intent,
    required this.targetKind,
    this.targetDurationSec,
    this.targetDistanceM,
    this.targetHrZone,
    this.targetPaceZone,
    this.targetPowerZone,
    this.targetValueMin,
    this.targetValueMax,
    this.targetFreeform,
    this.actualDurationSec,
    this.actualDistanceM,
    this.actualAverageHr,
    this.actualAveragePaceSecPerMeter,
    this.actualAveragePowerWatts,
    this.repeatCount,
    this.parentIntervalId,
    this.notes,
  });

  bool get isRepeatGroup => intent == IntervalIntent.repeatGroup;

  bool get isCompleted => actualDurationSec != null || actualDistanceM != null;

  SessionInterval copyWith({
    String? id,
    String? sessionId,
    int? orderIndex,
    IntervalIntent? intent,
    IntervalTargetKind? targetKind,
    int? targetDurationSec,
    double? targetDistanceM,
    int? targetHrZone,
    int? targetPaceZone,
    int? targetPowerZone,
    double? targetValueMin,
    double? targetValueMax,
    String? targetFreeform,
    int? actualDurationSec,
    double? actualDistanceM,
    int? actualAverageHr,
    double? actualAveragePaceSecPerMeter,
    double? actualAveragePowerWatts,
    int? repeatCount,
    String? parentIntervalId,
    String? notes,
  }) {
    return SessionInterval(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      orderIndex: orderIndex ?? this.orderIndex,
      intent: intent ?? this.intent,
      targetKind: targetKind ?? this.targetKind,
      targetDurationSec: targetDurationSec ?? this.targetDurationSec,
      targetDistanceM: targetDistanceM ?? this.targetDistanceM,
      targetHrZone: targetHrZone ?? this.targetHrZone,
      targetPaceZone: targetPaceZone ?? this.targetPaceZone,
      targetPowerZone: targetPowerZone ?? this.targetPowerZone,
      targetValueMin: targetValueMin ?? this.targetValueMin,
      targetValueMax: targetValueMax ?? this.targetValueMax,
      targetFreeform: targetFreeform ?? this.targetFreeform,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      actualDistanceM: actualDistanceM ?? this.actualDistanceM,
      actualAverageHr: actualAverageHr ?? this.actualAverageHr,
      actualAveragePaceSecPerMeter: actualAveragePaceSecPerMeter ?? this.actualAveragePaceSecPerMeter,
      actualAveragePowerWatts: actualAveragePowerWatts ?? this.actualAveragePowerWatts,
      repeatCount: repeatCount ?? this.repeatCount,
      parentIntervalId: parentIntervalId ?? this.parentIntervalId,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'orderIndex': orderIndex,
    'intent': intent.name,
    'targetKind': targetKind.name,
    'targetDurationSec': targetDurationSec,
    'targetDistanceM': targetDistanceM,
    'targetHrZone': targetHrZone,
    'targetPaceZone': targetPaceZone,
    'targetPowerZone': targetPowerZone,
    'targetValueMin': targetValueMin,
    'targetValueMax': targetValueMax,
    'targetFreeform': targetFreeform,
    'actualDurationSec': actualDurationSec,
    'actualDistanceM': actualDistanceM,
    'actualAverageHr': actualAverageHr,
    'actualAveragePaceSecPerMeter': actualAveragePaceSecPerMeter,
    'actualAveragePowerWatts': actualAveragePowerWatts,
    'repeatCount': repeatCount,
    'parentIntervalId': parentIntervalId,
    'notes': notes,
  };

  factory SessionInterval.fromJson(Map<String, dynamic> json) {
    return SessionInterval(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      orderIndex: json['orderIndex'] as int,
      intent: IntervalIntent.values.firstWhere(
        (e) => e.name == json['intent'],
        orElse: () => IntervalIntent.work,
      ),
      targetKind: IntervalTargetKind.values.firstWhere(
        (e) => e.name == json['targetKind'],
        orElse: () => IntervalTargetKind.freeform,
      ),
      targetDurationSec: json['targetDurationSec'] as int?,
      targetDistanceM: (json['targetDistanceM'] as num?)?.toDouble(),
      targetHrZone: json['targetHrZone'] as int?,
      targetPaceZone: json['targetPaceZone'] as int?,
      targetPowerZone: json['targetPowerZone'] as int?,
      targetValueMin: (json['targetValueMin'] as num?)?.toDouble(),
      targetValueMax: (json['targetValueMax'] as num?)?.toDouble(),
      targetFreeform: json['targetFreeform'] as String?,
      actualDurationSec: json['actualDurationSec'] as int?,
      actualDistanceM: (json['actualDistanceM'] as num?)?.toDouble(),
      actualAverageHr: json['actualAverageHr'] as int?,
      actualAveragePaceSecPerMeter: (json['actualAveragePaceSecPerMeter'] as num?)?.toDouble(),
      actualAveragePowerWatts: (json['actualAveragePowerWatts'] as num?)?.toDouble(),
      repeatCount: json['repeatCount'] as int?,
      parentIntervalId: json['parentIntervalId'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
