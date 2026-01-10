import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'skin_model.g.dart';

/// Represents a complete app skin/theme configuration.
///
/// This model can be serialized to/from JSON for storage and sharing.
@JsonSerializable(explicitToJson: true)
class SkinModel {
  final String id;
  final String name;
  final String description;
  final String author;
  final String version;
  final bool isPremium;
  final bool isBuiltIn;
  final SkinColors colors;
  final SkinModeColors lightMode;
  final SkinModeColors darkMode;
  final SkinMuscleGroupColors muscleGroups;
  final SkinWorkoutStatusColors workoutStatus;
  final SkinComponents components;
  final SkinBackgrounds? backgrounds;

  const SkinModel({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.version,
    this.isPremium = false,
    this.isBuiltIn = false,
    required this.colors,
    required this.lightMode,
    required this.darkMode,
    required this.muscleGroups,
    required this.workoutStatus,
    required this.components,
    this.backgrounds,
  });

  factory SkinModel.fromJson(Map<String, dynamic> json) =>
      _$SkinModelFromJson(json);

  Map<String, dynamic> toJson() => _$SkinModelToJson(this);

  SkinModel copyWith({
    String? id,
    String? name,
    String? description,
    String? author,
    String? version,
    bool? isPremium,
    bool? isBuiltIn,
    SkinColors? colors,
    SkinModeColors? lightMode,
    SkinModeColors? darkMode,
    SkinMuscleGroupColors? muscleGroups,
    SkinWorkoutStatusColors? workoutStatus,
    SkinComponents? components,
    SkinBackgrounds? backgrounds,
  }) {
    return SkinModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      author: author ?? this.author,
      version: version ?? this.version,
      isPremium: isPremium ?? this.isPremium,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      colors: colors ?? this.colors,
      lightMode: lightMode ?? this.lightMode,
      darkMode: darkMode ?? this.darkMode,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      workoutStatus: workoutStatus ?? this.workoutStatus,
      components: components ?? this.components,
      backgrounds: backgrounds ?? this.backgrounds,
    );
  }
}

/// Core accent colors used throughout the app.
@JsonSerializable()
class SkinColors {
  final String primary;
  final String primaryDark;
  final String primaryLight;
  final String secondary;
  final String success;
  final String warning;
  final String error;
  final String info;

  const SkinColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  factory SkinColors.fromJson(Map<String, dynamic> json) =>
      _$SkinColorsFromJson(json);

  Map<String, dynamic> toJson() => _$SkinColorsToJson(this);

  /// Parse a hex color string to a Flutter Color.
  static Color parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add full opacity
    }
    return Color(int.parse(hex, radix: 16));
  }

  Color get primaryColor => parseHex(primary);
  Color get primaryDarkColor => parseHex(primaryDark);
  Color get primaryLightColor => parseHex(primaryLight);
  Color get secondaryColor => parseHex(secondary);
  Color get successColor => parseHex(success);
  Color get warningColor => parseHex(warning);
  Color get errorColor => parseHex(error);
  Color get infoColor => parseHex(info);
}

/// Colors specific to light or dark mode.
@JsonSerializable()
class SkinModeColors {
  final String scaffoldBackground;
  final String cardBackground;
  final String inputBackground;
  final String divider;
  final String textPrimary;
  final String textSecondary;
  final String textDisabled;

  const SkinModeColors({
    required this.scaffoldBackground,
    required this.cardBackground,
    required this.inputBackground,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
  });

  factory SkinModeColors.fromJson(Map<String, dynamic> json) =>
      _$SkinModeColorsFromJson(json);

  Map<String, dynamic> toJson() => _$SkinModeColorsToJson(this);

  Color get scaffoldBackgroundColor => SkinColors.parseHex(scaffoldBackground);
  Color get cardBackgroundColor => SkinColors.parseHex(cardBackground);
  Color get inputBackgroundColor => SkinColors.parseHex(inputBackground);
  Color get dividerColor => SkinColors.parseHex(divider);
  Color get textPrimaryColor => SkinColors.parseHex(textPrimary);
  Color get textSecondaryColor => SkinColors.parseHex(textSecondary);
  Color get textDisabledColor => SkinColors.parseHex(textDisabled);
}

/// Colors for muscle group categorization.
@JsonSerializable()
class SkinMuscleGroupColors {
  final String upperPush;
  final String upperPull;
  final String legs;
  final String coreAndAccessories;

  const SkinMuscleGroupColors({
    required this.upperPush,
    required this.upperPull,
    required this.legs,
    required this.coreAndAccessories,
  });

  factory SkinMuscleGroupColors.fromJson(Map<String, dynamic> json) =>
      _$SkinMuscleGroupColorsFromJson(json);

  Map<String, dynamic> toJson() => _$SkinMuscleGroupColorsToJson(this);

  Color get upperPushColor => SkinColors.parseHex(upperPush);
  Color get upperPullColor => SkinColors.parseHex(upperPull);
  Color get legsColor => SkinColors.parseHex(legs);
  Color get coreAndAccessoriesColor => SkinColors.parseHex(coreAndAccessories);
}

/// Colors for workout status indicators.
@JsonSerializable()
class SkinWorkoutStatusColors {
  final String current;
  final String completed;
  final String skipped;
  final String deload;

  const SkinWorkoutStatusColors({
    required this.current,
    required this.completed,
    required this.skipped,
    required this.deload,
  });

  factory SkinWorkoutStatusColors.fromJson(Map<String, dynamic> json) =>
      _$SkinWorkoutStatusColorsFromJson(json);

  Map<String, dynamic> toJson() => _$SkinWorkoutStatusColorsToJson(this);

  Color get currentColor => SkinColors.parseHex(current);
  Color get completedColor => SkinColors.parseHex(completed);
  Color get skippedColor => SkinColors.parseHex(skipped);
  Color get deloadColor => SkinColors.parseHex(deload);
}

/// Component styling properties (dimensions, radii, etc.).
@JsonSerializable()
class SkinComponents {
  final double cardBorderRadius;
  final double buttonBorderRadius;
  final double inputBorderRadius;
  final double cardElevation;
  final double buttonElevation;

  const SkinComponents({
    this.cardBorderRadius = 12,
    this.buttonBorderRadius = 8,
    this.inputBorderRadius = 8,
    this.cardElevation = 2,
    this.buttonElevation = 2,
  });

  factory SkinComponents.fromJson(Map<String, dynamic> json) =>
      _$SkinComponentsFromJson(json);

  Map<String, dynamic> toJson() => _$SkinComponentsToJson(this);
}

/// Background image configuration for screens.
@JsonSerializable()
class SkinBackgrounds {
  /// Background image for the Workout screen (main tab).
  final String? workout;

  /// Background image for the Training Cycles list screen.
  final String? cycles;

  /// Background image for the Exercises screen.
  final String? exercises;

  /// Background image for the More screen.
  final String? more;

  /// Default background for all other/sub screens (including Calendar).
  final String? defaultBackground;

  /// App icon/accent image for AppBar or branding.
  final String? appIcon;

  /// Overlay opacity for light mode (0.0 to 1.0).
  /// Higher values = more overlay = better text readability.
  final double lightOverlayOpacity;

  /// Overlay opacity for dark mode (0.0 to 1.0).
  final double darkOverlayOpacity;

  const SkinBackgrounds({
    this.workout,
    this.cycles,
    this.exercises,
    this.more,
    this.defaultBackground,
    this.appIcon,
    this.lightOverlayOpacity = 0.7,
    this.darkOverlayOpacity = 0.75,
  });

  factory SkinBackgrounds.fromJson(Map<String, dynamic> json) =>
      _$SkinBackgroundsFromJson(json);

  Map<String, dynamic> toJson() => _$SkinBackgroundsToJson(this);
}
