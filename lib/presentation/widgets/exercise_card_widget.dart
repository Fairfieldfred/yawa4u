import 'package:flutter/material.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import 'dialogs/exercise_info_dialog.dart';

/// Shared widget for displaying an exercise card with sets.
/// Used in both workout_home_screen and exercises_home_screen.
class ExerciseCardWidget extends StatelessWidget {
  final Exercise exercise;
  final bool showMuscleGroupBadge;
  final int? targetRir;
  final Function(String exerciseId) onAddNote;
  final Function(String exerciseId)? onMoveDown;
  final bool showMoveDown;
  final Function(String exerciseId) onReplace;
  final Function(String exerciseId) onJointPain;
  final Function(String exerciseId) onAddSet;
  final Function(String exerciseId) onSkipSets;
  final Function(String exerciseId) onDelete;
  final Function(int setIndex) onAddSetBelow;
  final Function(int setIndex) onToggleSetSkip;
  final Function(int setIndex) onDeleteSet;
  final Function(int setIndex, SetType setType) onUpdateSetType;
  final Function(int setIndex, String value) onUpdateSetWeight;
  final Function(int setIndex, String value) onUpdateSetReps;
  final Function(int setIndex) onToggleSetLog;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
    required this.showMuscleGroupBadge,
    this.targetRir,
    required this.onAddNote,
    this.onMoveDown,
    this.showMoveDown = true,
    required this.onReplace,
    required this.onJointPain,
    required this.onAddSet,
    required this.onSkipSets,
    required this.onDelete,
    required this.onAddSetBelow,
    required this.onToggleSetSkip,
    required this.onDeleteSet,
    required this.onUpdateSetType,
    required this.onUpdateSetWeight,
    required this.onUpdateSetReps,
    required this.onToggleSetLog,
  });

  @override
  Widget build(BuildContext context) {
    final muscleGroup = exercise.muscleGroup;
    final equipmentType = exercise.equipmentType;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Exercise card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            equipmentType.displayName.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
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
                        child: Center(
                          child: Text(
                            'i',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                      onPressed: () =>
                          showExerciseInfoDialog(context, exercise),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                    const SizedBox(width: 0),
                    // Overflow menu button
                    _buildExerciseOverflowMenu(context),
                  ],
                ),
                const SizedBox(height: 16),

                // Column headers
                if (exercise.sets.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 24,
                        ), // Spacer for overflow menu alignment
                        Expanded(
                          child: Text(
                            'WEIGHT',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'REPS',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'LOG',
                            style: TextStyle(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Sets list
                ...List.generate(exercise.sets.length, (index) {
                  final set = exercise.sets[index];
                  return _buildSetRow(context, set, index);
                }),
              ],
            ),
          ),
        ),

        // Muscle group badge - overlays the card
        if (showMuscleGroupBadge)
          Positioned(
            top: -20,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: muscleGroup.color.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    muscleGroup.displayName.toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade700
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseOverflowMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).textTheme.bodySmall?.color,
        size: 24,
      ),
      offset: const Offset(-180, 40),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 250),
      color: const Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      onSelected: (value) {
        switch (value) {
          case 'note':
            onAddNote(exercise.id);
            break;
          case 'move_down':
            onMoveDown?.call(exercise.id);
            break;
          case 'replace':
            onReplace(exercise.id);
            break;
          case 'joint_pain':
            onJointPain(exercise.id);
            break;
          case 'add_set':
            onAddSet(exercise.id);
            break;
          case 'skip_sets':
            onSkipSets(exercise.id);
            break;
          case 'delete':
            onDelete(exercise.id);
            break;
        }
      },
      itemBuilder: (context) => [
        // Header
        const PopupMenuItem<String>(
          enabled: false,
          height: 32,
          child: Text(
            'EXERCISE',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // New note
        const PopupMenuItem<String>(
          value: 'note',
          height: 48,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('New note', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        // Move down (conditionally shown)
        if (showMoveDown)
          const PopupMenuItem<String>(
            value: 'move_down',
            height: 48,
            child: Row(
              children: [
                Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Move down', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        // Replace
        const PopupMenuItem<String>(
          value: 'replace',
          height: 48,
          child: Row(
            children: [
              Icon(Icons.swap_horiz, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Replace', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        // Joint pain
        PopupMenuItem<String>(
          value: 'joint_pain',
          enabled: exercise.sets.any((s) => s.isLogged),
          height: 48,
          child: Row(
            children: [
              Icon(
                Icons.healing,
                color: exercise.sets.any((s) => s.isLogged)
                    ? Colors.white
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Joint pain',
                style: TextStyle(
                  color: exercise.sets.any((s) => s.isLogged)
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        // Add set
        const PopupMenuItem<String>(
          value: 'add_set',
          height: 48,
          child: Row(
            children: [
              Icon(Icons.add, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Add set', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        // Skip sets
        const PopupMenuItem<String>(
          value: 'skip_sets',
          height: 48,
          child: Row(
            children: [
              Icon(Icons.fast_forward, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Skip sets', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        // Delete exercise
        PopupMenuItem<String>(
          value: 'delete',
          enabled: !exercise.sets.any((s) => s.isLogged),
          height: 48,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: exercise.sets.any((s) => s.isLogged)
                    ? Colors.grey
                    : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete exercise',
                style: TextStyle(
                  color: exercise.sets.any((s) => s.isLogged)
                      ? Colors.grey
                      : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetRow(BuildContext context, ExerciseSet set, int index) {
    final isLoggable = set.weight != null && set.reps.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Set menu (3 dots)
          SizedBox(
            width: 24,
            child: _buildSetOverflowMenu(context, set, index),
          ),

          // Weight Input
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Center(
                child: TextFormField(
                  key: ValueKey('weight_${set.id}'),
                  initialValue: set.weight?.toString() ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'lbs',
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(bottom: 12),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (value) {
                    onUpdateSetWeight(index, value);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Reps Input
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Center(
                    child: TextFormField(
                      key: ValueKey('reps_${set.id}'),
                      initialValue: set.reps,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: targetRir != null ? '$targetRir RIR' : 'RIR',
                        hintStyle: Theme.of(
                          context,
                        ).inputDecorationTheme.hintStyle,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(bottom: 12),
                      ),
                      onChanged: (value) {
                        onUpdateSetReps(index, value);
                      },
                    ),
                  ),
                ),
                // Badge for non-regular set types
                if (_getSetTypeBadge(set.setType) != null)
                  Positioned(
                    top: 2,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        _getSetTypeBadge(set.setType)!,
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Log Checkbox
          SizedBox(
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                color: set.isLogged
                    ? Colors.green.withValues(alpha: 0.2)
                    : (isLoggable
                          ? Theme.of(context).inputDecorationTheme.fillColor
                          : Colors.grey.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: set.isLogged
                      ? Colors.green
                      : (isLoggable
                            ? Colors.green
                            : Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.3)),
                  width: set.isLogged || isLoggable ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: isLoggable ? () => onToggleSetLog(index) : null,
                child: set.isLogged
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetOverflowMenu(
    BuildContext context,
    ExerciseSet set,
    int index,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
        size: 20,
      ),
      offset: const Offset(0, 40),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 250),
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      onSelected: (value) {
        switch (value) {
          case 'add_below':
            onAddSetBelow(index);
            break;
          case 'skip':
            onToggleSetSkip(index);
            break;
          case 'delete':
            onDeleteSet(index);
            break;
          case 'regular':
            onUpdateSetType(index, SetType.regular);
            break;
          case 'myorep':
            onUpdateSetType(index, SetType.myorep);
            break;
          case 'myorep_match':
            onUpdateSetType(index, SetType.myorepMatch);
            break;
          case 'max_reps':
            onUpdateSetType(index, SetType.maxReps);
            break;
          case 'end_with_partials':
            onUpdateSetType(index, SetType.endWithPartials);
            break;
        }
      },
      itemBuilder: (context) => [
        // SET Header
        const PopupMenuItem<String>(
          enabled: false,
          height: 32,
          child: Text(
            'SET',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Add set below
        PopupMenuItem<String>(
          value: 'add_below',
          height: 40,
          child: Row(
            children: [
              Icon(
                Icons.subdirectory_arrow_right,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Add set below',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Skip set
        PopupMenuItem<String>(
          value: 'skip',
          height: 40,
          child: Row(
            children: [
              Icon(
                Icons.fast_forward,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                set.isSkipped ? 'Unskip set' : 'Skip set',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Delete set
        const PopupMenuItem<String>(
          value: 'delete',
          height: 40,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text('Delete set', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // SET TYPE Header
        const PopupMenuItem<String>(
          enabled: false,
          height: 32,
          child: Text(
            'SET TYPE',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Regular
        PopupMenuItem<String>(
          value: 'regular',
          height: 40,
          child: Row(
            children: [
              Icon(
                set.setType == SetType.regular
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: set.setType == SetType.regular
                    ? Colors.red
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Regular',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Myorep
        PopupMenuItem<String>(
          value: 'myorep',
          height: 40,
          child: Row(
            children: [
              Icon(
                set.setType == SetType.myorep
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: set.setType == SetType.myorep ? Colors.red : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Myorep',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Myorep match
        PopupMenuItem<String>(
          value: 'myorep_match',
          height: 40,
          child: Row(
            children: [
              Icon(
                set.setType == SetType.myorepMatch
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: set.setType == SetType.myorepMatch
                    ? Colors.red
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Myorep match',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // Max reps
        PopupMenuItem<String>(
          value: 'max_reps',
          height: 40,
          child: Row(
            children: [
              Icon(
                set.setType == SetType.maxReps
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: set.setType == SetType.maxReps
                    ? Colors.red
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Max reps',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        // End with partials
        PopupMenuItem<String>(
          value: 'end_with_partials',
          height: 40,
          child: Row(
            children: [
              Icon(
                set.setType == SetType.endWithPartials
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: set.setType == SetType.endWithPartials
                    ? Colors.red
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'End with partials',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _getSetTypeBadge(SetType setType) {
    switch (setType) {
      case SetType.myorep:
        return 'M';
      case SetType.myorepMatch:
        return 'MM';
      case SetType.maxReps:
        return 'MAX';
      case SetType.endWithPartials:
        return 'P';
      default:
        return null;
    }
  }
}
