import 'dart:convert';

import 'package:flutter/services.dart';

import '../../data/models/exercise.dart';
import '../../data/models/training_cycle.dart';
import '../../data/models/training_cycle_template.dart';
import '../../data/models/workout.dart';

class TemplateExporter {
  /// Converts a TrainingCycle to a JSON string compatible with the template system
  /// and copies it to the clipboard.
  static Future<void> exportToClipboard(TrainingCycle trainingCycle) async {
    final template = _convertTrainingCycleToTemplate(trainingCycle);
    final jsonMap = template.toJson();
    final jsonString = const JsonEncoder.withIndent('    ').convert(jsonMap);

    await Clipboard.setData(ClipboardData(text: jsonString));
  }

  static TrainingCycleTemplate _convertTrainingCycleToTemplate(
    TrainingCycle trainingCycle,
  ) {
    // Sort workouts to ensure they are in order
    final sortedWorkouts = List<Workout>.from(trainingCycle.workouts)
      ..sort((a, b) {
        final periodComp = a.periodNumber.compareTo(b.periodNumber);
        if (periodComp != 0) return periodComp;
        return a.dayNumber.compareTo(b.dayNumber);
      });

    return TrainingCycleTemplate(
      id: trainingCycle.name.toLowerCase().replaceAll(' ', '_'),
      name: trainingCycle.name,
      description: 'Exported from app: ${trainingCycle.name}',
      periodsTotal: trainingCycle.periodsTotal,
      daysPerPeriod: trainingCycle.daysPerPeriod,
      recoveryPeriod: trainingCycle.recoveryPeriod,
      workouts: sortedWorkouts.map(_convertWorkoutToTemplate).toList(),
    );
  }

  static WorkoutTemplate _convertWorkoutToTemplate(Workout workout) {
    return WorkoutTemplate(
      periodNumber: workout.periodNumber,
      dayNumber: workout.dayNumber,
      dayName: workout.dayName,
      exercises: workout.exercises.map(_convertExerciseToTemplate).toList(),
    );
  }

  static ExerciseTemplate _convertExerciseToTemplate(Exercise exercise) {
    // Determine reps from the first set, or default to "8-12"
    String reps = "8-12";
    if (exercise.sets.isNotEmpty) {
      final firstSetReps = exercise.sets.first.reps;
      if (firstSetReps.isNotEmpty) {
        reps = firstSetReps;
      }
    }

    // Determine set type from first set
    String setType = "regular";
    if (exercise.sets.isNotEmpty) {
      setType = exercise.sets.first.setType.name;
    }

    return ExerciseTemplate(
      name: exercise.name,
      muscleGroup: exercise.muscleGroup.name, // Enum to string
      equipmentType: exercise.equipmentType.name, // Enum to string
      sets: exercise.sets.length,
      reps: reps,
      setType: setType,
      notes: exercise.notes,
    );
  }
}
