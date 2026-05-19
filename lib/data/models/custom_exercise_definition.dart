import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import 'exercise_definition.dart';

/// A user-created custom exercise definition
///
/// This allows users to add their own exercises to the exercise library.
class CustomExerciseDefinition {
  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final MuscleGroup? secondaryMuscleGroup;
  final EquipmentType equipmentType;
  final String? videoUrl;
  final int? restSeconds;
  final DateTime createdAt;

  CustomExerciseDefinition({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscleGroup,
    required this.equipmentType,
    this.videoUrl,
    this.restSeconds,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to ExerciseDefinition for use in the exercise library
  ExerciseDefinition toExerciseDefinition() {
    return ExerciseDefinition(
      name: name,
      muscleGroup: muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup,
      equipmentType: equipmentType,
      videoUrl: videoUrl,
      restSeconds: restSeconds,
    );
  }

  /// Create a copy with updated fields
  CustomExerciseDefinition copyWith({
    String? id,
    String? name,
    MuscleGroup? muscleGroup,
    MuscleGroup? secondaryMuscleGroup,
    EquipmentType? equipmentType,
    String? videoUrl,
    int? restSeconds,
    DateTime? createdAt,
  }) {
    return CustomExerciseDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup ?? this.secondaryMuscleGroup,
      equipmentType: equipmentType ?? this.equipmentType,
      videoUrl: videoUrl ?? this.videoUrl,
      restSeconds: restSeconds ?? this.restSeconds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup.name,
      'secondaryMuscleGroup': secondaryMuscleGroup?.name,
      'equipmentType': equipmentType.name,
      'videoUrl': videoUrl,
      'restSeconds': restSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CustomExerciseDefinition.fromJson(Map<String, dynamic> json) {
    return CustomExerciseDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: MuscleGroup.values.firstWhere(
        (e) => e.name == json['muscleGroup'],
        orElse: () => MuscleGroup.chest,
      ),
      secondaryMuscleGroup: json['secondaryMuscleGroup'] != null
          ? MuscleGroup.values.firstWhere(
              (e) => e.name == json['secondaryMuscleGroup'],
              orElse: () => MuscleGroup.chest,
            )
          : null,
      equipmentType: EquipmentType.values.firstWhere(
        (e) => e.name == json['equipmentType'],
        orElse: () => EquipmentType.barbell,
      ),
      videoUrl: json['videoUrl'] as String?,
      restSeconds: json['restSeconds'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
    );
  }

  @override
  String toString() {
    final secondary = secondaryMuscleGroup != null ? '/${secondaryMuscleGroup!.name}' : '';
    return 'CustomExerciseDefinition(id: $id, name: $name, muscleGroup: ${muscleGroup.name}$secondary, equipment: ${equipmentType.name})';
  }
}
