import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/muscle_groups.dart';
import '../../../data/models/workout.dart';
import '../../../domain/providers/repository_providers.dart';
import '../../screens/add_exercise_screen.dart';

/// Shows a muscle group selector bottom sheet and navigates to AddExerciseScreen.
///
/// This is a shared utility used by workout_screen, exercises_screen,
/// and edit_workout_screen.
///
/// Parameters:
/// - [context]: The BuildContext for showing the bottom sheet
/// - [ref]: The WidgetRef for accessing providers
/// - [workouts]: List of existing workouts for the current day
/// - [trainingCycleId]: The ID of the training cycle
/// - [periodNumber]: The period number for the workout
/// - [dayNumber]: The day number for the workout
/// - [dayName]: Optional day name for the workout
void showAddExerciseDialog({
  required BuildContext context,
  required WidgetRef ref,
  required List<Workout> workouts,
  required String trainingCycleId,
  required int periodNumber,
  required int dayNumber,
  String? dayName,
}) {
  if (workouts.isEmpty && trainingCycleId.isEmpty) return;

  // Create a map of existing muscle groups to their workouts
  final muscleGroupWorkouts = <MuscleGroup, Workout>{};
  for (final workout in workouts) {
    if (workout.exercises.isNotEmpty) {
      final muscleGroup = workout.exercises.first.muscleGroup;
      if (!muscleGroupWorkouts.containsKey(muscleGroup)) {
        muscleGroupWorkouts[muscleGroup] = workout;
      }
    }
  }

  // Show all muscle groups sorted alphabetically
  final allMuscleGroups = MuscleGroup.values.toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => Container(
      height: MediaQuery.of(sheetContext).size.height * 0.8,
      decoration: BoxDecoration(
        color: Theme.of(sheetContext).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Muscle Group',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: allMuscleGroups.length,
                itemBuilder: (listContext, index) {
                  final muscleGroup = allMuscleGroups[index];
                  final existingWorkout = muscleGroupWorkouts[muscleGroup];

                  return ListTile(
                    title: Text(muscleGroup.displayName),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      Navigator.pop(sheetContext);

                      // If workout exists for this muscle group, use it
                      if (existingWorkout != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddExerciseScreen(
                              trainingCycleId: existingWorkout.trainingCycleId,
                              workoutId: existingWorkout.id,
                              initialMuscleGroup: muscleGroup,
                            ),
                          ),
                        );
                      } else {
                        // Create a new workout for this muscle group
                        final newWorkout = Workout(
                          id: const Uuid().v4(),
                          trainingCycleId: trainingCycleId,
                          periodNumber: periodNumber,
                          dayNumber: dayNumber,
                          dayName: dayName,
                          label: muscleGroup.displayName,
                          exercises: [],
                        );

                        // Save the new workout
                        await ref
                            .read(workoutRepositoryProvider)
                            .create(newWorkout);

                        // Navigate to add exercise screen
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AddExerciseScreen(
                                trainingCycleId: newWorkout.trainingCycleId,
                                workoutId: newWorkout.id,
                                initialMuscleGroup: muscleGroup,
                              ),
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Convenience method that extracts workout info and calls showAddExerciseDialog.
///
/// Use this when you have a list of workouts and want to add an exercise.
void showAddExerciseDialogFromWorkouts({
  required BuildContext context,
  required WidgetRef ref,
  required List<Workout> workouts,
}) {
  if (workouts.isEmpty) return;

  final firstWorkout = workouts.first;
  showAddExerciseDialog(
    context: context,
    ref: ref,
    workouts: workouts,
    trainingCycleId: firstWorkout.trainingCycleId,
    periodNumber: firstWorkout.periodNumber,
    dayNumber: firstWorkout.dayNumber,
    dayName: firstWorkout.dayName,
  );
}
