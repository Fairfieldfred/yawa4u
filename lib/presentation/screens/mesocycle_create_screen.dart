import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/enums.dart';
import '../../data/models/mesocycle.dart';
import '../../data/models/workout.dart';
import '../../domain/providers/repository_providers.dart';
import '../../data/services/analytics_service.dart';

/// Mesocycle creation screen with form
class MesocycleCreateScreen extends ConsumerStatefulWidget {
  const MesocycleCreateScreen({super.key});

  @override
  ConsumerState<MesocycleCreateScreen> createState() =>
      _MesocycleCreateScreenState();
}

class _MesocycleCreateScreenState
    extends ConsumerState<MesocycleCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uuid = const Uuid();

  // Form values
  int _weeksTotal = 4;
  int _daysPerWeek = 4;
  int? _deloadWeek;
  Gender _gender = Gender.male;
  String? _templateName;
  bool _hasDeload = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createMesocycle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(mesocycleRepositoryProvider);
      final analytics = AnalyticsService();

      // Create mesocycle
      final mesocycle = Mesocycle(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        weeksTotal: _weeksTotal,
        daysPerWeek: _daysPerWeek,
        deloadWeek: _hasDeload ? _deloadWeek : null,
        status: MesocycleStatus.draft,
        gender: _gender,
        createdDate: DateTime.now(),
        workouts: _generateWorkouts(),
        muscleGroupPriorities: {},
        templateName: _templateName,
      );

      // Save to database
      await repository.create(mesocycle);

      // Log analytics
      await analytics.logMesocycleCreated(
        weeks: _weeksTotal,
        daysPerWeek: _daysPerWeek,
        gender: _gender.toString().split('.').last,
        templateName: _templateName,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mesocycle "${mesocycle.name}" created!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating mesocycle: $e'),
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

  /// Generate workout templates for the mesocycle
  List<Workout> _generateWorkouts() {
    final workouts = <Workout>[];

    for (int week = 1; week <= _weeksTotal; week++) {
      for (int day = 1; day <= _daysPerWeek; day++) {
        workouts.add(
          Workout(
            id: _uuid.v4(),
            mesocycleId: '', // Will be set when mesocycle is created
            weekNumber: week,
            dayNumber: day,
            dayName: _getDayName(day),
            status: WorkoutStatus.incomplete,
            exercises: [],
          ),
        );
      }
    }

    return workouts;
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Push';
      case 2:
        return 'Pull';
      case 3:
        return 'Legs';
      case 4:
        return 'Upper';
      case 5:
        return 'Lower';
      case 6:
        return 'Full Body';
      default:
        return 'Day $day';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Mesocycle'),
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
              'New Training Mesocycle',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'A mesocycle is a multi-week training program with progressive overload',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Mesocycle Name',
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

            // Deload week
            _buildSectionHeader('Deload Week (Optional)'),
            const SizedBox(height: 12),
            _buildDeloadSwitch(),
            if (_hasDeload) ...[
              const SizedBox(height: 12),
              _buildDeloadWeekSelector(),
            ],
            const SizedBox(height: 24),

            // Gender selector
            _buildSectionHeader('Gender'),
            const SizedBox(height: 12),
            _buildGenderSelector(),
            const SizedBox(height: 24),

            // Template (optional)
            _buildSectionHeader('Template (Optional)'),
            const SizedBox(height: 12),
            _buildTemplateSelector(),
            const SizedBox(height: 32),

            // Create button
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _createMesocycle,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSubmitting ? 'Creating...' : 'Create Mesocycle'),
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
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
              min: 3,
              max: 6,
              divisions: 3,
              label: '$_daysPerWeek days',
              onChanged: (value) {
                setState(() => _daysPerWeek = value.toInt());
              },
            ),
            Text(
              _getDaysPerWeekDescription(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDaysPerWeekDescription() {
    switch (_daysPerWeek) {
      case 3:
        return 'Full body or Push/Pull/Legs split';
      case 4:
        return 'Upper/Lower or Push/Pull/Legs + Upper';
      case 5:
        return 'Push/Pull/Legs/Upper/Lower split';
      case 6:
        return 'Push/Pull/Legs twice per week';
      default:
        return '';
    }
  }

  Widget _buildDeloadSwitch() {
    return Card(
      child: SwitchListTile(
        title: const Text('Include Deload Week'),
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

  Widget _buildDeloadWeekSelector() {
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
                  'Deload on Week',
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
              'Most people deload on the last week',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            RadioListTile<Gender>(
              title: const Text('Male'),
              subtitle: const Text('Optimized recovery recommendations'),
              value: Gender.male,
              groupValue: _gender,
              onChanged: (value) {
                if (value != null) setState(() => _gender = value);
              },
            ),
            RadioListTile<Gender>(
              title: const Text('Female'),
              subtitle: const Text('Optimized recovery recommendations'),
              value: Gender.female,
              groupValue: _gender,
              onChanged: (value) {
                if (value != null) setState(() => _gender = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String?>(
              value: _templateName,
              decoration: const InputDecoration(
                labelText: 'Choose a Template',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.library_books),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('None (Custom)'),
                ),
                const DropdownMenuItem(
                  value: 'Push/Pull/Legs',
                  child: Text('Push/Pull/Legs'),
                ),
                const DropdownMenuItem(
                  value: 'Upper/Lower',
                  child: Text('Upper/Lower'),
                ),
                const DropdownMenuItem(
                  value: 'Full Body',
                  child: Text('Full Body'),
                ),
              ],
              onChanged: (value) {
                setState(() => _templateName = value);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Templates provide pre-configured workout splits',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
