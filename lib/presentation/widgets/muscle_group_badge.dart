import 'package:flutter/material.dart';

import '../../core/constants/muscle_groups.dart';

/// A reusable badge widget that displays a muscle group indicator.
///
/// This widget is designed to be used as an overlay badge on exercise cards,
/// positioned at the top-left corner using a [Positioned] widget in a [Stack].
///
/// Example usage:
/// ```dart
/// Stack(
///   clipBehavior: Clip.none,
///   children: [
///     // Card content...
///     if (showMuscleGroupBadge)
///       const MuscleGroupBadge(muscleGroup: MuscleGroup.chest),
///   ],
/// )
/// ```
class MuscleGroupBadge extends StatelessWidget {
  /// The primary muscle group to display.
  final MuscleGroup muscleGroup;

  /// The optional secondary muscle group to display.
  final MuscleGroup? secondaryMuscleGroup;

  /// Top position offset. Defaults to -20.
  final double top;

  /// Left position offset. Defaults to 16.
  final double left;

  /// Horizontal padding inside the badge. Defaults to 16.
  final double horizontalPadding;

  /// Vertical padding inside the badge. Defaults to 8.
  final double verticalPadding;

  /// Font size for the muscle group name. Defaults to 13.
  final double fontSize;

  /// Font weight for the muscle group name. Defaults to FontWeight.w600.
  final FontWeight fontWeight;

  /// Letter spacing for the muscle group name. Defaults to 0.5.
  final double letterSpacing;

  /// Creates a muscle group badge widget.
  const MuscleGroupBadge({
    super.key,
    required this.muscleGroup,
    this.secondaryMuscleGroup,
    this.top = -20,
    this.left = 16,
    this.horizontalPadding = 16,
    this.verticalPadding = 8,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w600,
    this.letterSpacing = 0.5,
  });

  /// Creates a compact variant of the badge with smaller padding and font.
  const MuscleGroupBadge.compact({
    super.key,
    required this.muscleGroup,
    this.secondaryMuscleGroup,
    this.top = -20,
    this.left = 16,
    this.horizontalPadding = 10,
    this.verticalPadding = 4,
    this.fontSize = 12,
    this.fontWeight = FontWeight.w500,
    this.letterSpacing = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isLightMode = Theme.of(context).brightness == Brightness.light;

    // Build display text with optional secondary muscle group
    final displayText = secondaryMuscleGroup != null
        ? '${muscleGroup.displayName} / ${secondaryMuscleGroup!.displayName}'
            .toUpperCase()
        : muscleGroup.displayName.toUpperCase();

    return Positioned(
      top: top,
      left: left,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: muscleGroup.color.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              displayText,
              style: TextStyle(
                color: isLightMode ? Colors.grey.shade700 : Colors.white,
                fontSize: fontSize,
                fontWeight: fontWeight,
                letterSpacing: letterSpacing,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
