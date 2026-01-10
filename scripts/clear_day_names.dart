import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yawa4u/data/models/workout.dart';

/// Script to clear all preset dayNames from existing workouts
/// This allows day names to be calculated dynamically from the trainingCycle start date
Future<void> clearWorkoutDayNames() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters if needed (adjust based on your actual adapter registration)
  // Hive.registerAdapter(WorkoutAdapter());
  // ... register other adapters as needed

  // Open workouts box
  final box = await Hive.openBox<Workout>('workouts');

  debugPrint('Found ${box.length} workouts in database');

  int updatedCount = 0;

  // Iterate through all workouts
  for (var key in box.keys) {
    final workout = box.get(key);
    if (workout != null && workout.dayName != null) {
      // Clear the dayName by creating a copy without it
      final updatedWorkout = workout.copyWith(dayName: null);
      await box.put(key, updatedWorkout);
      updatedCount++;
      debugPrint(
        'Cleared dayName from workout: Week ${workout.periodNumber}, Day ${workout.dayNumber} (was: "${workout.dayName}")',
      );
    }
  }

  debugPrint('\nCompleted! Cleared dayName from $updatedCount workouts.');
  debugPrint(
    'Day names will now be calculated dynamically from trainingCycle start dates.',
  );

  await box.close();
}

void main() async {
  await clearWorkoutDayNames();
}
