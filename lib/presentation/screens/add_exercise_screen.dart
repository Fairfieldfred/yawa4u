import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_definition.dart';
import '../../data/models/exercise_set.dart';
import '../../domain/providers/database_providers.dart';
import '../../domain/providers/exercise_providers.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/workout_providers.dart';
import '../widgets/available_equipment_filter.dart';
import '../widgets/dialogs/create_custom_exercise_dialog.dart';

/// Screen for adding exercises from the library to a workout
class AddExerciseScreen extends ConsumerStatefulWidget {
  final String trainingCycleId;
  final String workoutId;
  final MuscleGroup? initialMuscleGroup;

  /// If provided, the selected exercise will replace this exercise instead of being added
  final String? replaceExerciseId;

  const AddExerciseScreen({
    super.key,
    required this.trainingCycleId,
    required this.workoutId,
    this.initialMuscleGroup,
    this.replaceExerciseId,
  });

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  String _searchQuery = '';
  MuscleGroup? _selectedMuscleGroup;
  final Set<EquipmentType> _selectedEquipment = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMuscleGroup = widget.initialMuscleGroup;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get filtered exercises from combined CSV + custom exercises
    final allExercises = ref.watch(allExerciseDefinitionsProvider);
    final filteredExercises = _filterExercises(allExercises);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('Add exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => GoRouter.of(context).pop(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCustomExerciseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Create Custom'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Filter chips
          if (_selectedMuscleGroup != null || _selectedEquipment.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Muscle group filter chip
                  if (_selectedMuscleGroup != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          _selectedMuscleGroup!.displayName,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.black.withValues(alpha: 0.85)
                                : Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withValues(alpha: 0.85),
                          ),
                        ),
                        selected: true,
                        onSelected: (_) {
                          setState(() => _selectedMuscleGroup = null);
                        },
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => _selectedMuscleGroup = null);
                        },
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                    ),

                  // Equipment filter chips
                  ..._selectedEquipment.map((equipment) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          equipment.displayName,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                ? Colors.black.withValues(alpha: 0.85)
                                : Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer
                                      .withValues(alpha: 0.85),
                          ),
                        ),
                        selected: true,
                        onSelected: (_) {
                          setState(() => _selectedEquipment.remove(equipment));
                        },
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() => _selectedEquipment.remove(equipment));
                        },
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                    );
                  }),

                  // Filter button
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: OutlinedButton.icon(
                      onPressed: () => _showFilterModal(context),
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: const Text('Filter'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Just show filter button when no filters applied
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showFilterModal(context),
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filter'),
                  ),
                ],
              ),
            ),

          // Exercise list
          Expanded(
            child: filteredExercises.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];
                      return _buildExerciseCard(exercise);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateCustomExerciseDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const CreateCustomExerciseDialog(),
    );
    // The provider will automatically update with the new custom exercise
  }

  List<ExerciseDefinition> _filterExercises(
    List<ExerciseDefinition> exercises,
  ) {
    var filtered = exercises;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Filter by muscle group
    if (_selectedMuscleGroup != null) {
      filtered = filtered
          .where((e) => e.muscleGroup == _selectedMuscleGroup)
          .toList();
    }

    // Filter by selected equipment types (manual filter in modal)
    if (_selectedEquipment.isNotEmpty) {
      filtered = filtered
          .where((e) => _selectedEquipment.contains(e.equipmentType))
          .toList();
    }

    // Filter by user's available equipment (persisted setting)
    final equipmentFilterEnabled = ref.watch(equipmentFilterEnabledProvider);
    if (equipmentFilterEnabled) {
      final availableEquipment = ref.watch(selectedEquipmentProvider);
      if (availableEquipment.isNotEmpty) {
        // Use the mapping from EquipmentOption to EquipmentType
        final availableTypes = EquipmentOption.getEquipmentTypes(
          availableEquipment.toSet(),
        );
        filtered = filtered
            .where((e) => availableTypes.contains(e.equipmentType))
            .toList();
      }
    }

    return filtered;
  }

  Widget _buildExerciseCard(ExerciseDefinition exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          exercise.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              // Muscle group badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  exercise.muscleGroup.displayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black.withValues(alpha: 0.85)
                        : Theme.of(context).colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.85),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Equipment badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  exercise.equipmentType.displayName,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black.withValues(alpha: 0.85)
                        : Theme.of(context).colorScheme.onSecondaryContainer
                              .withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: FilledButton(
          onPressed: () => _addExerciseToWorkout(exercise),
          child: const Text('Add'),
        ),
        onTap: () => _addExerciseToWorkout(exercise),
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterModal(
        ref: ref,
        selectedMuscleGroup: _selectedMuscleGroup,
        selectedEquipment: _selectedEquipment,
        onApply: (muscleGroup, equipment) {
          setState(() {
            _selectedMuscleGroup = muscleGroup;
            _selectedEquipment.clear();
            _selectedEquipment.addAll(equipment);
          });
        },
      ),
    );
  }

  void _addExerciseToWorkout(ExerciseDefinition exerciseDef) {
    final workout = ref.read(workoutProvider(widget.workoutId));
    if (workout == null) return;

    // Check if we're replacing an existing exercise
    final isReplacing = widget.replaceExerciseId != null;
    final existingExercise = isReplacing
        ? workout.exercises
              .where((e) => e.id == widget.replaceExerciseId)
              .firstOrNull
        : null;

    // Create new exercise from definition
    final newExercise = Exercise(
      id: const Uuid().v4(),
      workoutId: workout.id,
      name: exerciseDef.name,
      muscleGroup: exerciseDef.muscleGroup,
      equipmentType: exerciseDef.equipmentType,
      orderIndex: existingExercise?.orderIndex ?? workout.exercises.length,
      videoUrl: exerciseDef.videoUrl,
      sets:
          existingExercise?.sets ??
          [
            ExerciseSet(
              id: const Uuid().v4(),
              setNumber: 1,
              reps: '',
              setType: SetType.regular,
            ),
            ExerciseSet(
              id: const Uuid().v4(),
              setNumber: 2,
              reps: '',
              setType: SetType.regular,
            ),
          ],
    );

    List<Exercise> updatedExercises;
    if (isReplacing) {
      // Replace the existing exercise with the new one
      updatedExercises = workout.exercises.map((e) {
        if (e.id == widget.replaceExerciseId) {
          return newExercise;
        }
        return e;
      }).toList();
    } else {
      // Add this exercise to the existing exercises
      updatedExercises = [...workout.exercises, newExercise];
    }

    final updatedWorkout = workout.copyWith(exercises: updatedExercises);
    ref.read(workoutRepositoryProvider).update(updatedWorkout);

    // Show confirmation and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isReplacing
              ? '${existingExercise?.name ?? "Exercise"} replaced with ${exerciseDef.name}'
              : '${exerciseDef.name} added',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    GoRouter.of(context).pop();
  }
}

/// Filter modal for selecting muscle group and equipment
class _FilterModal extends ConsumerStatefulWidget {
  final MuscleGroup? selectedMuscleGroup;
  final Set<EquipmentType> selectedEquipment;
  final Function(MuscleGroup?, Set<EquipmentType>) onApply;
  final WidgetRef ref;

  const _FilterModal({
    required this.ref,
    required this.selectedMuscleGroup,
    required this.selectedEquipment,
    required this.onApply,
  });

  @override
  ConsumerState<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<_FilterModal> {
  MuscleGroup? _tempMuscleGroup;
  final Set<EquipmentType> _tempEquipment = {};

  @override
  void initState() {
    super.initState();
    _tempMuscleGroup = widget.selectedMuscleGroup;
    _tempEquipment.addAll(widget.selectedEquipment);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempMuscleGroup = null;
                      _tempEquipment.clear();
                    });
                  },
                  child: const Text('CLEAR ALL'),
                ),
                Text('Filter', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Available Equipment Filter (shared widget)
                const AvailableEquipmentFilter(compact: true, autoSave: true),

                const SizedBox(height: 24),

                // Muscle Group section
                Text(
                  'Muscle Group',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MuscleGroup.values.map((muscleGroup) {
                    final isSelected = _tempMuscleGroup == muscleGroup;
                    return ChoiceChip(
                      label: Text(muscleGroup.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _tempMuscleGroup = selected ? muscleGroup : null;
                        });
                      },
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Equipment Type section (manual filter for this session)
                Text(
                  'Filter by Equipment Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temporarily filter to specific equipment types',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: EquipmentType.values.map((equipment) {
                    final isSelected = _tempEquipment.contains(equipment);
                    return FilterChip(
                      label: Text(equipment.displayName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _tempEquipment.add(equipment);
                          } else {
                            _tempEquipment.remove(equipment);
                          }
                        });
                      },
                      selectedColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Apply button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_tempMuscleGroup, _tempEquipment);
                    Navigator.pop(context);
                  },
                  child: const Text('APPLY FILTERS'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
