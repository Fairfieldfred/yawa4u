import 'package:hive/hive.dart';

part 'user_measurement.g.dart';

/// Represents a user's body measurement at a point in time
///
/// Used to track weight and height changes over time for BMI graphing.
@HiveType(typeId: 24)
class UserMeasurement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double heightCm;

  @HiveField(2)
  final double weightKg;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? notes;

  /// DEXA scan body fat percentage (optional)
  @HiveField(5)
  final double? bodyFatPercent;

  /// DEXA scan lean mass in kg (optional)
  @HiveField(6)
  final double? leanMassKg;

  UserMeasurement({
    required this.id,
    required this.heightCm,
    required this.weightKg,
    required this.timestamp,
    this.notes,
    this.bodyFatPercent,
    this.leanMassKg,
  });

  /// Calculate BMI from this measurement
  double get bmi {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Calculate lean mass from body fat percentage if not directly available
  double? get calculatedLeanMassKg {
    if (leanMassKg != null) return leanMassKg;
    if (bodyFatPercent != null) {
      return weightKg * (1 - bodyFatPercent! / 100);
    }
    return null;
  }

  /// Calculate fat mass in kg
  double? get fatMassKg {
    if (bodyFatPercent != null) {
      return weightKg * (bodyFatPercent! / 100);
    }
    return null;
  }

  /// Create a copy with updated fields
  UserMeasurement copyWith({
    String? id,
    double? heightCm,
    double? weightKg,
    DateTime? timestamp,
    String? notes,
    double? bodyFatPercent,
    double? leanMassKg,
  }) {
    return UserMeasurement(
      id: id ?? this.id,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      bodyFatPercent: bodyFatPercent ?? this.bodyFatPercent,
      leanMassKg: leanMassKg ?? this.leanMassKg,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'bodyFatPercent': bodyFatPercent,
      'leanMassKg': leanMassKg,
    };
  }

  /// Create from JSON map
  factory UserMeasurement.fromJson(Map<String, dynamic> json) {
    return UserMeasurement(
      id: json['id'] as String,
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
      leanMassKg: (json['leanMassKg'] as num?)?.toDouble(),
    );
  }
}
