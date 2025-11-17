import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/workout.dart';
import '../../data/models/exercise.dart';
import '../../domain/providers/workout_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/constants/equipment_types.dart';

/// Screen for viewing and editing workout details
///
/// Shows the exercise list, allows adding/removing exercises,
/// and provides navigation to exercise logging.
class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final String mesocycleId;
  final String workoutId;

  const WorkoutDetailScreen({
    required this.mesocycleId,
    required this.workoutId,
    super.key,
  });

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider(widget.workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
        actions: [
          if (workout != null)
            IconButton(
              icon: const Icon(Icons.edit_note),
              onPressed: () => _showNotesDialog(context, workout),
              tooltip: 'Edit notes',
            ),
        ],
      ),
      body: workout == null
          ? Center(
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
                    'Workout not found',
                    style: context.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => GoRouter.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : _buildWorkoutContent(context, workout),
      floatingActionButton: workout != null &&
              workout.status != WorkoutStatus.completed
          ? FloatingActionButton.extended(
              onPressed: () => _addExercise(context, workout),
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            )
          : null,
    );
  }

  Widget _buildWorkoutContent(BuildContext context, Workout workout) {
    return CustomScrollView(
      slivers: [
        // Workout header
        SliverToBoxAdapter(
          child: _buildWorkoutHeader(context, workout),
        ),

        // Exercise list
        if (workout.exercises.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(context, workout),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final exercise = workout.exercises[index];
                return _buildExerciseCard(context, workout, exercise, index);
              },
              childCount: workout.exercises.length,
            ),
          ),

        // Bottom padding for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildWorkoutHeader(BuildContext context, Workout workout) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(workout.status),
                  color: _getStatusColor(context, workout.status),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.displayName,
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Week ${workout.weekNumber} • Day ${workout.dayNumber}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context, workout.status),
              ],
            ),
            if (workout.exercises.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildProgressInfo(
                      context,
                      'Exercises',
                      '${workout.completedExercises}/${workout.totalExercises}',
                      Icons.fitness_center,
                    ),
                  ),
                  Expanded(
                    child: _buildProgressInfo(
                      context,
                      'Completion',
                      '${(workout.completionPercentage * 100).toInt()}%',
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: workout.completionPercentage,
                backgroundColor:
                    context.colorScheme.surfaceContainerHighest,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            if (workout.notes != null && workout.notes!.isNotEmpty) ...[
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
                workout.notes!,
                style: context.textTheme.bodyMedium,
              ),
            ],
            if (workout.status != WorkoutStatus.completed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: workout.exercises.isEmpty
                      ? null
                      : () => _completeWorkout(context, workout),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Complete Workout'),
                ),
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

  Widget _buildStatusChip(BuildContext context, WorkoutStatus status) {
    return Chip(
      label: Text(
        status.name.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: _getStatusColor(context, status),
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: _getStatusColor(context, status).withValues(alpha: 0.1),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildEmptyState(BuildContext context, Workout workout) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No exercises yet',
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add exercises to start your workout',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _addExercise(context, workout),
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    Workout workout,
    Exercise exercise,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _openExerciseLogging(context, workout, exercise),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: exercise.isCompleted
                        ? context.colorScheme.primaryContainer
                        : context.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      exercise.isCompleted
                          ? Icons.check
                          : Icons.fitness_center,
                      size: 20,
                      color: exercise.isCompleted
                          ? context.colorScheme.onPrimaryContainer
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exercise.muscleGroup.displayName} • ${exercise.equipmentType.displayName}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          _deleteExercise(context, workout, index);
                          break;
                        case 'notes':
                          _showExerciseNotesDialog(
                            context,
                            workout,
                            exercise,
                            index,
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'notes',
                        child: Row(
                          children: [
                            Icon(Icons.note),
                            SizedBox(width: 8),
                            Text('Edit notes'),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildExerciseInfo(
                    context,
                    'Sets',
                    '${exercise.completedSets}/${exercise.totalSets}',
                    Icons.format_list_numbered,
                  ),
                  const SizedBox(width: 16),
                  if (exercise.sets.isNotEmpty)
                    _buildExerciseInfo(
                      context,
                      'Type',
                      exercise.hasMyorepSets ? 'Myorep' : 'Regular',
                      Icons.type_specimen,
                    ),
                ],
              ),
              if (exercise.sets.isNotEmpty) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: exercise.completionPercentage,
                  backgroundColor:
                      context.colorScheme.surfaceContainerHighest,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
              if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
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
                          exercise.notes!,
                          style: context.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildExerciseInfo(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: context.colorScheme.primary,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(WorkoutStatus status) {
    switch (status) {
      case WorkoutStatus.completed:
        return Icons.check_circle;
      case WorkoutStatus.skipped:
        return Icons.skip_next;
      case WorkoutStatus.incomplete:
        return Icons.radio_button_unchecked;
    }
  }

  Color _getStatusColor(BuildContext context, WorkoutStatus status) {
    switch (status) {
      case WorkoutStatus.completed:
        return Colors.green;
      case WorkoutStatus.skipped:
        return Colors.orange;
      case WorkoutStatus.incomplete:
        return context.colorScheme.onSurfaceVariant;
    }
  }

  void _addExercise(BuildContext context, Workout workout) {
    // TODO: Navigate to exercise selection screen
    GoRouter.of(context).push(
      '/mesocycles/${widget.mesocycleId}/workouts/${workout.id}/add-exercise',
    );
  }

  void _openExerciseLogging(
    BuildContext context,
    Workout workout,
    Exercise exercise,
  ) {
    GoRouter.of(context).push(
      '/mesocycles/${widget.mesocycleId}/workouts/${workout.id}/exercises/${exercise.id}',
    );
  }

  void _deleteExercise(BuildContext context, Workout workout, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: const Text(
          'Are you sure you want to delete this exercise? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => GoRouter.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updatedWorkout = workout.removeExercise(index);
              ref
                  .read(workoutRepositoryProvider)
                  .update(updatedWorkout);
              GoRouter.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _completeWorkout(BuildContext context, Workout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Workout'),
        content: const Text(
          'Mark this workout as completed? You can still edit it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => GoRouter.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final completedWorkout = workout.complete();
              ref
                  .read(workoutRepositoryProvider)
                  .update(completedWorkout);
              GoRouter.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout completed!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context, Workout? workout) {
    if (workout == null) return;

    final notesController = TextEditingController(text: workout.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Notes'),
        content: TextField(
          controller: notesController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add notes about this workout...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => GoRouter.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updatedWorkout = workout.copyWith(
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
              );
              ref
                  .read(workoutRepositoryProvider)
                  .update(updatedWorkout);
              GoRouter.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showExerciseNotesDialog(
    BuildContext context,
    Workout workout,
    Exercise exercise,
    int index,
  ) {
    final notesController = TextEditingController(text: exercise.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercise Notes'),
        content: TextField(
          controller: notesController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add notes about this exercise...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => GoRouter.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final updatedExercise = exercise.copyWith(
                notes: notesController.text.isEmpty
                    ? null
                    : notesController.text,
              );
              final updatedWorkout =
                  workout.updateExercise(index, updatedExercise);
              ref
                  .read(workoutRepositoryProvider)
                  .update(updatedWorkout);
              GoRouter.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
