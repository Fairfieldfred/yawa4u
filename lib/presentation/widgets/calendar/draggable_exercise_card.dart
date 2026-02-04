import 'package:flutter/material.dart';

import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/exercise.dart';

/// Data transferred during drag operations for exercises
class ExerciseDragData {
  final Exercise exercise;
  final String sourceWorkoutId;
  final int sourcePeriod;
  final int sourceDay;
  final int sourceIndex;

  const ExerciseDragData({
    required this.exercise,
    required this.sourceWorkoutId,
    required this.sourcePeriod,
    required this.sourceDay,
    required this.sourceIndex,
  });
}

/// A draggable card representing an exercise with its sets
class DraggableExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String workoutId;
  final int periodNumber;
  final int dayNumber;
  final int index;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;

  const DraggableExerciseCard({
    super.key,
    required this.exercise,
    required this.workoutId,
    required this.periodNumber,
    required this.dayNumber,
    required this.index,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final dragData = ExerciseDragData(
      exercise: exercise,
      sourceWorkoutId: workoutId,
      sourcePeriod: periodNumber,
      sourceDay: dayNumber,
      sourceIndex: index,
    );

    return Draggable<ExerciseDragData>(
      data: dragData,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: _buildCard(context, isDragging: true),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildCard(context)),
      child: GestureDetector(onTap: onTap, child: _buildCard(context)),
    );
  }

  Widget _buildCard(BuildContext context, {bool isDragging = false}) {
    final muscleGroupColor = _getMuscleGroupColor(exercise.muscleGroup);
    final completedSets = exercise.sets.where((s) => s.isLogged).length;
    final totalSets = exercise.sets.length;
    final isComplete = completedSets == totalSets && totalSets > 0;

    return Container(
      width: compact ? 180 : 220,
      padding: EdgeInsets.all(compact ? 6 : 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : muscleGroupColor.withAlpha(150),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Muscle group indicator + Exercise name
          Row(
            children: [
              Container(
                width: 4,
                height: compact ? 28 : 36,
                decoration: BoxDecoration(
                  color: muscleGroupColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: compact ? 10 : 12,
                      ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      exercise.muscleGroup.displayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: muscleGroupColor,
                        fontSize: compact ? 8 : 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Sets progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: totalSets > 0 ? completedSets / totalSets : 0,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete ? Colors.green : muscleGroupColor,
                    ),
                    minHeight: compact ? 3 : 4,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$completedSets/$totalSets',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  fontSize: compact ? 9 : 10,
                ),
              ),
            ],
          ),
          // Expanded sets view (non-compact only)
          if (!compact && exercise.sets.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 2,
              children: exercise.sets.take(6).map((set) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: set.isLogged
                        ? Colors.green.withAlpha(50)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: set.isLogged
                          ? Colors.green.withAlpha(100)
                          : Theme.of(context).colorScheme.outline.withAlpha(50),
                    ),
                  ),
                  child: Text(
                    '${set.weight ?? '-'}×${set.reps}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: set.isLogged
                          ? Colors.green.shade700
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (exercise.sets.length > 6)
              Text(
                '+${exercise.sets.length - 6} more',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 8,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Color _getMuscleGroupColor(MuscleGroup muscleGroup) {
    switch (muscleGroup) {
      case MuscleGroup.chest:
      case MuscleGroup.triceps:
      case MuscleGroup.shoulders:
        return Colors.pink;
      case MuscleGroup.back:
      case MuscleGroup.biceps:
        return Colors.cyan;
      case MuscleGroup.quads:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
        return Colors.teal;
      case MuscleGroup.traps:
      case MuscleGroup.forearms:
      case MuscleGroup.abs:
        return Colors.purple;
    }
  }
}
