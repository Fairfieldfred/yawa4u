import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/constants/equipment_types.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../core/theme/skins/skin_model.dart';
import '../../models/custom_exercise_definition.dart' as model;
import '../../models/user_measurement.dart' as model;
import '../app_database.dart';

/// Converts between Drift CustomExerciseDefinition row and domain model
class CustomExerciseMapper {
  /// Convert a Drift CustomExerciseDefinition row to the domain model
  static model.CustomExerciseDefinition fromRow(CustomExerciseDefinition row) {
    return model.CustomExerciseDefinition(
      id: row.uuid,
      name: row.name,
      muscleGroup: MuscleGroup.values[row.muscleGroup],
      equipmentType: EquipmentType.values[row.equipmentType],
      videoUrl: row.videoUrl,
      createdAt: row.createdAt,
    );
  }

  /// Convert a domain CustomExerciseDefinition model to a Drift Companion
  static CustomExerciseDefinitionsCompanion toCompanion(
    model.CustomExerciseDefinition exercise,
  ) {
    return CustomExerciseDefinitionsCompanion(
      uuid: Value(exercise.id),
      name: Value(exercise.name),
      muscleGroup: Value(exercise.muscleGroup.index),
      equipmentType: Value(exercise.equipmentType.index),
      videoUrl: Value(exercise.videoUrl),
      createdAt: Value(exercise.createdAt),
    );
  }
}

/// Converts between Drift UserMeasurement row and domain model
class UserMeasurementMapper {
  /// Convert a Drift UserMeasurement row to the domain model
  static model.UserMeasurement fromRow(UserMeasurement row) {
    return model.UserMeasurement(
      id: row.uuid,
      heightCm: row.heightCm,
      weightKg: row.weightKg,
      timestamp: row.timestamp,
      notes: row.notes,
      bodyFatPercent: row.bodyFatPercent,
      leanMassKg: row.leanMassKg,
    );
  }

  /// Convert a domain UserMeasurement model to a Drift Companion
  static UserMeasurementsCompanion toCompanion(model.UserMeasurement measurement) {
    return UserMeasurementsCompanion(
      uuid: Value(measurement.id),
      heightCm: Value(measurement.heightCm),
      weightKg: Value(measurement.weightKg),
      timestamp: Value(measurement.timestamp),
      notes: Value(measurement.notes),
      bodyFatPercent: Value(measurement.bodyFatPercent),
      leanMassKg: Value(measurement.leanMassKg),
    );
  }
}

/// Converts between Drift Skin row and domain SkinModel
class SkinMapper {
  /// Convert a Drift Skin row to SkinModel
  static SkinModel fromRow(Skin row) {
    final skinJson = jsonDecode(row.skinJson) as Map<String, dynamic>;
    return SkinModel.fromJson(skinJson);
  }

  /// Convert a SkinModel to a Drift Companion
  static SkinsCompanion toCompanion(
    SkinModel skin, {
    bool isActive = false,
    DateTime? createdAt,
  }) {
    return SkinsCompanion(
      uuid: Value(skin.id),
      name: Value(skin.name),
      skinJson: Value(jsonEncode(skin.toJson())),
      isActive: Value(isActive),
      createdAt: Value(createdAt ?? DateTime.now()),
    );
  }

  /// Convert a SkinModel to a Drift Companion for update
  static SkinsCompanion toUpdateCompanion(SkinModel skin) {
    return SkinsCompanion(
      uuid: Value(skin.id),
      name: Value(skin.name),
      skinJson: Value(jsonEncode(skin.toJson())),
    );
  }
}
