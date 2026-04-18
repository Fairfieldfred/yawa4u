import '../../core/constants/sports.dart';

/// Aggregated cardio metrics for a single cardio session.
///
/// Every field is nullable: planned sessions may have no actuals yet, and
/// imported sessions may have no planned values. Unit conventions:
///   * distance: meters
///   * duration: seconds
///   * elevation: meters
///   * heart rate: bpm
///   * cadence: rpm (bike) or steps/min (run) or strokes/min (swim)
///   * power: watts
///   * speed: meters/second
///   * pace: seconds/meter  (pace_per_km = paceSecPerMeter * 1000)
class CardioDetail {
  final double? plannedDistanceM;
  final double? actualDistanceM;
  final int? plannedDurationSec;
  final int? actualDurationSec;

  final double? elevationGainM;
  final double? elevationLossM;

  final int? averageHr;
  final int? maxHr;

  final double? averageCadence;
  final double? averagePowerWatts;
  final double? normalizedPowerWatts;

  final double? averageSpeedMps;
  final double? averagePaceSecPerMeter;

  // Swim-specific.
  final double? poolLengthM;
  final StrokeType? strokeType;
  final int? lapCount;
  final int? swolf;

  // Subjective.
  final int? perceivedExertion; // 1..10
  final String? notes;

  const CardioDetail({
    this.plannedDistanceM,
    this.actualDistanceM,
    this.plannedDurationSec,
    this.actualDurationSec,
    this.elevationGainM,
    this.elevationLossM,
    this.averageHr,
    this.maxHr,
    this.averageCadence,
    this.averagePowerWatts,
    this.normalizedPowerWatts,
    this.averageSpeedMps,
    this.averagePaceSecPerMeter,
    this.poolLengthM,
    this.strokeType,
    this.lapCount,
    this.swolf,
    this.perceivedExertion,
    this.notes,
  });

  /// True if there are any actual / recorded values (as opposed to only
  /// planned). A good proxy for "was this session performed".
  bool get hasActuals =>
      actualDistanceM != null ||
      actualDurationSec != null ||
      averageHr != null ||
      averagePowerWatts != null;

  CardioDetail copyWith({
    double? plannedDistanceM,
    double? actualDistanceM,
    int? plannedDurationSec,
    int? actualDurationSec,
    double? elevationGainM,
    double? elevationLossM,
    int? averageHr,
    int? maxHr,
    double? averageCadence,
    double? averagePowerWatts,
    double? normalizedPowerWatts,
    double? averageSpeedMps,
    double? averagePaceSecPerMeter,
    double? poolLengthM,
    StrokeType? strokeType,
    int? lapCount,
    int? swolf,
    int? perceivedExertion,
    String? notes,
  }) {
    return CardioDetail(
      plannedDistanceM: plannedDistanceM ?? this.plannedDistanceM,
      actualDistanceM: actualDistanceM ?? this.actualDistanceM,
      plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      elevationLossM: elevationLossM ?? this.elevationLossM,
      averageHr: averageHr ?? this.averageHr,
      maxHr: maxHr ?? this.maxHr,
      averageCadence: averageCadence ?? this.averageCadence,
      averagePowerWatts: averagePowerWatts ?? this.averagePowerWatts,
      normalizedPowerWatts: normalizedPowerWatts ?? this.normalizedPowerWatts,
      averageSpeedMps: averageSpeedMps ?? this.averageSpeedMps,
      averagePaceSecPerMeter:
          averagePaceSecPerMeter ?? this.averagePaceSecPerMeter,
      poolLengthM: poolLengthM ?? this.poolLengthM,
      strokeType: strokeType ?? this.strokeType,
      lapCount: lapCount ?? this.lapCount,
      swolf: swolf ?? this.swolf,
      perceivedExertion: perceivedExertion ?? this.perceivedExertion,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'plannedDistanceM': plannedDistanceM,
    'actualDistanceM': actualDistanceM,
    'plannedDurationSec': plannedDurationSec,
    'actualDurationSec': actualDurationSec,
    'elevationGainM': elevationGainM,
    'elevationLossM': elevationLossM,
    'averageHr': averageHr,
    'maxHr': maxHr,
    'averageCadence': averageCadence,
    'averagePowerWatts': averagePowerWatts,
    'normalizedPowerWatts': normalizedPowerWatts,
    'averageSpeedMps': averageSpeedMps,
    'averagePaceSecPerMeter': averagePaceSecPerMeter,
    'poolLengthM': poolLengthM,
    'strokeType': strokeType?.name,
    'lapCount': lapCount,
    'swolf': swolf,
    'perceivedExertion': perceivedExertion,
    'notes': notes,
  };

  factory CardioDetail.fromJson(Map<String, dynamic> json) {
    return CardioDetail(
      plannedDistanceM: (json['plannedDistanceM'] as num?)?.toDouble(),
      actualDistanceM: (json['actualDistanceM'] as num?)?.toDouble(),
      plannedDurationSec: json['plannedDurationSec'] as int?,
      actualDurationSec: json['actualDurationSec'] as int?,
      elevationGainM: (json['elevationGainM'] as num?)?.toDouble(),
      elevationLossM: (json['elevationLossM'] as num?)?.toDouble(),
      averageHr: json['averageHr'] as int?,
      maxHr: json['maxHr'] as int?,
      averageCadence: (json['averageCadence'] as num?)?.toDouble(),
      averagePowerWatts: (json['averagePowerWatts'] as num?)?.toDouble(),
      normalizedPowerWatts:
          (json['normalizedPowerWatts'] as num?)?.toDouble(),
      averageSpeedMps: (json['averageSpeedMps'] as num?)?.toDouble(),
      averagePaceSecPerMeter:
          (json['averagePaceSecPerMeter'] as num?)?.toDouble(),
      poolLengthM: (json['poolLengthM'] as num?)?.toDouble(),
      strokeType: json['strokeType'] != null
          ? StrokeType.values.firstWhere(
              (e) => e.name == json['strokeType'],
              orElse: () => StrokeType.freestyle,
            )
          : null,
      lapCount: json['lapCount'] as int?,
      swolf: json['swolf'] as int?,
      perceivedExertion: json['perceivedExertion'] as int?,
      notes: json['notes'] as String?,
    );
  }
}
