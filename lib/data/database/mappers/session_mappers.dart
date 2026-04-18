import 'package:drift/drift.dart';

import '../../../core/constants/enums.dart';
import '../../../core/constants/sports.dart';
import '../../models/cardio_detail.dart';
import '../../models/cardio_feedback.dart' as model;
import '../../models/cycle_period.dart' as model;
import '../../models/exercise.dart' as exercise_model;
import '../../models/session.dart' as model;
import '../../models/session_interval.dart' as model;
import '../../models/session_sample.dart' as model;
import '../../models/sport_zone.dart' as model;
import '../app_database.dart';

/// Converts between Drift [Session] rows and domain [model.Session]s.
///
/// Strength vs. cardio is dispatched on the `sport` column. Children
/// (exercises for strength, cardio detail / intervals / samples for cardio)
/// are loaded by the repository and passed in here — this mapper itself
/// does no IO.
class SessionMapper {
  /// Build a [model.StrengthSession] from a Drift row plus preloaded
  /// exercises.
  static model.StrengthSession strengthFromRow(
    Session row, {
    List<exercise_model.Exercise> exercises = const [],
  }) {
    return model.StrengthSession(
      id: row.uuid,
      trainingCycleId: row.trainingCycleUuid,
      source: SessionSource.values[row.source],
      status: WorkoutStatus.values[row.status],
      periodNumber: row.periodNumber,
      dayNumber: row.dayNumber,
      dayName: row.dayName,
      label: row.label,
      scheduledDate: row.scheduledDate,
      completedDate: row.completedDate,
      startTime: row.startTime,
      endTime: row.endTime,
      notes: row.notes,
      externalId: row.externalId,
      creatorUuid: row.creatorUuid,
      ownerUuid: row.ownerUuid,
      exercises: exercises,
    );
  }

  /// Build a [model.CardioSession] from a Drift row plus preloaded children.
  static model.CardioSession cardioFromRow(
    Session row, {
    CardioDetail? detail,
    List<model.SessionInterval> intervals = const [],
    List<model.SessionSample>? samples,
  }) {
    return model.CardioSession(
      id: row.uuid,
      trainingCycleId: row.trainingCycleUuid,
      sport: Sport.values[row.sport],
      source: SessionSource.values[row.source],
      status: WorkoutStatus.values[row.status],
      periodNumber: row.periodNumber,
      dayNumber: row.dayNumber,
      dayName: row.dayName,
      label: row.label,
      scheduledDate: row.scheduledDate,
      completedDate: row.completedDate,
      startTime: row.startTime,
      endTime: row.endTime,
      notes: row.notes,
      externalId: row.externalId,
      creatorUuid: row.creatorUuid,
      ownerUuid: row.ownerUuid,
      detail: detail,
      intervals: intervals,
      samples: samples,
    );
  }

  /// Convert a domain [model.Session] to a Drift companion. The caller is
  /// responsible for persisting children (exercises for strength, cardio
  /// detail / intervals / samples for cardio).
  static SessionsCompanion toCompanion(model.Session session) {
    return SessionsCompanion(
      uuid: Value(session.id),
      trainingCycleUuid: Value(session.trainingCycleId),
      sport: Value(session.sport.index),
      source: Value(session.source.index),
      periodNumber: Value(session.periodNumber),
      dayNumber: Value(session.dayNumber),
      dayName: Value(session.dayName),
      label: Value(session.label),
      status: Value(session.status.index),
      scheduledDate: Value(session.scheduledDate),
      completedDate: Value(session.completedDate),
      startTime: Value(session.startTime),
      endTime: Value(session.endTime),
      notes: Value(session.notes),
      externalId: Value(session.externalId),
      creatorUuid: Value(session.creatorUuid),
      ownerUuid: Value(session.ownerUuid),
    );
  }
}

/// Converts between [SessionCardio] rows and [CardioDetail] models.
class CardioDetailMapper {
  static CardioDetail fromRow(SessionCardioData row) {
    return CardioDetail(
      plannedDistanceM: row.plannedDistanceM,
      actualDistanceM: row.actualDistanceM,
      plannedDurationSec: row.plannedDurationSec,
      actualDurationSec: row.actualDurationSec,
      elevationGainM: row.elevationGainM,
      elevationLossM: row.elevationLossM,
      averageHr: row.averageHr,
      maxHr: row.maxHr,
      averageCadence: row.averageCadence,
      averagePowerWatts: row.averagePowerWatts,
      normalizedPowerWatts: row.normalizedPowerWatts,
      averageSpeedMps: row.averageSpeedMps,
      averagePaceSecPerMeter: row.averagePaceSecPerMeter,
      poolLengthM: row.poolLengthM,
      strokeType: row.strokeType != null
          ? StrokeType.values[row.strokeType!]
          : null,
      lapCount: row.lapCount,
      swolf: row.swolf,
      perceivedExertion: row.perceivedExertion,
      notes: row.notes,
    );
  }

  static SessionCardioCompanion toCompanion(
    String sessionUuid,
    CardioDetail detail,
  ) {
    return SessionCardioCompanion(
      sessionUuid: Value(sessionUuid),
      plannedDistanceM: Value(detail.plannedDistanceM),
      actualDistanceM: Value(detail.actualDistanceM),
      plannedDurationSec: Value(detail.plannedDurationSec),
      actualDurationSec: Value(detail.actualDurationSec),
      elevationGainM: Value(detail.elevationGainM),
      elevationLossM: Value(detail.elevationLossM),
      averageHr: Value(detail.averageHr),
      maxHr: Value(detail.maxHr),
      averageCadence: Value(detail.averageCadence),
      averagePowerWatts: Value(detail.averagePowerWatts),
      normalizedPowerWatts: Value(detail.normalizedPowerWatts),
      averageSpeedMps: Value(detail.averageSpeedMps),
      averagePaceSecPerMeter: Value(detail.averagePaceSecPerMeter),
      poolLengthM: Value(detail.poolLengthM),
      strokeType: Value(detail.strokeType?.index),
      lapCount: Value(detail.lapCount),
      swolf: Value(detail.swolf),
      perceivedExertion: Value(detail.perceivedExertion),
      notes: Value(detail.notes),
    );
  }
}

/// Converts between [SessionIntervals] rows and [model.SessionInterval]s.
class SessionIntervalMapper {
  static model.SessionInterval fromRow(SessionInterval row) {
    return model.SessionInterval(
      id: row.uuid,
      sessionId: row.sessionUuid,
      orderIndex: row.orderIndex,
      intent: IntervalIntent.values[row.intentType],
      targetKind: IntervalTargetKind.values[row.targetKind],
      targetDurationSec: row.targetDurationSec,
      targetDistanceM: row.targetDistanceM,
      targetHrZone: row.targetHrZone,
      targetPaceZone: row.targetPaceZone,
      targetPowerZone: row.targetPowerZone,
      targetValueMin: row.targetValueMin,
      targetValueMax: row.targetValueMax,
      targetFreeform: row.targetFreeform,
      actualDurationSec: row.actualDurationSec,
      actualDistanceM: row.actualDistanceM,
      actualAverageHr: row.actualAverageHr,
      actualAveragePaceSecPerMeter: row.actualAveragePaceSecPerMeter,
      actualAveragePowerWatts: row.actualAveragePowerWatts,
      repeatCount: row.repeatCount,
      parentIntervalId: row.parentIntervalUuid,
      notes: row.notes,
    );
  }

  static SessionIntervalsCompanion toCompanion(
    model.SessionInterval interval,
  ) {
    return SessionIntervalsCompanion(
      uuid: Value(interval.id),
      sessionUuid: Value(interval.sessionId),
      orderIndex: Value(interval.orderIndex),
      intentType: Value(interval.intent.index),
      targetKind: Value(interval.targetKind.index),
      targetDurationSec: Value(interval.targetDurationSec),
      targetDistanceM: Value(interval.targetDistanceM),
      targetHrZone: Value(interval.targetHrZone),
      targetPaceZone: Value(interval.targetPaceZone),
      targetPowerZone: Value(interval.targetPowerZone),
      targetValueMin: Value(interval.targetValueMin),
      targetValueMax: Value(interval.targetValueMax),
      targetFreeform: Value(interval.targetFreeform),
      actualDurationSec: Value(interval.actualDurationSec),
      actualDistanceM: Value(interval.actualDistanceM),
      actualAverageHr: Value(interval.actualAverageHr),
      actualAveragePaceSecPerMeter:
          Value(interval.actualAveragePaceSecPerMeter),
      actualAveragePowerWatts: Value(interval.actualAveragePowerWatts),
      repeatCount: Value(interval.repeatCount),
      parentIntervalUuid: Value(interval.parentIntervalId),
      notes: Value(interval.notes),
    );
  }
}

/// Converts between [SessionSamples] rows and [model.SessionSample]s.
class SessionSampleMapper {
  static model.SessionSample fromRow(SessionSample row) {
    return model.SessionSample(
      sessionId: row.sessionUuid,
      offsetSec: row.offsetSec,
      lat: row.lat,
      lng: row.lng,
      altitudeM: row.altitudeM,
      hr: row.hr,
      cadence: row.cadence,
      powerW: row.powerW,
      speedMps: row.speedMps,
      strokeRate: row.strokeRate,
    );
  }

  static SessionSamplesCompanion toCompanion(model.SessionSample sample) {
    return SessionSamplesCompanion(
      sessionUuid: Value(sample.sessionId),
      offsetSec: Value(sample.offsetSec),
      lat: Value(sample.lat),
      lng: Value(sample.lng),
      altitudeM: Value(sample.altitudeM),
      hr: Value(sample.hr),
      cadence: Value(sample.cadence),
      powerW: Value(sample.powerW),
      speedMps: Value(sample.speedMps),
      strokeRate: Value(sample.strokeRate),
    );
  }
}

/// Converts between [SportZones] rows and [model.SportZone]s.
class SportZoneMapper {
  static model.SportZone fromRow(SportZone row) {
    return model.SportZone(
      id: row.uuid,
      sport: Sport.values[row.sport],
      zoneNumber: row.zoneNumber,
      minValue: row.minValue,
      maxValue: row.maxValue,
      unit: row.unit,
      ownerUuid: row.ownerUuid,
      createdAt: row.createdAt,
    );
  }

  static SportZonesCompanion toCompanion(model.SportZone zone) {
    return SportZonesCompanion(
      uuid: Value(zone.id),
      sport: Value(zone.sport.index),
      zoneNumber: Value(zone.zoneNumber),
      minValue: Value(zone.minValue),
      maxValue: Value(zone.maxValue),
      unit: Value(zone.unit),
      ownerUuid: Value(zone.ownerUuid),
      createdAt: Value(zone.createdAt),
    );
  }
}

/// Converts between [CardioFeedback] rows and [model.CardioFeedback]s.
class CardioFeedbackMapper {
  static model.CardioFeedback fromRow(CardioFeedbackData row) {
    return model.CardioFeedback(
      rpe: row.rpe,
      breathing: row.breathing,
      giComfort: row.giComfort,
      weather: row.weather,
      notes: row.notes,
      timestamp: row.timestamp,
      creatorUuid: row.creatorUuid,
      ownerUuid: row.ownerUuid,
    );
  }

  static CardioFeedbackCompanion toCompanion(
    String sessionUuid,
    model.CardioFeedback feedback,
  ) {
    return CardioFeedbackCompanion(
      sessionUuid: Value(sessionUuid),
      rpe: Value(feedback.rpe),
      breathing: Value(feedback.breathing),
      giComfort: Value(feedback.giComfort),
      weather: Value(feedback.weather),
      notes: Value(feedback.notes),
      timestamp: Value(feedback.timestamp),
      creatorUuid: Value(feedback.creatorUuid),
      ownerUuid: Value(feedback.ownerUuid),
    );
  }
}

/// Converts between [CyclePeriods] rows and [model.CyclePeriod]s.
class CyclePeriodMapper {
  static model.CyclePeriod fromRow(CyclePeriod row) {
    return model.CyclePeriod(
      id: row.uuid,
      trainingCycleId: row.trainingCycleUuid,
      periodNumber: row.periodNumber,
      phase: row.phase != null ? TrainingPhase.values[row.phase!] : null,
      notes: row.notes,
      creatorUuid: row.creatorUuid,
      ownerUuid: row.ownerUuid,
    );
  }

  static CyclePeriodsCompanion toCompanion(model.CyclePeriod period) {
    return CyclePeriodsCompanion(
      uuid: Value(period.id),
      trainingCycleUuid: Value(period.trainingCycleId),
      periodNumber: Value(period.periodNumber),
      phase: Value(period.phase?.index),
      notes: Value(period.notes),
      creatorUuid: Value(period.creatorUuid),
      ownerUuid: Value(period.ownerUuid),
    );
  }
}
