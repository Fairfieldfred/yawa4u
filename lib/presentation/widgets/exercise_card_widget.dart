import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/theme/skins/skins.dart';
import '../../core/utils/weight_conversion.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../domain/providers/database_providers.dart';
import 'dialogs/exercise_info_dialog.dart';
import 'muscle_group_badge.dart';

/// Bundles all callbacks for [ExerciseCardWidget] into a single object.
///
/// Reduces the number of constructor parameters from 15 individual callbacks
/// to one, making call sites cleaner and easier to maintain.
@immutable
class ExerciseCardCallbacks {
  // Exercise-level callbacks
  final void Function(String exerciseId) onAddNote;
  final void Function(String exerciseId)? onMoveUp;
  final void Function(String exerciseId)? onMoveDown;
  final void Function(String exerciseId) onReplace;
  final void Function(String exerciseId) onJointPain;
  final void Function(String exerciseId) onAddSet;
  final void Function(String exerciseId) onSkipSets;
  final void Function(String exerciseId) onDelete;

  // Set-level callbacks
  final void Function(int setIndex) onAddSetBelow;
  final void Function(int setIndex) onToggleSetSkip;
  final void Function(int setIndex) onDeleteSet;
  final void Function(int setIndex, SetType setType) onUpdateSetType;
  final void Function(int setIndex, String value) onUpdateSetWeight;
  final void Function(int setIndex, String value) onUpdateSetReps;
  final void Function(int setIndex) onToggleSetLog;

  const ExerciseCardCallbacks({
    required this.onAddNote,
    this.onMoveUp,
    this.onMoveDown,
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
}

/// Shared widget for displaying an exercise card with sets.
/// Used in both workout_screen and exercises_screen.
class ExerciseCardWidget extends ConsumerWidget {
  final Exercise exercise;
  final bool showMuscleGroupBadge;
  final int? targetRir;
  final String weightUnit;
  final bool useMetric;
  final ExerciseCardCallbacks callbacks;
  final bool showMoveDown;
  final bool isFirstExercise;
  final bool isLastExercise;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
    required this.showMuscleGroupBadge,
    this.targetRir,
    this.weightUnit = 'lbs',
    this.useMetric = false,
    required this.callbacks,
    this.showMoveDown = true,
    this.isFirstExercise = false,
    this.isLastExercise = false,
  });

  /// Find the most recent pinned note for exercises with the same name
  Future<String?> _findPinnedNoteForExercise(WidgetRef ref) async {
    // First check if current exercise has a pinned note
    if (exercise.isNotePinned &&
        exercise.notes != null &&
        exercise.notes!.isNotEmpty) {
      return exercise.notes;
    }

    // Look for pinned notes from other exercises with the same name
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final allWorkouts = await workoutRepo.getAll();

    // Find all exercises with the same name that have pinned notes
    final pinnedExercises = <Exercise>[];
    for (final workout in allWorkouts) {
      for (final ex in workout.exercises) {
        if (ex.name.toLowerCase() == exercise.name.toLowerCase() &&
            ex.id != exercise.id &&
            ex.isNotePinned &&
            ex.notes != null &&
            ex.notes!.isNotEmpty) {
          pinnedExercises.add(ex);
        }
      }
    }

    if (pinnedExercises.isEmpty) return null;

    // Return the most recent pinned note (by lastPerformed date, or just the first one)
    pinnedExercises.sort((a, b) {
      if (a.lastPerformed == null && b.lastPerformed == null) return 0;
      if (a.lastPerformed == null) return 1;
      if (b.lastPerformed == null) return -1;
      return b.lastPerformed!.compareTo(a.lastPerformed!);
    });

    return pinnedExercises.first.notes;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muscleGroup = exercise.muscleGroup;
    final equipmentType = exercise.equipmentType;

    return FutureBuilder<String?>(
      future: _findPinnedNoteForExercise(ref),
      builder: (context, snapshot) {
        final pinnedNote = snapshot.data;

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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
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
                                color: Theme.of(context).colorScheme.outline,
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
                        Semantics(
                          label: 'Exercise options for '
                              '${exercise.name}',
                          child:
                              _buildExerciseOverflowMenu(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Column headers
                    if (exercise.sets.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
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
                                      ? Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.7)
                                      : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'REPS',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.7)
                                      : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 32),
                            SizedBox(
                              width: 40,
                              child: Text(
                                'LOG',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
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

                    // Pinned note display (at bottom of card)
                    // Shows pinned notes from any exercise with the same name
                    if (pinnedNote != null)
                      _buildPinnedNote(context, pinnedNote),
                  ],
                ),
              ),
            ),

            // Muscle group badge - overlays the card
            if (showMuscleGroupBadge)
              MuscleGroupBadge.compact(
                muscleGroup: muscleGroup,
                secondaryMuscleGroup: exercise.secondaryMuscleGroup,
              ),
          ],
        );
      },
    );
  }

  Widget _buildPinnedNote(BuildContext context, String noteText) {
    return InkWell(
      onTap: () => callbacks.onAddNote(exercise.id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withAlpha(51),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withAlpha(77),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.push_pin,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                noteText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Icon(
              Icons.edit,
              size: 14,
              color: Theme.of(context).colorScheme.primary.withAlpha(153),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseOverflowMenu(BuildContext context) {
    final onSurfaceColor = Theme.of(context).colorScheme.onSurface;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).textTheme.bodySmall?.color,
        size: 24,
      ),
      offset: const Offset(-180, 40),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 250),
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      onSelected: (value) {
        switch (value) {
          case 'note':
            callbacks.onAddNote(exercise.id);
            break;
          case 'move_up':
            callbacks.onMoveUp?.call(exercise.id);
            break;
          case 'move_down':
            callbacks.onMoveDown?.call(exercise.id);
            break;
          case 'replace':
            callbacks.onReplace(exercise.id);
            break;
          case 'joint_pain':
            callbacks.onJointPain(exercise.id);
            break;
          case 'add_set':
            callbacks.onAddSet(exercise.id);
            break;
          case 'skip_sets':
            callbacks.onSkipSets(exercise.id);
            break;
          case 'delete':
            callbacks.onDelete(exercise.id);
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
        PopupMenuItem<String>(
          value: 'note',
          height: 48,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: onSurfaceColor, size: 20),
              const SizedBox(width: 12),
              Text('New note', style: TextStyle(color: onSurfaceColor)),
            ],
          ),
        ),
        // Move up (conditionally shown, disabled if first exercise)
        if (showMoveDown)
          PopupMenuItem<String>(
            value: 'move_up',
            enabled: !isFirstExercise,
            height: 48,
            child: Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  color: isFirstExercise ? Colors.grey : onSurfaceColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Move up',
                  style: TextStyle(
                    color: isFirstExercise ? Colors.grey : onSurfaceColor,
                  ),
                ),
              ],
            ),
          ),
        // Move down (conditionally shown, disabled if last exercise)
        if (showMoveDown)
          PopupMenuItem<String>(
            value: 'move_down',
            enabled: !isLastExercise,
            height: 48,
            child: Row(
              children: [
                Icon(
                  Icons.arrow_downward,
                  color: isLastExercise ? Colors.grey : onSurfaceColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Move down',
                  style: TextStyle(
                    color: isLastExercise ? Colors.grey : onSurfaceColor,
                  ),
                ),
              ],
            ),
          ),
        // Replace
        PopupMenuItem<String>(
          value: 'replace',
          height: 48,
          child: Row(
            children: [
              Icon(Icons.swap_horiz, color: onSurfaceColor, size: 20),
              const SizedBox(width: 12),
              Text('Replace', style: TextStyle(color: onSurfaceColor)),
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
                    ? onSurfaceColor
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Joint pain',
                style: TextStyle(
                  color: exercise.sets.any((s) => s.isLogged)
                      ? onSurfaceColor
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        // Add set
        PopupMenuItem<String>(
          value: 'add_set',
          height: 48,
          child: Row(
            children: [
              Icon(Icons.add, color: onSurfaceColor, size: 20),
              const SizedBox(width: 12),
              Text('Add set', style: TextStyle(color: onSurfaceColor)),
            ],
          ),
        ),
        // Skip sets
        PopupMenuItem<String>(
          value: 'skip_sets',
          height: 48,
          child: Row(
            children: [
              Icon(Icons.fast_forward, color: onSurfaceColor, size: 20),
              const SizedBox(width: 12),
              Text('Skip sets', style: TextStyle(color: onSurfaceColor)),
            ],
          ),
        ),
        // Delete exercise
        PopupMenuItem<String>(
          value: 'delete',
          enabled: !exercise.sets.any((s) => s.isLogged),
          height: 48,
          child: Builder(
            builder: (context) => Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  color: exercise.sets.any((s) => s.isLogged)
                      ? Colors.grey
                      : context.errorColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Delete exercise',
                  style: TextStyle(
                    color: exercise.sets.any((s) => s.isLogged)
                        ? Colors.grey
                        : context.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetRow(BuildContext context, ExerciseSet set, int index) {
    final isLoggable = set.weight != null && set.reps.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Set menu (3 dots)
          SizedBox(
            width: 24,
            child: _buildSetOverflowMenu(context, set, index),
          ),
          const SizedBox(width: 24),
          // Weight Input
          Expanded(
            child: Semantics(
              label: 'Weight for set ${index + 1}',
              textField: true,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(
                    context.inputBorderRadius,
                  ),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: Center(
                  child: TextFormField(
                    key: ValueKey('weight_${set.id}_$useMetric'),
                    initialValue: formatWeightForDisplay(
                      set.weight,
                      useMetric,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: false,
                      hintText: weightUnit,
                      hintStyle: Theme.of(context)
                          .inputDecorationTheme
                          .hintStyle,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.inputBorderRadius,
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.inputBorderRadius,
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 1,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.inputBorderRadius,
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.only(bottom: 12),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) {
                      // Convert user input back to storage unit (lbs)
                      final displayWeight = double.tryParse(value);
                      if (displayWeight == null && value.isNotEmpty) return;
                      final storageWeight = convertWeightForStorage(
                        displayWeight,
                        useMetric,
                      );
                      callbacks.onUpdateSetWeight(
                        index,
                        storageWeight?.toString() ?? '',
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),

          // Reps Input
          Expanded(
            child: Semantics(
              label: 'Reps for set ${index + 1}',
              textField: true,
              child: Stack(
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(
                      context.inputBorderRadius,
                    ),
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
                        filled: false,
                        hintText: targetRir != null ? '$targetRir RIR' : 'RIR',
                        hintStyle: Theme.of(
                          context,
                        ).inputDecorationTheme.hintStyle,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.inputBorderRadius,
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.inputBorderRadius,
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.inputBorderRadius,
                          ),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.only(bottom: 12),
                      ),
                      onChanged: (value) {
                        callbacks.onUpdateSetReps(index, value);
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
          ),
          const SizedBox(width: 48),

          // Log Checkbox
          Semantics(
            label: 'Log set ${index + 1}',
            checked: set.isLogged,
            enabled: isLoggable,
            child: SizedBox(
              width: 30,
              height: 30,
              child: Container(
                decoration: BoxDecoration(
                  color: set.isLogged
                      ? context.successColor.withValues(alpha: 0.2)
                      : (isLoggable
                            ? Theme.of(context).inputDecorationTheme.fillColor
                            : Colors.grey.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: set.isLogged
                        ? context.successColor
                        : (isLoggable
                              ? context.successColor
                              : Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.3)),
                    width: set.isLogged || isLoggable ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: isLoggable
                      ? () => callbacks.onToggleSetLog(index)
                      : null,
                  child: set.isLogged
                      ? Icon(Icons.check, color: context.successColor)
                      : null,
                ),
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
            callbacks.onAddSetBelow(index);
            break;
          case 'skip':
            callbacks.onToggleSetSkip(index);
            break;
          case 'delete':
            callbacks.onDeleteSet(index);
            break;
          case 'regular':
            callbacks.onUpdateSetType(index, SetType.regular);
            break;
          case 'myorep':
            callbacks.onUpdateSetType(index, SetType.myorep);
            break;
          case 'myorep_match':
            callbacks.onUpdateSetType(index, SetType.myorepMatch);
            break;
          case 'max_reps':
            callbacks.onUpdateSetType(index, SetType.maxReps);
            break;
          case 'end_with_partials':
            callbacks.onUpdateSetType(index, SetType.endWithPartials);
            break;
          case 'drop_set':
            callbacks.onUpdateSetType(index, SetType.dropSet);
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
        PopupMenuItem<String>(
          value: 'delete',
          height: 40,
          child: Builder(
            builder: (context) => Row(
              children: [
                Icon(Icons.delete_outline, color: context.errorColor, size: 20),
                const SizedBox(width: 12),
                Text('Delete set', style: TextStyle(color: context.errorColor)),
              ],
            ),
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
                    ? context.selectedIndicatorColor
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
                color: set.setType == SetType.myorep
                    ? context.selectedIndicatorColor
                    : Colors.grey,
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
          enabled: index > 0,
          height: 40,
          child: Row(
            children: [
              Icon(
                set.setType == SetType.myorepMatch
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: index > 0
                    ? (set.setType == SetType.myorepMatch
                          ? context.selectedIndicatorColor
                          : Colors.grey)
                    : Colors.grey.withValues(alpha: 0.4),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Myorep match',
                style: TextStyle(
                  color: index > 0
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey.withValues(alpha: 0.4),
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
                    ? context.selectedIndicatorColor
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
                    ? context.selectedIndicatorColor
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
        // Drop set
        PopupMenuItem<String>(
          value: 'drop_set',
          enabled: index > 0,
          height: 40,
          child: Row(
            children: [
              Icon(
                set.setType == SetType.dropSet
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: index > 0
                    ? (set.setType == SetType.dropSet
                          ? context.selectedIndicatorColor
                          : Colors.grey)
                    : Colors.grey.withValues(alpha: 0.4),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Drop set',
                style: TextStyle(
                  color: index > 0
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey.withValues(alpha: 0.4),
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
      case SetType.dropSet:
        return 'DS';
      default:
        return null;
    }
  }
}
