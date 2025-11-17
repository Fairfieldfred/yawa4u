import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/constants/equipment_types.dart';
import '../../data/models/exercise_definition.dart';
import '../../data/models/exercise.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/exercise_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../../domain/providers/repository_providers.dart';

/// Screen for selecting an exercise from the library to add to a workout
class ExerciseSelectionScreen extends ConsumerStatefulWidget {
  final String mesocycleId;
  final String workoutId;

  const ExerciseSelectionScreen({
    required this.mesocycleId,
    required this.workoutId,
    super.key,
  });

  @override
  ConsumerState<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState
    extends ConsumerState<ExerciseSelectionScreen> {
  String _searchQuery = '';
  MuscleGroup? _selectedMuscleGroup;
  EquipmentType? _selectedEquipment;

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider(widget.workoutId));
    final filteredExercises = ref.watch(
      exerciseDefinitionsFilterProvider((
        searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        muscleGroup: _selectedMuscleGroup,
        equipmentType: _selectedEquipment,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(
                        _selectedMuscleGroup?.displayName ?? 'Muscle Group',
                      ),
                      selected: _selectedMuscleGroup != null,
                      onSelected: (selected) {
                        _showMuscleGroupPicker(context);
                      },
                      avatar: _selectedMuscleGroup != null
                          ? const Icon(Icons.check, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(
                        _selectedEquipment?.displayName ?? 'Equipment',
                      ),
                      selected: _selectedEquipment != null,
                      onSelected: (selected) {
                        _showEquipmentPicker(context);
                      },
                      avatar: _selectedEquipment != null
                          ? const Icon(Icons.check, size: 16)
                          : null,
                    ),
                    if (_selectedMuscleGroup != null ||
                        _selectedEquipment != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedMuscleGroup = null;
                            _selectedEquipment = null;
                          });
                        },
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Clear Filters'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: workout == null
          ? _buildErrorState('Workout not found')
          : filteredExercises.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exerciseDef = filteredExercises[index];
                    return _buildExerciseCard(context, exerciseDef, workout);
                  },
                ),
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
            message,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (_searchQuery.isNotEmpty ||
              _selectedMuscleGroup != null ||
              _selectedEquipment != null)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedMuscleGroup = null;
                  _selectedEquipment = null;
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All Filters'),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    ExerciseDefinition exerciseDef,
    Workout workout,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colorScheme.primaryContainer,
          child: Icon(
            _getMuscleGroupIcon(exerciseDef.muscleGroup),
            color: context.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          exerciseDef.name,
          style: context.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 14,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  exerciseDef.muscleGroup.displayName,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _getEquipmentIcon(exerciseDef.equipmentType),
                  size: 14,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  exerciseDef.equipmentType.displayName,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: FilledButton(
          onPressed: () => _addExerciseToWorkout(context, exerciseDef, workout),
          child: const Text('Add'),
        ),
        onTap: () => _showExerciseDetails(context, exerciseDef),
      ),
    );
  }

  IconData _getMuscleGroupIcon(MuscleGroup muscleGroup) {
    switch (muscleGroup) {
      case MuscleGroup.chest:
        return Icons.straighten;
      case MuscleGroup.back:
        return Icons.back_hand;
      case MuscleGroup.shoulders:
        return Icons.arrow_upward;
      case MuscleGroup.biceps:
      case MuscleGroup.triceps:
      case MuscleGroup.forearms:
        return Icons.fitness_center;
      case MuscleGroup.quads:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
        return Icons.directions_walk;
      case MuscleGroup.abs:
      case MuscleGroup.traps:
        return Icons.circle_outlined;
    }
  }

  IconData _getEquipmentIcon(EquipmentType equipmentType) {
    switch (equipmentType) {
      case EquipmentType.barbell:
        return Icons.horizontal_rule;
      case EquipmentType.dumbbell:
        return Icons.fitness_center;
      case EquipmentType.machine:
      case EquipmentType.machineAssistance:
      case EquipmentType.smithMachine:
      case EquipmentType.freemotion:
        return Icons.settings;
      case EquipmentType.cable:
        return Icons.cable;
      case EquipmentType.bodyweightLoadable:
      case EquipmentType.bodyweightOnly:
        return Icons.accessibility;
    }
  }

  void _showMuscleGroupPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Muscle Group',
                      style: context.textTheme.titleLarge,
                    ),
                    if (_selectedMuscleGroup != null)
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedMuscleGroup = null);
                          GoRouter.of(context).pop();
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              ...MuscleGroup.values.map((group) {
                return ListTile(
                  leading: Icon(_getMuscleGroupIcon(group)),
                  title: Text(group.displayName),
                  selected: _selectedMuscleGroup == group,
                  onTap: () {
                    setState(() => _selectedMuscleGroup = group);
                    GoRouter.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showEquipmentPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Equipment',
                      style: context.textTheme.titleLarge,
                    ),
                    if (_selectedEquipment != null)
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedEquipment = null);
                          GoRouter.of(context).pop();
                        },
                        child: const Text('Clear'),
                      ),
                  ],
                ),
              ),
              ...EquipmentType.values.map((equipment) {
                return ListTile(
                  leading: Icon(_getEquipmentIcon(equipment)),
                  title: Text(equipment.displayName),
                  selected: _selectedEquipment == equipment,
                  onTap: () {
                    setState(() => _selectedEquipment = equipment);
                    GoRouter.of(context).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showExerciseDetails(
    BuildContext context,
    ExerciseDefinition exerciseDef,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exerciseDef.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              context,
              'Muscle Group',
              exerciseDef.muscleGroup.displayName,
              _getMuscleGroupIcon(exerciseDef.muscleGroup),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              context,
              'Equipment',
              exerciseDef.equipmentType.displayName,
              _getEquipmentIcon(exerciseDef.equipmentType),
            ),
            if (exerciseDef.videoUrl != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Video Tutorial Available',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => GoRouter.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              GoRouter.of(context).pop();
              final workout = ref.read(workoutProvider(widget.workoutId));
              if (workout != null) {
                _addExerciseToWorkout(context, exerciseDef, workout);
              }
            },
            child: const Text('Add Exercise'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
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
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }

  void _addExerciseToWorkout(
    BuildContext context,
    ExerciseDefinition exerciseDef,
    Workout workout,
  ) {
    // Create a new Exercise from the ExerciseDefinition
    final newExercise = Exercise(
      id: const Uuid().v4(),
      workoutId: workout.id,
      name: exerciseDef.name,
      muscleGroup: exerciseDef.muscleGroup,
      equipmentType: exerciseDef.equipmentType,
      orderIndex: workout.exercises.length,
      videoUrl: exerciseDef.videoUrl,
    );

    // Add the exercise to the workout
    final updatedWorkout = workout.addExercise(newExercise);

    // Update the workout in the repository
    ref.read(workoutRepositoryProvider).update(updatedWorkout);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exerciseDef.name} added to workout'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(workoutRepositoryProvider).update(workout);
          },
        ),
      ),
    );

    // Pop back to workout detail screen
    GoRouter.of(context).pop();
  }
}
