// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkinModel _$SkinModelFromJson(Map<String, dynamic> json) => SkinModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      version: json['version'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      colors: SkinColors.fromJson(json['colors'] as Map<String, dynamic>),
      lightMode:
          SkinModeColors.fromJson(json['lightMode'] as Map<String, dynamic>),
      darkMode:
          SkinModeColors.fromJson(json['darkMode'] as Map<String, dynamic>),
      muscleGroups: SkinMuscleGroupColors.fromJson(
          json['muscleGroups'] as Map<String, dynamic>),
      workoutStatus: SkinWorkoutStatusColors.fromJson(
          json['workoutStatus'] as Map<String, dynamic>),
      components:
          SkinComponents.fromJson(json['components'] as Map<String, dynamic>),
      backgrounds: json['backgrounds'] == null
          ? null
          : SkinBackgrounds.fromJson(
              json['backgrounds'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SkinModelToJson(SkinModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'author': instance.author,
      'version': instance.version,
      'isPremium': instance.isPremium,
      'isBuiltIn': instance.isBuiltIn,
      'colors': instance.colors.toJson(),
      'lightMode': instance.lightMode.toJson(),
      'darkMode': instance.darkMode.toJson(),
      'muscleGroups': instance.muscleGroups.toJson(),
      'workoutStatus': instance.workoutStatus.toJson(),
      'components': instance.components.toJson(),
      'backgrounds': instance.backgrounds?.toJson(),
    };

SkinColors _$SkinColorsFromJson(Map<String, dynamic> json) => SkinColors(
      primary: json['primary'] as String,
      primaryDark: json['primaryDark'] as String,
      primaryLight: json['primaryLight'] as String,
      secondary: json['secondary'] as String,
      success: json['success'] as String,
      warning: json['warning'] as String,
      error: json['error'] as String,
      info: json['info'] as String,
    );

Map<String, dynamic> _$SkinColorsToJson(SkinColors instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'primaryDark': instance.primaryDark,
      'primaryLight': instance.primaryLight,
      'secondary': instance.secondary,
      'success': instance.success,
      'warning': instance.warning,
      'error': instance.error,
      'info': instance.info,
    };

SkinModeColors _$SkinModeColorsFromJson(Map<String, dynamic> json) =>
    SkinModeColors(
      scaffoldBackground: json['scaffoldBackground'] as String,
      cardBackground: json['cardBackground'] as String,
      inputBackground: json['inputBackground'] as String,
      divider: json['divider'] as String,
      textPrimary: json['textPrimary'] as String,
      textSecondary: json['textSecondary'] as String,
      textDisabled: json['textDisabled'] as String,
    );

Map<String, dynamic> _$SkinModeColorsToJson(SkinModeColors instance) =>
    <String, dynamic>{
      'scaffoldBackground': instance.scaffoldBackground,
      'cardBackground': instance.cardBackground,
      'inputBackground': instance.inputBackground,
      'divider': instance.divider,
      'textPrimary': instance.textPrimary,
      'textSecondary': instance.textSecondary,
      'textDisabled': instance.textDisabled,
    };

SkinMuscleGroupColors _$SkinMuscleGroupColorsFromJson(
        Map<String, dynamic> json) =>
    SkinMuscleGroupColors(
      upperPush: json['upperPush'] as String,
      upperPull: json['upperPull'] as String,
      legs: json['legs'] as String,
      coreAndAccessories: json['coreAndAccessories'] as String,
    );

Map<String, dynamic> _$SkinMuscleGroupColorsToJson(
        SkinMuscleGroupColors instance) =>
    <String, dynamic>{
      'upperPush': instance.upperPush,
      'upperPull': instance.upperPull,
      'legs': instance.legs,
      'coreAndAccessories': instance.coreAndAccessories,
    };

SkinWorkoutStatusColors _$SkinWorkoutStatusColorsFromJson(
        Map<String, dynamic> json) =>
    SkinWorkoutStatusColors(
      current: json['current'] as String,
      completed: json['completed'] as String,
      skipped: json['skipped'] as String,
      deload: json['deload'] as String,
    );

Map<String, dynamic> _$SkinWorkoutStatusColorsToJson(
        SkinWorkoutStatusColors instance) =>
    <String, dynamic>{
      'current': instance.current,
      'completed': instance.completed,
      'skipped': instance.skipped,
      'deload': instance.deload,
    };

SkinComponents _$SkinComponentsFromJson(Map<String, dynamic> json) =>
    SkinComponents(
      cardBorderRadius: (json['cardBorderRadius'] as num?)?.toDouble() ?? 12,
      buttonBorderRadius: (json['buttonBorderRadius'] as num?)?.toDouble() ?? 8,
      inputBorderRadius: (json['inputBorderRadius'] as num?)?.toDouble() ?? 8,
      cardElevation: (json['cardElevation'] as num?)?.toDouble() ?? 2,
      buttonElevation: (json['buttonElevation'] as num?)?.toDouble() ?? 2,
    );

Map<String, dynamic> _$SkinComponentsToJson(SkinComponents instance) =>
    <String, dynamic>{
      'cardBorderRadius': instance.cardBorderRadius,
      'buttonBorderRadius': instance.buttonBorderRadius,
      'inputBorderRadius': instance.inputBorderRadius,
      'cardElevation': instance.cardElevation,
      'buttonElevation': instance.buttonElevation,
    };

SkinBackgrounds _$SkinBackgroundsFromJson(Map<String, dynamic> json) =>
    SkinBackgrounds(
      workout: json['workout'] as String?,
      cycles: json['cycles'] as String?,
      exercises: json['exercises'] as String?,
      more: json['more'] as String?,
      defaultBackground: json['defaultBackground'] as String?,
      appIcon: json['appIcon'] as String?,
      lightOverlayOpacity:
          (json['lightOverlayOpacity'] as num?)?.toDouble() ?? 0.7,
      darkOverlayOpacity:
          (json['darkOverlayOpacity'] as num?)?.toDouble() ?? 0.75,
    );

Map<String, dynamic> _$SkinBackgroundsToJson(SkinBackgrounds instance) =>
    <String, dynamic>{
      'workout': instance.workout,
      'cycles': instance.cycles,
      'exercises': instance.exercises,
      'more': instance.more,
      'defaultBackground': instance.defaultBackground,
      'appIcon': instance.appIcon,
      'lightOverlayOpacity': instance.lightOverlayOpacity,
      'darkOverlayOpacity': instance.darkOverlayOpacity,
    };
