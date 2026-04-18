/// A single recorded sample point within a cardio session.
///
/// Sample rate is whatever the importing device / service provides
/// (typically 1 Hz for HealthKit / Strava / Garmin). Fields are all nullable
/// because sources vary in what they record — a treadmill run has no GPS;
/// a rowing erg has no altitude.
class SessionSample {
  final String sessionId;
  final int offsetSec;
  final double? lat;
  final double? lng;
  final double? altitudeM;
  final int? hr;
  final double? cadence;
  final double? powerW;
  final double? speedMps;
  final double? strokeRate;

  const SessionSample({
    required this.sessionId,
    required this.offsetSec,
    this.lat,
    this.lng,
    this.altitudeM,
    this.hr,
    this.cadence,
    this.powerW,
    this.speedMps,
    this.strokeRate,
  });

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'offsetSec': offsetSec,
    'lat': lat,
    'lng': lng,
    'altitudeM': altitudeM,
    'hr': hr,
    'cadence': cadence,
    'powerW': powerW,
    'speedMps': speedMps,
    'strokeRate': strokeRate,
  };

  factory SessionSample.fromJson(Map<String, dynamic> json) => SessionSample(
    sessionId: json['sessionId'] as String,
    offsetSec: json['offsetSec'] as int,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    altitudeM: (json['altitudeM'] as num?)?.toDouble(),
    hr: json['hr'] as int?,
    cadence: (json['cadence'] as num?)?.toDouble(),
    powerW: (json['powerW'] as num?)?.toDouble(),
    speedMps: (json['speedMps'] as num?)?.toDouble(),
    strokeRate: (json['strokeRate'] as num?)?.toDouble(),
  );
}
