import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/muscle_groups.dart';
import '../../data/models/mesocycle_template.dart';
import '../../domain/providers/repository_providers.dart';
import '../../domain/providers/template_providers.dart';

class TemplatePreviewScreen extends ConsumerStatefulWidget {
  final MesocycleTemplate template;

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
      // TODO: Get actual user name
      const userName = 'User';

      final repository = ref.read(templateRepositoryProvider);
      final mesocycle = await repository.createMesocycleFromTemplate(
        widget.template,
        userName,
      );

      // Save mesocycle
      final mesocycleRepository = ref.read(mesocycleRepositoryProvider);
      await mesocycleRepository.create(mesocycle);

      // Save workouts and exercises
      final workoutRepository = ref.read(workoutRepositoryProvider);
      final exerciseRepository = ref.read(exerciseRepositoryProvider);

      for (final workout in mesocycle.workouts) {
        await workoutRepository.create(workout);
        for (final exercise in workout.exercises) {
          await exerciseRepository.create(exercise);
        }
      }

      if (mounted) {
        // Navigate to home/list screen
        Navigator.of(context).popUntil((route) => route.isFirst);
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
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: Text(widget.template.name),
        backgroundColor: const Color(0xFF2C2C2E),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Description
                Text(
                  widget.template.description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Program Details
                _buildInfoSection(),
                const SizedBox(height: 24),

                // Workouts
                const Text(
                  'Workouts',
                  style: TextStyle(
                    color: Colors.white,
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
              color: const Color(0xFF2C2C2E),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createProgram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
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
                          'START PROGRAM',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            Icons.calendar_today,
            '${widget.template.weeksTotal} Weeks',
            'Duration',
          ),
          _buildInfoItem(
            Icons.fitness_center,
            '${widget.template.daysPerWeek} Days',
            'Per Week',
          ),
          if (widget.template.deloadWeek != null)
            _buildInfoItem(
              Icons.refresh,
              'Week ${widget.template.deloadWeek}',
              'Deload',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWorkoutCard(WorkoutTemplate workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            workout.dayName ?? 'Day ${workout.dayNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${workout.exercises.length} Exercises',
            style: const TextStyle(color: Colors.white54),
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${exercise.sets} sets × ${exercise.reps}',
                                style: const TextStyle(
                                  color: Colors.white54,
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
