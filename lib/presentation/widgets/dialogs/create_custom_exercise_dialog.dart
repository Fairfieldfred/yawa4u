import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/equipment_types.dart';
import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/custom_exercise_definition.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/exercise_providers.dart';
import '../../../l10n/app_localizations.dart';

/// Dialog for creating a new custom exercise
class CreateCustomExerciseDialog extends ConsumerStatefulWidget {
  const CreateCustomExerciseDialog({super.key});

  @override
  ConsumerState<CreateCustomExerciseDialog> createState() => _CreateCustomExerciseDialogState();
}

class _CreateCustomExerciseDialogState extends ConsumerState<CreateCustomExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  MuscleGroup _selectedMuscleGroup = MuscleGroup.chest;
  MuscleGroup? _selectedSecondaryMuscleGroup;
  EquipmentType _selectedEquipmentType = EquipmentType.barbell;
  final _restSecondsController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _restSecondsController.dispose();
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
      error: (_, _) => false,
    );
    if (exists) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.exerciseNameExists;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final restSeconds = _restSecondsController.text.trim().isNotEmpty
          ? int.tryParse(_restSecondsController.text.trim())
          : null;

      final customExercise = CustomExerciseDefinition(
        id: const Uuid().v4(),
        name: name,
        muscleGroup: _selectedMuscleGroup,
        secondaryMuscleGroup: _selectedSecondaryMuscleGroup,
        equipmentType: _selectedEquipmentType,
        restSeconds: restSeconds,
      );

      final repository = ref.read(customExerciseRepositoryProvider);
      await repository.add(customExercise);

      if (mounted) {
        Navigator.of(context).pop(customExercise.toExerciseDefinition());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.failedToCreateExercise(e);
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.createCustomExerciseTitle,
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

              // Scrollable form fields
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Exercise name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.exerciseNameLabel,
                          hintText: l10n.exerciseNameHint,
                          prefixIcon: const Icon(Icons.fitness_center),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        autofocus: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.exerciseNameRequired;
                          }
                          if (value.trim().length < 3) {
                            return l10n.exerciseNameMinLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Muscle group dropdown
                      DropdownButtonFormField<MuscleGroup>(
                        initialValue: _selectedMuscleGroup,
                        decoration: InputDecoration(
                          labelText: l10n.muscleGroupLabel,
                          prefixIcon: const Icon(Icons.accessibility_new),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: MuscleGroup.values.map((group) {
                          return DropdownMenuItem(
                            value: group,
                            child: Text(group.localizedName(l10n)),
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
                          labelText: l10n.secondaryMuscleGroupLabel,
                          prefixIcon: const Icon(Icons.accessibility_new_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: [
                          DropdownMenuItem<MuscleGroup?>(
                            value: null,
                            child: Text(l10n.secondaryMuscleGroupNone),
                          ),
                          ...MuscleGroup.values.where((group) => group != _selectedMuscleGroup).map((group) {
                            return DropdownMenuItem<MuscleGroup?>(
                              value: group,
                              child: Text(group.localizedName(l10n)),
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
                          labelText: l10n.equipmentTypeLabel,
                          prefixIcon: const Icon(Icons.sports_gymnastics),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: EquipmentType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.localizedName(l10n)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedEquipmentType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Rest timer (optional)
                      TextFormField(
                        controller: _restSecondsController,
                        decoration: InputDecoration(
                          labelText: l10n.restTimerOptionalLabel,
                          hintText: l10n.restTimerHint,
                          suffixText: l10n.restTimerSuffix,
                          prefixIcon: const Icon(Icons.timer),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        keyboardAppearance: Brightness.light,
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final parsed = int.tryParse(value.trim());
                            if (parsed == null || parsed < 0 || parsed > 600) {
                              return l10n.restTimerValidation;
                            }
                          }
                          return null;
                        },
                      ),

                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons (fixed at bottom)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
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
                    label: Text(_isSubmitting ? l10n.creatingButton : l10n.createButton),
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
