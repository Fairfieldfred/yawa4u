import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/equipment_types.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/custom_exercise_definition.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/exercise_providers.dart';

/// Dialog for creating a new custom exercise
class CreateCustomExerciseDialog extends ConsumerStatefulWidget {
  const CreateCustomExerciseDialog({super.key});

  @override
  ConsumerState<CreateCustomExerciseDialog> createState() =>
      _CreateCustomExerciseDialogState();
}

class _CreateCustomExerciseDialogState
    extends ConsumerState<CreateCustomExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  MuscleGroup _selectedMuscleGroup = MuscleGroup.chest;
  MuscleGroup? _selectedSecondaryMuscleGroup;
  EquipmentType _selectedEquipmentType = EquipmentType.barbell;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    // Check if exercise name already exists
    final existsAsync = ref.read(exerciseNameExistsProvider(name));
    final exists = existsAsync.when(
      data: (value) => value,
      loading: () => false,
      error: (_, __) => false,
    );
    if (exists) {
      setState(() {
        _errorMessage = 'An exercise with this name already exists';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final customExercise = CustomExerciseDefinition(
        id: const Uuid().v4(),
        name: name,
        muscleGroup: _selectedMuscleGroup,
        secondaryMuscleGroup: _selectedSecondaryMuscleGroup,
        equipmentType: _selectedEquipmentType,
      );

      final repository = ref.read(customExerciseRepositoryProvider);
      await repository.add(customExercise);

      if (mounted) {
        Navigator.of(context).pop(customExercise.toExerciseDefinition());
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create exercise: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create Custom Exercise',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Exercise name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Exercise Name',
                  hintText: 'e.g., Cable Chest Fly',
                  prefixIcon: const Icon(Icons.fitness_center),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an exercise name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Muscle group dropdown
              DropdownButtonFormField<MuscleGroup>(
                initialValue: _selectedMuscleGroup,
                decoration: InputDecoration(
                  labelText: 'Muscle Group',
                  prefixIcon: const Icon(Icons.accessibility_new),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: MuscleGroup.values.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMuscleGroup = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Secondary muscle group dropdown (optional)
              DropdownButtonFormField<MuscleGroup?>(
                initialValue: _selectedSecondaryMuscleGroup,
                decoration: InputDecoration(
                  labelText: 'Secondary Muscle Group (Optional)',
                  prefixIcon: const Icon(Icons.accessibility_new_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  const DropdownMenuItem<MuscleGroup?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...MuscleGroup.values
                      .where((group) => group != _selectedMuscleGroup)
                      .map((group) {
                    return DropdownMenuItem<MuscleGroup?>(
                      value: group,
                      child: Text(group.displayName),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() => _selectedSecondaryMuscleGroup = value);
                },
              ),
              const SizedBox(height: 16),

              // Equipment type dropdown
              DropdownButtonFormField<EquipmentType>(
                initialValue: _selectedEquipmentType,
                decoration: InputDecoration(
                  labelText: 'Equipment Type',
                  prefixIcon: const Icon(Icons.sports_gymnastics),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: EquipmentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedEquipmentType = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Error message
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isSubmitting ? 'Creating...' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows the create custom exercise dialog and returns the created exercise
Future<void> showCreateCustomExerciseDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => const CreateCustomExerciseDialog(),
  );
}
