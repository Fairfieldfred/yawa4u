import '../../core/constants/muscle_groups.dart';
import '../../core/constants/equipment_types.dart';

/// Represents an exercise definition from the CSV library
///
/// Contains basic exercise information without tracking data.
/// This is used for the exercise library/picker.
class ExerciseDefinition {
  final String name;
  final MuscleGroup muscleGroup;
  final EquipmentType equipmentType;
  final String? videoUrl;

  const ExerciseDefinition({
    required this.name,
    required this.muscleGroup,
    required this.equipmentType,
    this.videoUrl,
  });

  /// Create from CSV row
  ///
  /// Expected format: name,muscleGroup,equipmentType
  factory ExerciseDefinition.fromCsv(List<String> row) {
    if (row.length < 3) {
      throw ArgumentError('CSV row must have at least 3 columns: $row');
    }

    final name = row[0].trim();
    final muscleGroupStr = row[1].trim();
    final equipmentTypeStr = row[2].trim();

    // Parse muscle group
    final muscleGroup = MuscleGroups.parse(muscleGroupStr);
    if (muscleGroup == null) {
      throw ArgumentError(
        'Invalid muscle group: $muscleGroupStr for exercise: $name',
      );
    }

    // Parse equipment type
    final equipmentType = EquipmentTypes.parse(equipmentTypeStr);
    if (equipmentType == null) {
      throw ArgumentError(
        'Invalid equipment type: $equipmentTypeStr for exercise: $name',
      );
    }

    return ExerciseDefinition(
      name: name,
      muscleGroup: muscleGroup,
      equipmentType: equipmentType,
    );
  }

  /// Convert to CSV row
  List<String> toCsv() {
    return [
      name,
      muscleGroup.displayName,
      equipmentType.displayName,
    ];
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscleGroup': muscleGroup.name,
      'equipmentType': equipmentType.name,
      'videoUrl': videoUrl,
    };
  }

  /// Create from JSON
  factory ExerciseDefinition.fromJson(Map<String, dynamic> json) {
    return ExerciseDefinition(
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
    );
  }

  @override
  String toString() {
    return 'ExerciseDefinition(name: $name, muscleGroup: ${muscleGroup.name}, equipment: ${equipmentType.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseDefinition &&
        other.name == name &&
        other.muscleGroup == muscleGroup &&
        other.equipmentType == equipmentType;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      muscleGroup,
      equipmentType,
    );
  }
}
