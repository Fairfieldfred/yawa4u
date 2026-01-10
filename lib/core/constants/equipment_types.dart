import 'package:hive/hive.dart';

part 'equipment_types.g.dart';

/// Equipment type categories for exercises
@HiveType(typeId: 21)
enum EquipmentType {
  @HiveField(0)
  barbell,
  @HiveField(1)
  bodyweightLoadable,
  @HiveField(2)
  bodyweightOnly,
  @HiveField(3)
  cable,
  @HiveField(4)
  dumbbell,
  @HiveField(5)
  freemotion,
  @HiveField(6)
  machine,
  @HiveField(7)
  machineAssistance,
  @HiveField(8)
  smithMachine,
  @HiveField(9)
  bandAssistance,
}

extension EquipmentTypeExtension on EquipmentType {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case EquipmentType.barbell:
        return 'Barbell';
      case EquipmentType.bodyweightLoadable:
        return 'Bodyweight Loadable';
      case EquipmentType.bodyweightOnly:
        return 'Bodyweight Only';
      case EquipmentType.cable:
        return 'Cable';
      case EquipmentType.dumbbell:
        return 'Dumbbell';
      case EquipmentType.freemotion:
        return 'Freemotion';
      case EquipmentType.machine:
        return 'Machine';
      case EquipmentType.machineAssistance:
        return 'Machine Assistance';
      case EquipmentType.smithMachine:
        return 'Smith Machine';
      case EquipmentType.bandAssistance:
        return 'Band Assistance';
    }
  }

  /// Uppercase display name for UI (as shown in screenshots)
  String get displayNameUppercase => displayName.toUpperCase();

  /// Whether this equipment type requires bodyweight tracking
  bool get isBodyweightLoadable => this == EquipmentType.bodyweightLoadable;
}

/// Helper class for equipment type utilities
class EquipmentTypes {
  EquipmentTypes._();

  /// All equipment types in order
  static const List<EquipmentType> all = EquipmentType.values;

  /// Parse equipment type from string (case-insensitive)
  /// Handles variations from CSV data
  static EquipmentType? parse(String value) {
    final normalized = value.trim().toLowerCase();

    // Handle exact matches first
    for (final type in EquipmentType.values) {
      if (type.displayName.toLowerCase() == normalized) {
        return type;
      }
    }

    // Handle variations and common misspellings
    if (normalized.contains('bodyweight loadable')) {
      return EquipmentType.bodyweightLoadable;
    }
    if (normalized.contains('bodyweight only') || normalized == 'bodyweight') {
      return EquipmentType.bodyweightOnly;
    }
    if (normalized.contains('machine assistance')) {
      return EquipmentType.machineAssistance;
    }
    if (normalized.contains('smith machine') || normalized == 'smith') {
      return EquipmentType.smithMachine;
    }
    if (normalized.contains('band assistance') || normalized == 'band') {
      return EquipmentType.bandAssistance;
    }

    return null;
  }

  /// Get all equipment types sorted by display name
  static List<EquipmentType> get sorted {
    final types = List<EquipmentType>.from(all);
    types.sort((a, b) => a.displayName.compareTo(b.displayName));
    return types;
  }

  /// Get equipment types that require bodyweight tracking
  static List<EquipmentType> get bodyweightLoadable =>
      all.where((t) => t.isBodyweightLoadable).toList();
}
