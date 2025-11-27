import 'package:flutter/material.dart';

import '../../../../core/constants/equipment_types.dart';
import '../../../../data/models/exercise.dart';
import '../../../../data/models/exercise_set.dart';
import 'muscle_group_badge.dart';
import 'set_row.dart';

/// A card widget displaying a single exercise with all its sets
///
/// Features:
/// - Muscle group badge (colored, top left)
/// - Exercise name (large, bold)
/// - Equipment type (small, gray)
/// - Info icon button (opens exercise detail)
/// - Overflow menu button (3 dots)
/// - Set row headers (WEIGHT, REPS, LOG)
/// - List of set rows with week-based RIR hints
/// - Card styling with elevation/shadow
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final double? bodyweight;
  final int? targetRir;
  final ValueChanged<Exercise>? onExerciseChanged;
  final VoidCallback? onInfoPressed;
  final VoidCallback? onMenuPressed;
  final void Function(ExerciseSet, int)? onSetMenuPressed;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.bodyweight,
    this.targetRir,
    this.onExerciseChanged,
    this.onInfoPressed,
    this.onMenuPressed,
    this.onSetMenuPressed,
  });

  bool get _isBodyweightLoadable {
    return exercise.equipmentType == EquipmentType.bodyweightLoadable;
  }

  void _handleSetChanged(int index, ExerciseSet updatedSet) {
    if (onExerciseChanged != null) {
      final updatedSets = List<ExerciseSet>.from(exercise.sets);
      updatedSets[index] = updatedSet;
      onExerciseChanged!(exercise.copyWith(sets: updatedSets));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Muscle group badge
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: MuscleGroupBadge(muscleGroup: exercise.muscleGroup),
        ),

        // Exercise card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                exercise.equipmentType.displayName
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              if (_isBodyweightLoadable &&
                                  bodyweight != null) ...[
                                Text(
                                  ' @ ${bodyweight!.toInt()} LBS BODYWEIGHT',
                                  style: const TextStyle(
                                    color: Color(0xFF8E8E93),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Info button
                    IconButton(
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF8E8E93),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'i',
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      onPressed: onInfoPressed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Overflow menu button
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF8E8E93),
                        size: 24,
                      ),
                      onPressed: onMenuPressed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),

                const SizedBox(height: 16),

                // Set headers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 40), // Menu icon space
                      const SizedBox(width: 32), // Set number space
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isBodyweightLoadable ? '+WEIGHT' : 'WEIGHT',
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'REPS',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                // Show RIR explanation dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('RIR (Reps In Reserve)'),
                                    content: const Text(
                                      'RIR indicates how many more reps you could have done.\n\n'
                                      'Examples:\n'
                                      '• "2 RIR" = could have done 2 more reps\n'
                                      '• "0 RIR" = reached failure\n'
                                      '• "8" = did exactly 8 reps',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('GOT IT'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF8E8E93),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'i',
                                    style: TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const SizedBox(
                        width: 28,
                        child: Text(
                          'LOG',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Set rows
                ...List.generate(
                  exercise.sets.length,
                  (index) => SetRow(
                    set: exercise.sets[index],
                    setNumber: index + 1,
                    isBodyweightLoadable: _isBodyweightLoadable,
                    bodyweight: bodyweight,
                    targetRir: targetRir,
                    onSetChanged: (updatedSet) =>
                        _handleSetChanged(index, updatedSet),
                    onMenuPressed: () =>
                        onSetMenuPressed?.call(exercise.sets[index], index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
