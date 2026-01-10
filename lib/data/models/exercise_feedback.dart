import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/constants/enums.dart';

part 'exercise_feedback.g.dart';

/// Tracks post-workout feedback for muscle groups
///
/// Includes joint pain, muscle pump, workload difficulty,
/// and soreness ratings for each trained muscle group.
@HiveType(typeId: 1)
@JsonSerializable()
class ExerciseFeedback {
  @HiveField(0)
  final JointPain? jointPain;

  @HiveField(1)
  final MusclePump? musclePump;

  @HiveField(2)
  final Workload? workload;

  @HiveField(3)
  final Soreness? soreness;

  /// Map of muscle group to soreness level (for tracking specific muscle soreness)
  @HiveField(4)
  final Map<String, Soreness>? muscleGroupSoreness;

  @HiveField(5)
  final DateTime? timestamp;

  ExerciseFeedback({
    this.jointPain,
    this.musclePump,
    this.workload,
    this.soreness,
    this.muscleGroupSoreness,
    this.timestamp,
  });

  /// Create a copy with updated fields
  ExerciseFeedback copyWith({
    JointPain? jointPain,
    MusclePump? musclePump,
    Workload? workload,
    Soreness? soreness,
    Map<String, Soreness>? muscleGroupSoreness,
    DateTime? timestamp,
  }) {
    return ExerciseFeedback(
      jointPain: jointPain ?? this.jointPain,
      musclePump: musclePump ?? this.musclePump,
      workload: workload ?? this.workload,
      soreness: soreness ?? this.soreness,
      muscleGroupSoreness: muscleGroupSoreness ?? this.muscleGroupSoreness,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Check if any feedback has been provided
  bool get hasAnyFeedback {
    return jointPain != null ||
        musclePump != null ||
        workload != null ||
        soreness != null ||
        (muscleGroupSoreness?.isNotEmpty ?? false);
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() => _$ExerciseFeedbackToJson(this);

  /// Create from JSON for import
  factory ExerciseFeedback.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFeedbackFromJson(json);

  @override
  String toString() {
    return 'ExerciseFeedback(jointPain: $jointPain, pump: $musclePump, workload: $workload, soreness: $soreness)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseFeedback &&
        other.jointPain == jointPain &&
        other.musclePump == musclePump &&
        other.workload == workload &&
        other.soreness == soreness &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(jointPain, musclePump, workload, soreness, timestamp);
  }
}
