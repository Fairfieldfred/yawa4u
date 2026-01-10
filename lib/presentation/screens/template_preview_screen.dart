import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/muscle_groups.dart';
import '../../data/models/training_cycle_template.dart';
import '../../domain/providers/navigation_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/template_providers.dart';
import '../../domain/providers/training_cycle_providers.dart';
import '../../domain/providers/workout_providers.dart';

class TemplatePreviewScreen extends ConsumerStatefulWidget {
  final TrainingCycleTemplate template;

  const TemplatePreviewScreen({super.key, required this.template});

  @override
  ConsumerState<TemplatePreviewScreen> createState() =>
      _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends ConsumerState<TemplatePreviewScreen> {
  bool _isLoading = false;

  Future<void> _createProgram() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(templateRepositoryProvider);
      final trainingCycle = await repository.createTrainingCycleFromTemplate(
        widget.template,
      );

      // Save trainingCycle
      final trainingCycleRepository = ref.read(trainingCycleRepositoryProvider);
      await trainingCycleRepository.create(trainingCycle);

      // Save workouts and exercises
      final workoutRepository = ref.read(workoutRepositoryProvider);
      final exerciseRepository = ref.read(exerciseRepositoryProvider);

      for (final workout in trainingCycle.workouts) {
        await workoutRepository.create(workout);
        for (final exercise in workout.exercises) {
          await exerciseRepository.create(exercise);
        }
      }

      // Invalidate providers to ensure fresh data is loaded
      ref.invalidate(trainingCyclesProvider);
      ref.invalidate(workoutsProvider);

      if (mounted) {
        // Set tab to TrainingCycles (index 1) to show the draft
        ref.read(homeTabIndexProvider.notifier).setTab(HomeTab.trainingCycles);
        // Navigate to home
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating program: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.template.name), elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Description
                Text(
                  widget.template.description,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Program Details
                _buildInfoSection(),
                const SizedBox(height: 24),

                // Workouts
                Text(
                  'Workouts',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...widget.template.workouts.map(
                  (workout) => _buildWorkoutCard(workout),
                ),
              ],
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createProgram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'LOAD PROGRAM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            Icons.calendar_today,
            '${widget.template.periodsTotal} Periods',
            'Duration',
          ),
          _buildInfoItem(
            Icons.fitness_center,
            '${widget.template.daysPerPeriod} Days',
            'Per Period',
          ),
          if (widget.template.recoveryPeriod != null)
            _buildInfoItem(
              Icons.refresh,
              'Period ${widget.template.recoveryPeriod}',
              'Recovery',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(WorkoutTemplate workout) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            workout.dayName ?? 'Day ${workout.dayNumber}',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${workout.exercises.length} Exercises',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: workout.exercises.map((exercise) {
                  final muscleGroup = MuscleGroup.values.firstWhere(
                    (m) => m.name == exercise.muscleGroup.toLowerCase(),
                    orElse: () => MuscleGroup.chest,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: muscleGroup.color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${exercise.sets} sets × ${exercise.reps}',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
