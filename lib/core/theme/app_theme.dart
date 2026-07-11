import 'package:flutter/material.dart';

/// Custom theme extension for muscle group colors
@immutable
class MuscleGroupColors extends ThemeExtension<MuscleGroupColors> {
  final Color? upperPush;
  final Color? upperPull;
  final Color? legs;
  final Color? coreAndAccessories;

  const MuscleGroupColors({
    required this.upperPush,
    required this.upperPull,
    required this.legs,
    required this.coreAndAccessories,
  });

  @override
  MuscleGroupColors copyWith({
    Color? upperPush,
    Color? upperPull,
    Color? legs,
    Color? coreAndAccessories,
  }) {
    return MuscleGroupColors(
      upperPush: upperPush ?? this.upperPush,
      upperPull: upperPull ?? this.upperPull,
      legs: legs ?? this.legs,
      coreAndAccessories: coreAndAccessories ?? this.coreAndAccessories,
    );
  }

  @override
  MuscleGroupColors lerp(ThemeExtension<MuscleGroupColors>? other, double t) {
    if (other is! MuscleGroupColors) {
      return this;
    }
    return MuscleGroupColors(
      upperPush: Color.lerp(upperPush, other.upperPush, t),
      upperPull: Color.lerp(upperPull, other.upperPull, t),
      legs: Color.lerp(legs, other.legs, t),
      coreAndAccessories: Color.lerp(
        coreAndAccessories,
        other.coreAndAccessories,
        t,
      ),
    );
  }
}
