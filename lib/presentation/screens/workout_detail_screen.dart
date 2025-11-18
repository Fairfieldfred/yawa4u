import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/workout.dart';
import '../../data/models/exercise.dart';
import '../../domain/providers/workout_providers.dart';
import '../../domain/providers/mesocycle_providers.dart';
import '../../domain/providers/repository_providers.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/constants/equipment_types.dart';

/// Workout detail screen showing exercises and set logging
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
    final mesocyclesAsync = ref.watch(mesocyclesProvider);

    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('Workout not found')),
      );
    }

    return mesocyclesAsync.when(
      data: (mesocycles) {
        final mesocycle = mesocycles.firstWhere(
          (m) => m.id == widget.mesocycleId,
          orElse: () => mesocycles.first,
        );

        return Scaffold(
          backgroundColor: const Color(0xFF1C1C1E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1C1C1E),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mesocycle.name.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'WEEK ${workout.weekNumber} DAY ${workout.dayNumber} ${_getDayName(workout.dayNumber)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: workout.exercises.isEmpty
              ? const Center(
                  child: Text(
                    'No exercises',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _getExerciseGroupCount(workout.exercises),
                  itemBuilder: (context, index) {
                    return _buildExerciseGroup(
                      context,
                      workout,
                      _getExerciseAtIndex(workout.exercises, index),
                    );
                  },
                ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  int _getExerciseGroupCount(List<Exercise> exercises) {
    return exercises.length;
  }

  Exercise _getExerciseAtIndex(List<Exercise> exercises, int index) {
    return exercises[index];
  }

  String _getDayName(int dayNumber) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    if (dayNumber >= 1 && dayNumber <= days.length) {
      return days[dayNumber - 1];
    }
    return 'Day $dayNumber';
  }

  Widget _buildExerciseGroup(
    BuildContext context,
    Workout workout,
    Exercise exercise,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Muscle group badge
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getMuscleGroupColor(exercise.muscleGroup),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  exercise.muscleGroup.displayName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Exercise card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.equipmentType.displayName.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF8E8E93),
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF8E8E93),
                      ),
                      onPressed: () {
                        _showExerciseMenu(context, workout, exercise);
                      },
                    ),
                  ],
                ),
              ),

              // Set headers and rows
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    // Headers
                    Row(
                      children: [
                        const SizedBox(width: 32),
                        Expanded(
                          child: Text(
                            'WEIGHT',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'REPS',
                                style: TextStyle(
                                  color: Color(0xFF8E8E93),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Color(0xFF8E8E93),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 60,
                          child: Text(
                            'LOG',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Set rows
                    ...List.generate(
                      exercise.sets.isEmpty ? 4 : exercise.sets.length,
                      (setIndex) => _buildSetRow(
                        context,
                        workout,
                        exercise,
                        setIndex,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetRow(
    BuildContext context,
    Workout workout,
    Exercise exercise,
    int setIndex,
  ) {
    final set = setIndex < exercise.sets.length ? exercise.sets[setIndex] : null;
    final isLast = setIndex == 3 || (exercise.sets.isNotEmpty && setIndex == exercise.sets.length - 1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Drag handle
          const Icon(
            Icons.drag_indicator,
            color: Color(0xFF8E8E93),
            size: 20,
          ),
          const SizedBox(width: 12),

          // Weight field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF3A3A3C),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  set?.weight?.toInt().toString() ?? '105',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Reps field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF3A3A3C),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  isLast ? '1 RIR' : (set?.reps.toString() ?? '8'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Log checkbox
          SizedBox(
            width: 60,
            child: Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: setIndex == 0
                      ? const Color(0xFF30D158)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: setIndex == 0
                        ? const Color(0xFF30D158)
                        : const Color(0xFF3A3A3C),
                    width: 2,
                  ),
                ),
                child: setIndex == 0
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMuscleGroupColor(MuscleGroup muscleGroup) {
    switch (muscleGroup) {
      case MuscleGroup.shoulders:
        return const Color(0xFFD946A6); // Pink/Magenta
      case MuscleGroup.chest:
      case MuscleGroup.triceps:
        return const Color(0xFFE91E63);
      case MuscleGroup.back:
      case MuscleGroup.biceps:
        return const Color(0xFF00BCD4); // Cyan
      case MuscleGroup.quads:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
        return const Color(0xFF009688); // Teal
      default:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  void _showExerciseMenu(
    BuildContext context,
    Workout workout,
    Exercise exercise,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Exercise',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                GoRouter.of(context).pop();
                _deleteExercise(context, workout, exercise);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_vert, color: Colors.white),
              title: const Text(
                'Reorder',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                GoRouter.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.white54),
              title: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
              onTap: () => GoRouter.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteExercise(
    BuildContext context,
    Workout workout,
    Exercise exercise,
  ) {
    final index =
        workout.exercises.indexWhere((e) => e.id == exercise.id);
    if (index == -1) return;

    final updatedWorkout = workout.removeExercise(index);
    ref.read(workoutRepositoryProvider).update(updatedWorkout);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exercise deleted')),
    );
  }
}
