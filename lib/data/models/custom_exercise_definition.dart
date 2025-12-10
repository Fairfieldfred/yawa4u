import 'package:hive/hive.dart';

import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import 'exercise_definition.dart';

part 'custom_exercise_definition.g.dart';

/// A user-created custom exercise definition stored in Hive
///
/// This allows users to add their own exercises to the exercise library.
@HiveType(typeId: 22)
class CustomExerciseDefinition extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final MuscleGroup muscleGroup;

  @HiveField(3)
  final EquipmentType equipmentType;

  @HiveField(4)
  final String? videoUrl;

  @HiveField(5)
  final DateTime createdAt;

  CustomExerciseDefinition({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipmentType,
    this.videoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to ExerciseDefinition for use in the exercise library
  ExerciseDefinition toExerciseDefinition() {
    return ExerciseDefinition(
      name: name,
      muscleGroup: muscleGroup,
      equipmentType: equipmentType,
      videoUrl: videoUrl,
    );
  }

  /// Create a copy with updated fields
  CustomExerciseDefinition copyWith({
    String? id,
    String? name,
    MuscleGroup? muscleGroup,
    EquipmentType? equipmentType,
    String? videoUrl,
    DateTime? createdAt,
  }) {
    return CustomExerciseDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipmentType: equipmentType ?? this.equipmentType,
      videoUrl: videoUrl ?? this.videoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup.name,
      'equipmentType': equipmentType.name,
      'videoUrl': videoUrl,
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
      equipmentType: EquipmentType.values.firstWhere(
        (e) => e.name == json['equipmentType'],
        orElse: () => EquipmentType.barbell,
      ),
      videoUrl: json['videoUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'CustomExerciseDefinition(id: $id, name: $name, muscleGroup: ${muscleGroup.name}, equipment: ${equipmentType.name})';
  }
}
