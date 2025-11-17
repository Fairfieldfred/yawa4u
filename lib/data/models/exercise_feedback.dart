import 'package:hive/hive.dart';
import '../../core/constants/enums.dart';

part 'exercise_feedback.g.dart';

/// Tracks post-workout feedback for muscle groups
///
/// Includes joint pain, muscle pump, workload difficulty,
/// and soreness ratings for each trained muscle group.
@HiveType(typeId: 1)
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
  Map<String, dynamic> toJson() {
    return {
      'jointPain': jointPain?.name,
      'musclePump': musclePump?.name,
      'workload': workload?.name,
      'soreness': soreness?.name,
      'muscleGroupSoreness': muscleGroupSoreness?.map(
        (key, value) => MapEntry(key, value.name),
      ),
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Create from JSON for import
  factory ExerciseFeedback.fromJson(Map<String, dynamic> json) {
    return ExerciseFeedback(
      jointPain: json['jointPain'] != null
          ? JointPain.values.firstWhere(
              (e) => e.name == json['jointPain'],
              orElse: () => JointPain.none,
            )
          : null,
      musclePump: json['musclePump'] != null
          ? MusclePump.values.firstWhere(
              (e) => e.name == json['musclePump'],
              orElse: () => MusclePump.moderate,
            )
          : null,
      workload: json['workload'] != null
          ? Workload.values.firstWhere(
              (e) => e.name == json['workload'],
              orElse: () => Workload.prettyGood,
            )
          : null,
      soreness: json['soreness'] != null
          ? Soreness.values.firstWhere(
              (e) => e.name == json['soreness'],
              orElse: () => Soreness.healedJustOnTime,
            )
          : null,
      muscleGroupSoreness: json['muscleGroupSoreness'] != null
          ? (json['muscleGroupSoreness'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                Soreness.values.firstWhere(
                  (e) => e.name == value,
                  orElse: () => Soreness.healedJustOnTime,
                ),
              ),
            )
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

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
    return Object.hash(
      jointPain,
      musclePump,
      workload,
      soreness,
      timestamp,
    );
  }
}
