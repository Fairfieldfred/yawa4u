import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../data/models/exercise.dart';
import '../../data/models/exercise_set.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/training_cycle_template.dart';
import '../../data/models/workout.dart';
import '../../data/services/analytics_service.dart';
import '../../domain/providers/navigation_providers.dart';
import '../../domain/providers/onboarding_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/template_providers.dart';
import '../../domain/providers/training_cycle_providers.dart';

/// TrainingCycle creation screen with form
class TrainingCycleCreateScreen extends ConsumerStatefulWidget {
  const TrainingCycleCreateScreen({super.key});

  @override
  ConsumerState<TrainingCycleCreateScreen> createState() =>
      _TrainingCycleCreateScreenState();
}

class _TrainingCycleCreateScreenState
    extends ConsumerState<TrainingCycleCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uuid = const Uuid();

  // Form values
  int _weeksTotal = 4;
  int _daysPerWeek = 4;
  int? _deloadWeek;
  RecoveryWeekType _recoveryWeekType = RecoveryWeekType.deload;
  TrainingCycleTemplate? _selectedTemplate;
  bool _hasDeload = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createTrainingCycle() async {
    // Check if name is empty first and show a clear prompt
    if (_nameController.text.trim().isEmpty) {
      final cycleTerm = ref.read(trainingCycleTermProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a name for your $cycleTerm'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(trainingCycleRepositoryProvider);
      final analytics = AnalyticsService();

      // Create trainingCycle
      final trainingCycle = TrainingCycle(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        weeksTotal: _weeksTotal,
        daysPerWeek: _daysPerWeek,
        deloadWeek: _hasDeload ? _deloadWeek : null,
        recoveryWeekType: _recoveryWeekType,
        status: TrainingCycleStatus.draft,
        gender:
            Gender.male, // Default value - will be set from onboarding later
        createdDate: DateTime.now(),
        workouts: _generateWorkouts(),
        muscleGroupPriorities: {},
        templateName: _selectedTemplate?.name,
      );

      // Save to database
      await repository.create(trainingCycle);

      // Invalidate provider to ensure fresh data is loaded
      ref.invalidate(trainingCyclesProvider);

      // Log analytics
      await analytics.logTrainingCycleCreated(
        weeks: _weeksTotal,
        daysPerWeek: _daysPerWeek,
        gender: 'not_specified', // Will be set from onboarding later
        templateName: _selectedTemplate?.name,
      );

      if (mounted) {
        final cycleTerm = ref.read(trainingCycleTermProvider);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$cycleTerm "${trainingCycle.name}" created!'),
            backgroundColor: Colors.green,
          ),
        );

        // Set tab to TrainingCycles (index 1) to show the draft
        ref.read(homeTabIndexProvider.notifier).setTab(HomeTab.trainingCycles);
        // Navigate to HomeScreen
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating trainingCycle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Generate workout templates for the trainingCycle
  /// If a template is selected, uses its exercises; otherwise creates empty workouts
  List<Workout> _generateWorkouts() {
    final workouts = <Workout>[];

    for (int week = 1; week <= _weeksTotal; week++) {
      for (int day = 1; day <= _daysPerWeek; day++) {
        // Find matching template workout if template selected
        WorkoutTemplate? templateWorkout;
        if (_selectedTemplate != null) {
          templateWorkout = _selectedTemplate!.workouts
              .where((w) => w.weekNumber == week && w.dayNumber == day)
              .firstOrNull;
        }

        workouts.add(
          Workout(
            id: _uuid.v4(),
            trainingCycleId: '', // Will be set when trainingCycle is created
            weekNumber: week,
            dayNumber: day,
            dayName: templateWorkout?.dayName,
            status: WorkoutStatus.incomplete,
            exercises: templateWorkout != null
                ? _convertTemplateExercises(templateWorkout.exercises)
                : [],
          ),
        );
      }
    }

    return workouts;
  }

  /// Convert template exercises to actual Exercise objects
  List<Exercise> _convertTemplateExercises(List<ExerciseTemplate> templates) {
    return templates.asMap().entries.map((entry) {
      final index = entry.key;
      final template = entry.value;
      final exerciseId = _uuid.v4();

      return Exercise(
        id: exerciseId,
        workoutId: '', // Will be set when workout is saved
        name: template.name,
        muscleGroup:
            MuscleGroups.parse(template.muscleGroup) ?? MuscleGroup.chest,
        equipmentType:
            EquipmentTypes.parse(template.equipmentType) ??
            EquipmentType.barbell,
        sets: _generateSetsFromTemplate(template),
        orderIndex: index,
      );
    }).toList();
  }

  /// Generate exercise sets from template
  List<ExerciseSet> _generateSetsFromTemplate(ExerciseTemplate template) {
    return List.generate(
      template.sets,
      (index) => ExerciseSet(
        id: _uuid.v4(),
        setNumber: index + 1,
        reps: template.reps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycleTerm = ref.watch(trainingCycleTermProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create $cycleTerm'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Header
            Text(
              'New $cycleTerm',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'A $cycleTerm is a multi-week training program with progressive overload, often followed by a recovery week to allow your body to rest and adapt.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '$cycleTerm Name',
                hintText: 'e.g., Spring 2025 Hypertrophy',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Weeks selector
            _buildSectionHeader('Duration'),
            const SizedBox(height: 12),
            _buildWeeksSelector(),
            const SizedBox(height: 24),

            // Days per week selector
            _buildSectionHeader('Training Frequency'),
            const SizedBox(height: 12),
            _buildDaysPerWeekSelector(),
            const SizedBox(height: 24),

            // Recovery week
            _buildSectionHeader('Recovery Week (Optional)'),
            const SizedBox(height: 12),
            _buildRecoverySwitch(),
            if (_hasDeload) ...[
              const SizedBox(height: 12),
              _buildRecoveryTypeSelector(),
              const SizedBox(height: 12),
              _buildRecoveryWeekSelector(),
            ],
            const SizedBox(height: 24),

            // Template (optional)
            _buildSectionHeader('Template (Optional)'),
            const SizedBox(height: 12),
            _buildTemplateSelector(),
            const SizedBox(height: 32),

            // Create button
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _createTrainingCycle,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSubmitting ? 'Creating...' : 'Create $cycleTerm'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildWeeksSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Weeks',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '$_weeksTotal weeks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _weeksTotal.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              label: '$_weeksTotal weeks',
              onChanged: (value) {
                setState(() {
                  _weeksTotal = value.toInt();
                  // Adjust deload week if needed
                  if (_hasDeload &&
                      _deloadWeek != null &&
                      _deloadWeek! > _weeksTotal) {
                    _deloadWeek = _weeksTotal;
                  }
                });
              },
            ),
            Text(
              'Recommended: 4-6 weeks for hypertrophy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysPerWeekSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Training Days',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '$_daysPerWeek days/week',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _daysPerWeek.toDouble(),
              min: 2,
              max: 7,
              divisions: 5,
              label: '$_daysPerWeek days',
              onChanged: (value) {
                setState(() => _daysPerWeek = value.toInt());
              },
            ),
            Text(
              _getDaysPerWeekDescription(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDaysPerWeekDescription() {
    switch (_daysPerWeek) {
      case 2:
        return 'Minimalist full body split';
      case 3:
        return 'Full body or Push/Pull/Legs split';
      case 4:
        return 'Upper/Lower or Push/Pull/Legs + Upper';
      case 5:
        return 'Push/Pull/Legs/Upper/Lower split';
      case 6:
        return 'Push/Pull/Legs twice per week';
      case 7:
        return 'Daily training (advanced)';
      default:
        return '';
    }
  }

  Widget _buildRecoverySwitch() {
    return Card(
      child: SwitchListTile(
        title: const Text('Include Recovery Week'),
        subtitle: const Text(
          'A lighter week to aid recovery and prevent overtraining',
        ),
        value: _hasDeload,
        onChanged: (value) {
          setState(() {
            _hasDeload = value;
            if (value && _deloadWeek == null) {
              _deloadWeek = _weeksTotal;
            }
          });
        },
      ),
    );
  }

  Widget _buildRecoveryTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recovery Type', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            RadioGroup<RecoveryWeekType>(
              groupValue: _recoveryWeekType,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _recoveryWeekType = value);
                }
              },
              child: Column(
                children: RecoveryWeekType.values.map((type) {
                  return RadioListTile<RecoveryWeekType>(
                    title: Text(type.displayName),
                    subtitle: Text(
                      type.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    value: type,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryWeekSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_recoveryWeekType.displayName} on Week',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Week $_deloadWeek',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _deloadWeek!.toDouble(),
              min: 1,
              max: _weeksTotal.toDouble(),
              divisions: _weeksTotal - 1,
              label: 'Week $_deloadWeek',
              onChanged: (value) {
                setState(() => _deloadWeek = value.toInt());
              },
            ),
            Text(
              'Most people schedule this on the last week',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    final templatesAsync = ref.watch(availableTemplatesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            templatesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Error loading templates: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              data: (templates) =>
                  DropdownButtonFormField<TrainingCycleTemplate?>(
                    initialValue: _selectedTemplate,
                    decoration: const InputDecoration(
                      labelText: 'Choose a Template',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.library_books),
                    ),
                    items: [
                      const DropdownMenuItem<TrainingCycleTemplate?>(
                        value: null,
                        child: Text('None (Custom)'),
                      ),
                      ...templates.map(
                        (template) => DropdownMenuItem<TrainingCycleTemplate?>(
                          value: template,
                          child: Text(template.name),
                        ),
                      ),
                    ],
                    onChanged: (template) {
                      setState(() {
                        _selectedTemplate = template;
                        // Optionally update form values from template
                        if (template != null) {
                          _weeksTotal = template.weeksTotal;
                          _daysPerWeek = template.daysPerWeek;
                          if (template.deloadWeek != null) {
                            _hasDeload = true;
                            _deloadWeek = template.deloadWeek;
                          }
                        }
                      });
                    },
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Templates provide pre-configured workout splits with exercises',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
