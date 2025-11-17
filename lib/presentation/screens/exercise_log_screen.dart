import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/workout.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../domain/providers/workout_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/constants/equipment_types.dart';

/// Screen for logging exercise sets
///
/// Allows users to add/edit sets with weight, reps, and RIR support.
class ExerciseLogScreen extends ConsumerStatefulWidget {
  final String mesocycleId;
  final String workoutId;
  final String exerciseId;

  const ExerciseLogScreen({
    required this.mesocycleId,
    required this.workoutId,
    required this.exerciseId,
    super.key,
  });

  @override
  ConsumerState<ExerciseLogScreen> createState() => _ExerciseLogScreenState();
}

class _ExerciseLogScreenState extends ConsumerState<ExerciseLogScreen> {
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider(widget.workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showRIRInfoDialog,
            tooltip: 'RIR Info',
          ),
        ],
      ),
      body: workout == null
          ? _buildErrorState('Workout not found')
          : () {
              try {
                final exercise = workout.exercises.firstWhere(
                  (e) => e.id == widget.exerciseId,
                );
                return _buildExerciseContent(context, workout, exercise);
              } catch (e) {
                return _buildErrorState('Exercise not found');
              }
            }(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => GoRouter.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent(
    BuildContext context,
    Workout workout,
    Exercise exercise,
  ) {
    return CustomScrollView(
      slivers: [
        // Exercise header
        SliverToBoxAdapter(
          child: _buildExerciseHeader(context, exercise),
        ),

        // Sets list
        if (exercise.sets.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(context, workout, exercise),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final set = exercise.sets[index];
                return _buildSetCard(
                  context,
                  workout,
                  exercise,
                  set,
                  index,
                );
              },
              childCount: exercise.sets.length,
            ),
          ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildExerciseHeader(BuildContext context, Exercise exercise) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.colorScheme.primaryContainer,
                  radius: 24,
                  child: Icon(
                    Icons.fitness_center,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exercise.muscleGroup.displayName} • ${exercise.equipmentType.displayName}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (exercise.sets.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildProgressInfo(
                      context,
                      'Sets Logged',
                      '${exercise.completedSets}/${exercise.totalSets}',
                      Icons.check_circle_outline,
                    ),
                  ),
                  Expanded(
                    child: _buildProgressInfo(
                      context,
                      'Completion',
                      '${(exercise.completionPercentage * 100).toInt()}%',
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: exercise.completionPercentage,
                backgroundColor: context.colorScheme.surfaceContainerHighest,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 20,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Notes',
                    style: context.textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                exercise.notes!,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: context.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Workout workout,
    Exercise exercise,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.format_list_numbered,
              size: 64,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No sets yet',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a set to start logging',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _addSet(workout, exercise),
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetCard(
    BuildContext context,
    Workout workout,
    Exercise exercise,
    ExerciseSet set,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _editSet(workout, exercise, set, index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: set.isLogged
                        ? context.colorScheme.primaryContainer
                        : context.colorScheme.surfaceContainerHighest,
                    child: Text(
                      '${set.setNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: set.isLogged
                            ? context.colorScheme.onPrimaryContainer
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSetTypeLabel(set.setType),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (set.weight != null) ...[
                              Icon(
                                Icons.fitness_center,
                                size: 16,
                                color: context.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${set.weight} lbs',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Icon(
                              Icons.repeat,
                              size: 16,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              set.reps,
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (set.isLogged)
                    Icon(
                      Icons.check_circle,
                      color: context.colorScheme.primary,
                    )
                  else
                    Icon(
                      Icons.radio_button_unchecked,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editSet(workout, exercise, set, index);
                          break;
                        case 'delete':
                          _deleteSet(workout, exercise, index);
                          break;
                        case 'toggle':
                          _toggleSetLogged(workout, exercise, set, index);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(set.isLogged
                                ? Icons.radio_button_unchecked
                                : Icons.check_circle),
                            const SizedBox(width: 8),
                            Text(set.isLogged
                                ? 'Mark incomplete'
                                : 'Mark complete'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (set.notes != null && set.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          set.notes!,
                          style: context.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getSetTypeLabel(SetType type) {
    switch (type) {
      case SetType.regular:
        return 'Regular Set';
      case SetType.myorep:
        return 'Myorep Set';
      case SetType.myorepMatch:
        return 'Myorep Match Set';
    }
  }

  void _addSet(Workout workout, Exercise exercise) {
    final newSetNumber = exercise.sets.length + 1;
    _showSetDialog(
      context,
      workout,
      exercise,
      null,
      null,
      setNumber: newSetNumber,
    );
  }

  void _editSet(
    Workout workout,
    Exercise exercise,
    ExerciseSet set,
    int index,
  ) {
    _showSetDialog(context, workout, exercise, set, index);
  }

  void _toggleSetLogged(
    Workout workout,
    Exercise exercise,
    ExerciseSet set,
    int index,
  ) {
    final updatedSet = set.copyWith(isLogged: !set.isLogged);
    final updatedExercise = exercise.updateSet(index, updatedSet);
    final exerciseIndex =
        workout.exercises.indexWhere((e) => e.id == exercise.id);
    final updatedWorkout =
        workout.updateExercise(exerciseIndex, updatedExercise);
    ref.read(workoutRepositoryProvider).update(updatedWorkout);
  }

  void _deleteSet(Workout workout, Exercise exercise, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Set'),
        content: const Text(
          'Are you sure you want to delete this set?',
        ),
        actions: [
          TextButton(
            onPressed: () => GoRouter.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updatedExercise = exercise.removeSet(index);
              final exerciseIndex =
                  workout.exercises.indexWhere((e) => e.id == exercise.id);
              final updatedWorkout =
                  workout.updateExercise(exerciseIndex, updatedExercise);
              ref.read(workoutRepositoryProvider).update(updatedWorkout);
              GoRouter.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSetDialog(
    BuildContext context,
    Workout workout,
    Exercise exercise,
    ExerciseSet? existingSet,
    int? setIndex, {
    int? setNumber,
  }) {
    final weightController = TextEditingController(
      text: existingSet?.weight?.toString() ?? '',
    );
    final repsController = TextEditingController(
      text: existingSet?.reps ?? '',
    );
    final notesController = TextEditingController(
      text: existingSet?.notes ?? '',
    );
    SetType selectedSetType = existingSet?.setType ?? SetType.regular;
    bool isLogged = existingSet?.isLogged ?? false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingSet == null ? 'Add Set' : 'Edit Set'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Set type selector
                Text(
                  'Set Type',
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<SetType>(
                  segments: const [
                    ButtonSegment(
                      value: SetType.regular,
                      label: Text('Regular'),
                    ),
                    ButtonSegment(
                      value: SetType.myorep,
                      label: Text('Myorep'),
                    ),
                    ButtonSegment(
                      value: SetType.myorepMatch,
                      label: Text('Match'),
                    ),
                  ],
                  selected: {selectedSetType},
                  onSelectionChanged: (Set<SetType> newSelection) {
                    setState(() {
                      selectedSetType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Weight input
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (lbs)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),
                const SizedBox(height: 16),

                // Reps input (supports RIR format)
                TextField(
                  controller: repsController,
                  decoration: const InputDecoration(
                    labelText: 'Reps (e.g., "10" or "2 RIR")',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.repeat),
                    helperText: 'Enter number or "X RIR" for RIR format',
                  ),
                ),
                const SizedBox(height: 16),

                // Notes input
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Logged checkbox
                CheckboxListTile(
                  title: const Text('Mark as logged'),
                  value: isLogged,
                  onChanged: (value) {
                    setState(() {
                      isLogged = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final weight = weightController.text.isEmpty
                    ? null
                    : double.tryParse(weightController.text);
                final reps = repsController.text.isEmpty
                    ? '0'
                    : repsController.text;

                if (reps == '0' || reps.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter reps'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final newSet = ExerciseSet(
                  id: existingSet?.id ?? _uuid.v4(),
                  setNumber: existingSet?.setNumber ?? setNumber ?? 1,
                  weight: weight,
                  reps: reps,
                  setType: selectedSetType,
                  isLogged: isLogged,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );

                Exercise updatedExercise;
                if (existingSet != null && setIndex != null) {
                  updatedExercise = exercise.updateSet(setIndex, newSet);
                } else {
                  updatedExercise = exercise.addSet(newSet);
                }

                final exerciseIndex =
                    workout.exercises.indexWhere((e) => e.id == exercise.id);
                final updatedWorkout =
                    workout.updateExercise(exerciseIndex, updatedExercise);
                ref
                    .read(workoutRepositoryProvider)
                    .update(updatedWorkout);

                Navigator.of(dialogContext).pop();
              },
              child: Text(existingSet == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRIRInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('RIR (Reps in Reserve)'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What is RIR?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'RIR stands for "Reps in Reserve" - it indicates how many more reps you could have done before failure.',
              ),
              SizedBox(height: 16),
              Text(
                'How to use RIR:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 0 RIR = Trained to failure'),
              Text('• 1 RIR = Could do 1 more rep'),
              Text('• 2 RIR = Could do 2 more reps'),
              Text('• 3 RIR = Could do 3 more reps'),
              SizedBox(height: 16),
              Text(
                'Example:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'If you enter "2 RIR" it means you stopped your set when you could have done 2 more reps.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => GoRouter.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
