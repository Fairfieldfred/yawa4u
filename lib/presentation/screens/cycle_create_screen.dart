import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/theme/skins/skins.dart';
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
  int _periodsTotal = 4;
  int _daysPerPeriod = 4;
  int? _recoveryPeriod;
  RecoveryPeriodType _recoveryPeriodType = RecoveryPeriodType.deload;
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
          backgroundColor: context.warningColor,
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
        periodsTotal: _periodsTotal,
        daysPerPeriod: _daysPerPeriod,
        recoveryPeriod: _hasDeload ? _recoveryPeriod : null,
        recoveryPeriodType: _recoveryPeriodType,
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
        periods: _periodsTotal,
        daysPerPeriod: _daysPerPeriod,
        gender: 'not_specified', // Will be set from onboarding later
        templateName: _selectedTemplate?.name,
      );

      if (mounted) {
        final cycleTerm = ref.read(trainingCycleTermProvider);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$cycleTerm "${trainingCycle.name}" created!'),
            backgroundColor: context.successColor,
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
            backgroundColor: context.errorColor,
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

    for (int period = 1; period <= _periodsTotal; period++) {
      for (int day = 1; day <= _daysPerPeriod; day++) {
        // Find matching template workout if template selected
        WorkoutTemplate? templateWorkout;
        if (_selectedTemplate != null) {
          templateWorkout = _selectedTemplate!.workouts
              .where((w) => w.periodNumber == period && w.dayNumber == day)
              .firstOrNull;
        }

        workouts.add(
          Workout(
            id: _uuid.v4(),
            trainingCycleId: '', // Will be set when trainingCycle is created
            periodNumber: period,
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
        notes: template.notes,
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
              'A $cycleTerm is a multi-period training program with progressive overload, often followed by a recovery period to allow your body to rest and adapt.',
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

            // Periods selector
            _buildSectionHeader('Duration'),
            const SizedBox(height: 12),
            _buildPeriodsSelector(),
            const SizedBox(height: 24),

            // Days per period selector
            _buildSectionHeader('Training Frequency'),
            const SizedBox(height: 12),
            _buildDaysPerPeriodSelector(),
            const SizedBox(height: 24),

            // Recovery period
            _buildSectionHeader('Recovery Period (Optional)'),
            const SizedBox(height: 12),
            _buildRecoverySwitch(),
            if (_hasDeload) ...[
              const SizedBox(height: 12),
              _buildRecoveryTypeSelector(),
              const SizedBox(height: 12),
              _buildRecoveryPeriodSelector(),
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

  Widget _buildPeriodsSelector() {
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
                  'Total Periods',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '$_periodsTotal periods',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _periodsTotal.toDouble(),
              min: 1,
              max: 8,
              divisions: 7,
              label: '$_periodsTotal periods',
              onChanged: (value) {
                setState(() {
                  _periodsTotal = value.toInt();
                  // Adjust recovery period if needed
                  if (_hasDeload &&
                      _recoveryPeriod != null &&
                      _recoveryPeriod! > _periodsTotal) {
                    _recoveryPeriod = _periodsTotal;
                  }
                });
              },
            ),
            Text(
              'Recommended: 4-6 periods for hypertrophy',
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

  Widget _buildDaysPerPeriodSelector() {
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
                  '$_daysPerPeriod days/period',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _daysPerPeriod.toDouble(),
              min: 2,
              max: AppConstants.maxDaysPerPeriod.toDouble(),
              divisions: AppConstants.maxDaysPerPeriod - 2,
              label: '$_daysPerPeriod days',
              onChanged: (value) {
                setState(() => _daysPerPeriod = value.toInt());
              },
            ),
            Text(
              _getDaysPerPeriodDescription(),
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

  String _getDaysPerPeriodDescription() {
    switch (_daysPerPeriod) {
      case 2:
        return 'Minimalist full body split';
      case 3:
        return 'Full body or Push/Pull/Legs split';
      case 4:
        return 'Upper/Lower or Push/Pull/Legs + Upper';
      case 5:
        return 'Push/Pull/Legs/Upper/Lower split';
      case 6:
        return 'Push/Pull/Legs twice per period';
      case 7:
        return 'Daily training (7-day cycle)';
      case 8:
        return '8-day training cycle with rest day';
      case 9:
        return '9-day training cycle (e.g., 3-on/1-off)';
      case 10:
        return '10-day training cycle';
      case 11:
        return '11-day training cycle';
      case 12:
        return '12-day training cycle';
      case 13:
        return '13-day training cycle';
      case 14:
        return '14-day (bi-weekly) training cycle';
      default:
        return '$_daysPerPeriod-day training cycle';
    }
  }

  Widget _buildRecoverySwitch() {
    return Card(
      child: SwitchListTile(
        title: const Text('Include Recovery Period'),
        subtitle: const Text(
          'A lighter period to aid recovery and prevent overtraining',
        ),
        value: _hasDeload,
        onChanged: (value) {
          setState(() {
            _hasDeload = value;
            if (value && _recoveryPeriod == null) {
              _recoveryPeriod = _periodsTotal;
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
            RadioGroup<RecoveryPeriodType>(
              groupValue: _recoveryPeriodType,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _recoveryPeriodType = value);
                }
              },
              child: Column(
                children: RecoveryPeriodType.values.map((type) {
                  return RadioListTile<RecoveryPeriodType>(
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

  Widget _buildRecoveryPeriodSelector() {
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
                  '${_recoveryPeriodType.displayName} on Period',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Period $_recoveryPeriod',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: _recoveryPeriod!.toDouble(),
              min: 1,
              max: _periodsTotal.toDouble(),
              divisions: _periodsTotal - 1,
              label: 'Period $_recoveryPeriod',
              onChanged: (value) {
                setState(() => _recoveryPeriod = value.toInt());
              },
            ),
            Text(
              'Most people schedule this on the last period',
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
                          _periodsTotal = template.periodsTotal;
                          _daysPerPeriod = template.daysPerPeriod;
                          if (template.recoveryPeriod != null) {
                            _hasDeload = true;
                            _recoveryPeriod = template.recoveryPeriod;
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
