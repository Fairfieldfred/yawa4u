import 'package:json_annotation/json_annotation.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import 'exercise_feedback.dart';
import 'exercise_set.dart';

part 'exercise.g.dart';

/// Represents an exercise within a workout
///
/// Contains exercise details, sets, feedback, and tracking information.
@JsonSerializable(explicitToJson: true)
class Exercise {
  final String id;
  final String workoutId;
  final String name;
  final MuscleGroup muscleGroup;
  final MuscleGroup? secondaryMuscleGroup;
  final EquipmentType equipmentType;
  final List<ExerciseSet> sets;
  final int orderIndex;
  final double? bodyweight;
  final String? notes;
  final ExerciseFeedback? feedback;
  final DateTime? lastPerformed;
  final String? videoUrl;
  final bool isNotePinned;

  Exercise({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscleGroup,
    required this.equipmentType,
    List<ExerciseSet>? sets,
    this.orderIndex = 0,
    this.bodyweight,
    this.notes,
    this.feedback,
    this.lastPerformed,
    this.videoUrl,
    this.isNotePinned = false,
  }) : sets = sets ?? [];

  /// Get total number of sets
  int get totalSets => sets.length;

  /// Get number of completed (logged) sets
  int get completedSets => sets.where((s) => s.isLogged).length;

  /// Check if all sets are completed
  bool get isCompleted => sets.isNotEmpty && sets.every((s) => s.isLogged);

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    if (sets.isEmpty) return 0.0;
    return completedSets / totalSets;
  }

  /// Check if exercise has any Myorep sets
  bool get hasMyorepSets {
    return sets.any(
      (s) => s.setType == SetType.myorep || s.setType == SetType.myorepMatch,
    );
  }

  /// Add a new set
  Exercise addSet(ExerciseSet set) {
    return copyWith(sets: [...sets, set]);
  }

  /// Remove a set by index
  Exercise removeSet(int index) {
    if (index < 0 || index >= sets.length) return this;
    final newSets = List<ExerciseSet>.from(sets);
    newSets.removeAt(index);
    return copyWith(sets: newSets);
  }

  /// Update a set at a specific index
  Exercise updateSet(int index, ExerciseSet set) {
    if (index < 0 || index >= sets.length) return this;
    final newSets = List<ExerciseSet>.from(sets);
    newSets[index] = set;
    return copyWith(sets: newSets);
  }

  /// Reorder sets
  Exercise reorderSet(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= sets.length ||
        newIndex < 0 ||
        newIndex >= sets.length) {
      return this;
    }
    final newSets = List<ExerciseSet>.from(sets);
    final set = newSets.removeAt(oldIndex);
    newSets.insert(newIndex, set);
    return copyWith(sets: newSets);
  }

  /// Create a copy with updated fields
  Exercise copyWith({
    String? id,
    String? workoutId,
    String? name,
    MuscleGroup? muscleGroup,
    MuscleGroup? secondaryMuscleGroup,
    EquipmentType? equipmentType,
    List<ExerciseSet>? sets,
    int? orderIndex,
    double? bodyweight,
    String? notes,
    ExerciseFeedback? feedback,
    DateTime? lastPerformed,
    String? videoUrl,
    bool? isNotePinned,
  }) {
    return Exercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup ?? this.secondaryMuscleGroup,
      equipmentType: equipmentType ?? this.equipmentType,
      sets: sets ?? this.sets,
      orderIndex: orderIndex ?? this.orderIndex,
      bodyweight: bodyweight ?? this.bodyweight,
      notes: notes ?? this.notes,
      feedback: feedback ?? this.feedback,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      videoUrl: videoUrl ?? this.videoUrl,
      isNotePinned: isNotePinned ?? this.isNotePinned,
    );
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  /// Create from JSON for import
  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  @override
  String toString() {
    final secondary = secondaryMuscleGroup != null
        ? '/${secondaryMuscleGroup!.name}'
        : '';
    return 'Exercise(name: $name, muscleGroup: ${muscleGroup.name}$secondary, sets: ${sets.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Exercise &&
        other.id == id &&
        other.workoutId == workoutId &&
        other.name == name &&
        other.muscleGroup == muscleGroup &&
        other.secondaryMuscleGroup == secondaryMuscleGroup &&
        other.equipmentType == equipmentType;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      workoutId,
      name,
      muscleGroup,
      secondaryMuscleGroup,
      equipmentType,
    );
  }
}
