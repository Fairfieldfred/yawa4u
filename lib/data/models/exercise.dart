import 'package:hive/hive.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/enums.dart';
import 'exercise_set.dart';
import 'exercise_feedback.dart';

part 'exercise.g.dart';

/// Represents an exercise within a workout
///
/// Contains exercise details, sets, feedback, and tracking information.
@HiveType(typeId: 2)
class Exercise {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String workoutId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final MuscleGroup muscleGroup;

  @HiveField(4)
  final EquipmentType equipmentType;

  @HiveField(5)
  final List<ExerciseSet> sets;

  @HiveField(6)
  final int orderIndex;

  @HiveField(7)
  final double? bodyweight;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final ExerciseFeedback? feedback;

  @HiveField(10)
  final DateTime? lastPerformed;

  @HiveField(11)
  final String? videoUrl;

  Exercise({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.muscleGroup,
    required this.equipmentType,
    List<ExerciseSet>? sets,
    this.orderIndex = 0,
    this.bodyweight,
    this.notes,
    this.feedback,
    this.lastPerformed,
    this.videoUrl,
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
    return sets.any((s) =>
        s.setType == SetType.myorep || s.setType == SetType.myorepMatch);
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
    EquipmentType? equipmentType,
    List<ExerciseSet>? sets,
    int? orderIndex,
    double? bodyweight,
    String? notes,
    ExerciseFeedback? feedback,
    DateTime? lastPerformed,
    String? videoUrl,
  }) {
    return Exercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipmentType: equipmentType ?? this.equipmentType,
      sets: sets ?? this.sets,
      orderIndex: orderIndex ?? this.orderIndex,
      bodyweight: bodyweight ?? this.bodyweight,
      notes: notes ?? this.notes,
      feedback: feedback ?? this.feedback,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'name': name,
      'muscleGroup': muscleGroup.name,
      'equipmentType': equipmentType.name,
      'sets': sets.map((s) => s.toJson()).toList(),
      'orderIndex': orderIndex,
      'bodyweight': bodyweight,
      'notes': notes,
      'feedback': feedback?.toJson(),
      'lastPerformed': lastPerformed?.toIso8601String(),
      'videoUrl': videoUrl,
    };
  }

  /// Create from JSON for import
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      workoutId: json['workoutId'] as String,
      name: json['name'] as String,
      muscleGroup: MuscleGroup.values.firstWhere(
        (e) => e.name == json['muscleGroup'],
        orElse: () => MuscleGroup.chest,
      ),
      equipmentType: EquipmentType.values.firstWhere(
        (e) => e.name == json['equipmentType'],
        orElse: () => EquipmentType.barbell,
      ),
      sets: (json['sets'] as List?)
              ?.map((s) => ExerciseSet.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      orderIndex: json['orderIndex'] as int? ?? 0,
      bodyweight: json['bodyweight'] as double?,
      notes: json['notes'] as String?,
      feedback: json['feedback'] != null
          ? ExerciseFeedback.fromJson(json['feedback'] as Map<String, dynamic>)
          : null,
      lastPerformed: json['lastPerformed'] != null
          ? DateTime.parse(json['lastPerformed'] as String)
          : null,
      videoUrl: json['videoUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'Exercise(name: $name, muscleGroup: ${muscleGroup.name}, sets: ${sets.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Exercise &&
        other.id == id &&
        other.workoutId == workoutId &&
        other.name == name &&
        other.muscleGroup == muscleGroup &&
        other.equipmentType == equipmentType;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      workoutId,
      name,
      muscleGroup,
      equipmentType,
    );
  }
}
