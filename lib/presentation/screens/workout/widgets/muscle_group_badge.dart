import 'package:flutter/material.dart';

import '../../../../core/constants/muscle_groups.dart';

/// A badge widget displaying a muscle group with colored background
///
/// Features:
/// - Colored background based on muscle group
/// - White vertical bars icon
/// - Uppercase muscle group name
/// - Rounded corners
class MuscleGroupBadge extends StatelessWidget {
  final MuscleGroup muscleGroup;

  const MuscleGroupBadge({
    super.key,
    required this.muscleGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: muscleGroup.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vertical bars icon
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          // Muscle group name
          Text(
            muscleGroup.displayName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
