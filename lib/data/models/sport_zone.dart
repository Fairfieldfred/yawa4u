import '../../core/constants/sports.dart';

/// A user's configured training zone for a given sport.
///
/// Zones are typically 5 per sport. [unit] describes what [minValue] /
/// [maxValue] are in — "bpm" for heart-rate zones, "sec_per_km" or
/// "sec_per_mi" for pace zones, "watts" for power zones.
class SportZone {
  final String id;
  final Sport sport;
  final int zoneNumber; // 1..5
  final double minValue;
  final double maxValue;
  final String unit;
  final String? ownerUuid;
  final DateTime createdAt;

  const SportZone({
    required this.id,
    required this.sport,
    required this.zoneNumber,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    this.ownerUuid,
    required this.createdAt,
  });

  /// True if [value] sits inside this zone's `[min, max)` half-open range.
  bool contains(double value) => value >= minValue && value < maxValue;

  SportZone copyWith({
    String? id,
    Sport? sport,
    int? zoneNumber,
    double? minValue,
    double? maxValue,
    String? unit,
    String? ownerUuid,
    DateTime? createdAt,
  }) {
    return SportZone(
      id: id ?? this.id,
      sport: sport ?? this.sport,
      zoneNumber: zoneNumber ?? this.zoneNumber,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      unit: unit ?? this.unit,
      ownerUuid: ownerUuid ?? this.ownerUuid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sport': sport.name,
    'zoneNumber': zoneNumber,
    'minValue': minValue,
    'maxValue': maxValue,
    'unit': unit,
    'ownerUuid': ownerUuid,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SportZone.fromJson(Map<String, dynamic> json) => SportZone(
    id: json['id'] as String,
    sport: Sport.values.firstWhere(
      (e) => e.name == json['sport'],
      orElse: () => Sport.other,
    ),
    zoneNumber: json['zoneNumber'] as int,
    minValue: (json['minValue'] as num).toDouble(),
    maxValue: (json['maxValue'] as num).toDouble(),
    unit: json['unit'] as String,
    ownerUuid: json['ownerUuid'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
