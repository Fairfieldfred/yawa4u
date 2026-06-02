import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

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
  fullBody,
  adductors,
  core,
  grip,
  obliques,
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
      case MuscleGroup.fullBody:
        return 'Full Body';
      case MuscleGroup.adductors:
        return 'Adductors';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.grip:
        return 'Grip';
      case MuscleGroup.obliques:
        return 'Obliques';
    }
  }

  /// Localized display name for UI (uses ARB translations)
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case MuscleGroup.chest:
        return l10n.muscleGroupChest;
      case MuscleGroup.triceps:
        return l10n.muscleGroupTriceps;
      case MuscleGroup.shoulders:
        return l10n.muscleGroupShoulders;
      case MuscleGroup.back:
        return l10n.muscleGroupBack;
      case MuscleGroup.biceps:
        return l10n.muscleGroupBiceps;
      case MuscleGroup.quads:
        return l10n.muscleGroupQuads;
      case MuscleGroup.hamstrings:
        return l10n.muscleGroupHamstrings;
      case MuscleGroup.glutes:
        return l10n.muscleGroupGlutes;
      case MuscleGroup.calves:
        return l10n.muscleGroupCalves;
      case MuscleGroup.traps:
        return l10n.muscleGroupTraps;
      case MuscleGroup.forearms:
        return l10n.muscleGroupForearms;
      case MuscleGroup.abs:
        return l10n.muscleGroupAbs;
      case MuscleGroup.fullBody:
        return l10n.muscleGroupFullBody;
      case MuscleGroup.adductors:
        return l10n.muscleGroupAdductors;
      case MuscleGroup.core:
        return l10n.muscleGroupCore;
      case MuscleGroup.grip:
        return l10n.muscleGroupGrip;
      case MuscleGroup.obliques:
        return l10n.muscleGroupObliques;
    }
  }

  /// Color for muscle group badges and indicators
  /// Based on UI screenshots:
  /// - Pink/Magenta: Chest, Triceps, Shoulders
  /// - Cyan/Blue: Back, Biceps
  /// - Teal/Green: Quads, Hamstrings, Glutes, Calves, Adductors
  /// - Purple: Traps, Forearms, Abs, Core, Obliques, Grip
  /// - Orange: Full Body
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
      case MuscleGroup.adductors:
        return const Color(0xFF009688); // Teal/Green
      case MuscleGroup.traps:
      case MuscleGroup.forearms:
      case MuscleGroup.abs:
      case MuscleGroup.core:
      case MuscleGroup.obliques:
      case MuscleGroup.grip:
        return const Color(0xFF9C27B0); // Purple
      case MuscleGroup.fullBody:
        return const Color(0xFFFF9800); // Orange
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
