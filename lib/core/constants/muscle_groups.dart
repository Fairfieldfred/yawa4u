import 'package:flutter/material.dart';

/// Muscle group categories for exercises
enum MuscleGroup {
  chest,
  triceps,
  shoulders,
  back,
  biceps,
  quads,
  hamstrings,
  glutes,
  calves,
  traps,
  forearms,
  abs,
}

extension MuscleGroupExtension on MuscleGroup {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.quads:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.traps:
        return 'Traps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.abs:
        return 'Abs';
    }
  }

  /// Color for muscle group badges and indicators
  /// Based on UI screenshots:
  /// - Pink/Magenta: Chest, Triceps, Shoulders
  /// - Cyan/Blue: Back, Biceps
  /// - Teal/Green: Quads, Hamstrings, Glutes, Calves
  /// - Purple: Traps, Forearms, Abs
  Color get color {
    switch (this) {
      case MuscleGroup.chest:
      case MuscleGroup.triceps:
      case MuscleGroup.shoulders:
        return const Color(0xFFE91E63); // Pink/Magenta
      case MuscleGroup.back:
      case MuscleGroup.biceps:
        return const Color(0xFF00BCD4); // Cyan/Blue
      case MuscleGroup.quads:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
        return const Color(0xFF009688); // Teal/Green
      case MuscleGroup.traps:
      case MuscleGroup.forearms:
      case MuscleGroup.abs:
        return const Color(0xFF9C27B0); // Purple
    }
  }
}

/// Helper class for muscle group utilities
class MuscleGroups {
  MuscleGroups._();

  /// All muscle groups in order
  static const List<MuscleGroup> all = MuscleGroup.values;

  /// Parse muscle group from string (case-insensitive)
  static MuscleGroup? parse(String value) {
    final normalized = value.trim().toLowerCase();
    for (final group in MuscleGroup.values) {
      if (group.displayName.toLowerCase() == normalized) {
        return group;
      }
    }
    return null;
  }

  /// Get all muscle groups sorted by display name
  static List<MuscleGroup> get sorted {
    final groups = List<MuscleGroup>.from(all);
    groups.sort((a, b) => a.displayName.compareTo(b.displayName));
    return groups;
  }
}
