import 'package:intl/intl.dart';

import '../../core/constants/equipment_types.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/workout.dart';
import '../repositories/workout_repository.dart';

/// Provides exercise history lookups for auto-populating weights
/// and showing previous performance inline.
class ExerciseHistoryService {
  final WorkoutRepository _workoutRepository;

  ExerciseHistoryService(this._workoutRepository);

  /// Get the most recent logged performance of an exercise by name,
  /// excluding the exercise with [currentExerciseId].
  ///
  /// Returns null if no previous performance exists.
  Future<Exercise?> getPreviousPerformance(
    String exerciseName,
    String currentExerciseId,
  ) async {
    final allWorkouts = await _workoutRepository.getAll();
    final lowerName = exerciseName.toLowerCase();

    Exercise? mostRecent;
    DateTime? mostRecentDate;

    for (final workout in allWorkouts) {
      for (final exercise in workout.exercises) {
        if (exercise.id == currentExerciseId) continue;
        if (exercise.name.toLowerCase() != lowerName) continue;
        if (!exercise.sets.any((s) => s.isLogged)) continue;

        final date = workout.completedDate ?? exercise.lastPerformed;
        if (date == null) continue;

        if (mostRecentDate == null || date.isAfter(mostRecentDate)) {
          mostRecent = exercise;
          mostRecentDate = date;
        }
      }
    }

    return mostRecent;
  }

  /// Get previous set data (weight + reps) for auto-populating new sets.
  ///
  /// Returns logged sets from the most recent previous performance,
  /// or an empty list if none exists.
  Future<List<ExerciseSet>> getPreviousSets(
    String exerciseName,
    String currentExerciseId,
  ) async {
    final previous = await getPreviousPerformance(
      exerciseName,
      currentExerciseId,
    );
    if (previous == null) return [];
    return previous.sets.where((s) => s.isLogged).toList();
  }

  /// Get the weight to auto-populate for a new set at [setIndex].
  ///
  /// Uses the weight from the same set index in the previous workout,
  /// or falls back to the last set's weight if the index exceeds
  /// the previous set count.
  Future<double?> getAutoPopulateWeight(
    String exerciseName,
    String currentExerciseId,
    int setIndex,
  ) async {
    final previousSets = await getPreviousSets(
      exerciseName,
      currentExerciseId,
    );
    if (previousSets.isEmpty) return null;

    if (setIndex < previousSets.length) {
      return previousSets[setIndex].weight;
    }
    return previousSets.last.weight;
  }

  /// Format a compact summary of an exercise's performance.
  ///
  /// Example: "135 lbs x 8, 10, 12" or "BW+25 x 6, 6"
  String formatPerformanceSummary(Exercise exercise) {
    final loggedSets = exercise.sets.where((s) => s.isLogged).toList();
    if (loggedSets.isEmpty) return '';

    final weights = loggedSets.map((s) => s.weight).toSet();
    final reps = loggedSets.map((s) => s.reps).join(', ');

    if (weights.length == 1) {
      final w = weights.first;
      if (w == null || w == 0) {
        return 'x $reps';
      }
      return '${_formatWeight(w)} x $reps';
    }

    // Multiple weights — show each set individually
    return loggedSets.map((s) {
      final w = s.weight;
      if (w == null || w == 0) return 'x ${s.reps}';
      return '${_formatWeight(w)} x ${s.reps}';
    }).join(', ');
  }

  /// Format the date for display, showing relative text when recent.
  ///
  /// Examples: "today", "yesterday", "3 days ago", "Jan 15"
  String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }
    return DateFormat('MMM d').format(date);
  }

  /// Get the date of the most recent previous performance for an exercise.
  Future<DateTime?> getLastPerformedDate(
    String exerciseName,
    String currentExerciseId,
  ) async {
    final allWorkouts = await _workoutRepository.getAll();
    final lowerName = exerciseName.toLowerCase();
    DateTime? latest;

    for (final workout in allWorkouts) {
      for (final exercise in workout.exercises) {
        if (exercise.id == currentExerciseId) continue;
        if (exercise.name.toLowerCase() != lowerName) continue;
        if (!exercise.sets.any((s) => s.isLogged)) continue;

        final date = workout.completedDate ?? exercise.lastPerformed;
        if (date != null && (latest == null || date.isAfter(latest))) {
          latest = date;
        }
      }
    }

    return latest;
  }

  /// Get the date of the most recent performance for an exercise name
  /// across all workouts (no exclusion). Used for Add Exercise screen.
  Future<DateTime?> getLastPerformedDateForName(String exerciseName) async {
    final allWorkouts = await _workoutRepository.getAll();
    final lowerName = exerciseName.toLowerCase();
    DateTime? latest;

    for (final workout in allWorkouts) {
      for (final exercise in workout.exercises) {
        if (exercise.name.toLowerCase() != lowerName) continue;
        if (!exercise.sets.any((s) => s.isLogged)) continue;

        final date = workout.completedDate ?? exercise.lastPerformed;
        if (date != null && (latest == null || date.isAfter(latest))) {
          latest = date;
        }
      }
    }

    return latest;
  }

  /// Get all history entries for an exercise name, sorted most recent first.
  ///
  /// Each entry contains the exercise and its parent workout.
  /// Used for mini-charts and history displays.
  Future<List<ExerciseHistoryEntry>> getFullHistory(
    String exerciseName,
  ) async {
    final allWorkouts = await _workoutRepository.getAll();
    final lowerName = exerciseName.toLowerCase();
    final entries = <ExerciseHistoryEntry>[];

    for (final workout in allWorkouts) {
      for (final exercise in workout.exercises) {
        if (exercise.name.toLowerCase() != lowerName) continue;
        if (!exercise.sets.any((s) => s.isLogged)) continue;

        entries.add(ExerciseHistoryEntry(
          exercise: exercise,
          workout: workout,
          date: workout.completedDate ?? exercise.lastPerformed,
        ));
      }
    }

    entries.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    return entries;
  }

  /// Whether the user hit all reps in the previous performance.
  ///
  /// Returns true if every logged set has a pure integer reps value
  /// (not a range like "8-12", not RIR like "2 RIR", not empty).
  bool didHitAllReps(Exercise previousExercise) {
    final loggedSets =
        previousExercise.sets.where((s) => s.isLogged).toList();
    if (loggedSets.isEmpty) return false;

    for (final set in loggedSets) {
      final reps = set.reps.trim();
      if (reps.isEmpty) return false;
      if (int.tryParse(reps) == null) return false;
    }
    return true;
  }

  /// Weight increment in lbs based on equipment type.
  ///
  /// Returns null for bodyweight exercises where weight isn't
  /// the primary progression variable.
  double? getWeightIncrement(EquipmentType equipmentType) {
    switch (equipmentType) {
      case EquipmentType.barbell:
      case EquipmentType.smithMachine:
        return 5.0;
      case EquipmentType.dumbbell:
      case EquipmentType.cable:
      case EquipmentType.machine:
      case EquipmentType.kettlebell:
      case EquipmentType.freemotion:
      case EquipmentType.machineAssistance:
        return 2.5;
      case EquipmentType.bodyweightOnly:
      case EquipmentType.bodyweightLoadable:
      case EquipmentType.bandAssistance:
        return null;
    }
  }

  /// Get auto-populate weight with optional increase suggestion.
  ///
  /// If the user hit all reps last time and the equipment supports
  /// weight progression, returns the increased weight.
  Future<({double? weight, bool hasSuggestion})>
      getAutoPopulateWeightWithSuggestion(
    String exerciseName,
    String currentExerciseId,
    int setIndex,
    EquipmentType equipmentType,
  ) async {
    final previous = await getPreviousPerformance(
      exerciseName,
      currentExerciseId,
    );
    if (previous == null) {
      return (weight: null, hasSuggestion: false);
    }

    final previousSets =
        previous.sets.where((s) => s.isLogged).toList();
    if (previousSets.isEmpty) {
      return (weight: null, hasSuggestion: false);
    }

    final baseWeight = setIndex < previousSets.length
        ? previousSets[setIndex].weight
        : previousSets.last.weight;

    if (baseWeight == null) {
      return (weight: null, hasSuggestion: false);
    }

    if (didHitAllReps(previous)) {
      final increment = getWeightIncrement(equipmentType);
      if (increment != null) {
        return (weight: baseWeight + increment, hasSuggestion: true);
      }
    }

    return (weight: baseWeight, hasSuggestion: false);
  }

  String _formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toInt().toString();
    }
    return weight.toString();
  }
}

/// A history entry pairing an exercise with its parent workout.
class ExerciseHistoryEntry {
  final Exercise exercise;
  final Workout workout;
  final DateTime? date;

  /// Max weight across all logged sets
  double get maxWeight {
    final loggedSets = exercise.sets.where((s) => s.isLogged);
    if (loggedSets.isEmpty) return 0;
    return loggedSets.fold<double>(
      0,
      (max, s) => (s.weight ?? 0) > max ? (s.weight ?? 0) : max,
    );
  }

  const ExerciseHistoryEntry({
    required this.exercise,
    required this.workout,
    this.date,
  });
}
