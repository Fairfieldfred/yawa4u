import 'package:json_annotation/json_annotation.dart';

import '../../core/constants/enums.dart';

part 'exercise_set.g.dart';

/// Represents a single set within an exercise
///
/// Tracks weight, reps (supporting RIR format like "2 RIR"),
/// set type (regular, myorep, myorep match), and logging status.
@JsonSerializable()
class ExerciseSet {
  final String id;
  final int setNumber;
  final double? weight;

  /// Reps can be a number or RIR format (e.g., "2 RIR")
  final String reps;
  final SetType setType;
  final bool isLogged;
  final String? notes;
  final bool isSkipped;

  ExerciseSet({
    required this.id,
    required this.setNumber,
    this.weight,
    required this.reps,
    this.setType = SetType.regular,
    this.isLogged = false,
    this.notes,
    this.isSkipped = false,
  });

  /// Create a copy with updated fields
  ExerciseSet copyWith({
    String? id,
    int? setNumber,
    double? weight,
    String? reps,
    SetType? setType,
    bool? isLogged,
    String? notes,
    bool? isSkipped,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      setType: setType ?? this.setType,
      isLogged: isLogged ?? this.isLogged,
      notes: notes ?? this.notes,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);

  /// Create from JSON for import
  factory ExerciseSet.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetFromJson(json);

  @override
  String toString() {
    return 'ExerciseSet(setNumber: $setNumber, weight: $weight, reps: $reps, type: ${setType.name}, skipped: $isSkipped)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseSet &&
        other.id == id &&
        other.setNumber == setNumber &&
        other.weight == weight &&
        other.reps == reps &&
        other.setType == setType &&
        other.isLogged == isLogged &&
        other.notes == notes &&
        other.isSkipped == isSkipped;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      setNumber,
      weight,
      reps,
      setType,
      isLogged,
      notes,
      isSkipped,
    );
  }
}
