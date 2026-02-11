import '../../core/constants/muscle_groups.dart';
import '../../core/constants/equipment_types.dart';

/// Represents an exercise definition from the CSV library
///
/// Contains basic exercise information without tracking data.
/// This is used for the exercise library/picker.
class ExerciseDefinition {
  final String name;
  final MuscleGroup muscleGroup;
  final MuscleGroup? secondaryMuscleGroup;
  final EquipmentType equipmentType;
  final String? videoUrl;

  const ExerciseDefinition({
    required this.name,
    required this.muscleGroup,
    this.secondaryMuscleGroup,
    required this.equipmentType,
    this.videoUrl,
  });

  /// Create from CSV row
  ///
  /// Expected format: name,muscleGroup,equipmentType
  /// Muscle group can be compound: "Primary/Secondary" (e.g., "Glutes/Hamstrings")
  factory ExerciseDefinition.fromCsv(List<String> row) {
    if (row.length < 3) {
      throw ArgumentError('CSV row must have at least 3 columns: $row');
    }

    final name = row[0].trim();
    final muscleGroupStr = row[1].trim();
    final equipmentTypeStr = row[2].trim();

    // Parse muscle group(s) - handle "Primary/Secondary" format
    MuscleGroup? primaryMuscleGroup;
    MuscleGroup? secondaryMuscleGroup;

    if (muscleGroupStr.contains('/')) {
      final parts = muscleGroupStr.split('/');
      primaryMuscleGroup = MuscleGroups.parse(parts[0].trim());
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        secondaryMuscleGroup = MuscleGroups.parse(parts[1].trim());
        // Log warning if secondary is invalid but don't fail
        // Invalid secondary will just be null
      }
    } else {
      primaryMuscleGroup = MuscleGroups.parse(muscleGroupStr);
    }

    if (primaryMuscleGroup == null) {
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
      muscleGroup: primaryMuscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup,
      equipmentType: equipmentType,
    );
  }

  /// Convert to CSV row
  List<String> toCsv() {
    final muscleGroupDisplay = secondaryMuscleGroup != null
        ? '${muscleGroup.displayName}/${secondaryMuscleGroup!.displayName}'
        : muscleGroup.displayName;
    return [
      name,
      muscleGroupDisplay,
      equipmentType.displayName,
    ];
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscleGroup': muscleGroup.name,
      'secondaryMuscleGroup': secondaryMuscleGroup?.name,
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
    );
  }

  /// Create a copy with modified fields
  ExerciseDefinition copyWith({
    String? name,
    MuscleGroup? muscleGroup,
    MuscleGroup? secondaryMuscleGroup,
    EquipmentType? equipmentType,
    String? videoUrl,
  }) {
    return ExerciseDefinition(
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      secondaryMuscleGroup: secondaryMuscleGroup ?? this.secondaryMuscleGroup,
      equipmentType: equipmentType ?? this.equipmentType,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }

  @override
  String toString() {
    final secondary = secondaryMuscleGroup != null
        ? ', secondary: ${secondaryMuscleGroup!.name}'
        : '';
    return 'ExerciseDefinition(name: $name, muscleGroup: ${muscleGroup.name}$secondary, equipment: ${equipmentType.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExerciseDefinition &&
        other.name == name &&
        other.muscleGroup == muscleGroup &&
        other.secondaryMuscleGroup == secondaryMuscleGroup &&
        other.equipmentType == equipmentType;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      muscleGroup,
      secondaryMuscleGroup,
      equipmentType,
    );
  }
}
