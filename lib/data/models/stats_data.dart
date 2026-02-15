import '../../core/constants/muscle_groups.dart';
import 'workout.dart';

/// Aggregated workout statistics for a training cycle or lifetime.
class WorkoutStats {
  final int totalWorkouts;
  final int completedWorkouts;
  final int skippedWorkouts;
  final double completionRate;
  final Map<MuscleGroup, int> setsByMuscleGroup;
  final Map<String, int> exerciseFrequency;
  final List<VolumeDataPoint> volumeProgression;
  final Map<String, double> personalRecords;
  final int totalSets;

  const WorkoutStats({
    required this.totalWorkouts,
    required this.completedWorkouts,
    required this.skippedWorkouts,
    required this.completionRate,
    required this.setsByMuscleGroup,
    required this.exerciseFrequency,
    required this.volumeProgression,
    required this.personalRecords,
    required this.totalSets,
  });

  /// Build stats from a list of workouts.
  factory WorkoutStats.fromWorkouts(List<Workout> workouts) {
    final completed = workouts.where((w) => w.isCompleted).length;
    final skipped = workouts.where((w) => w.isSkipped).length;
    final total = workouts.length;
    final rate = total > 0 ? completed / total : 0.0;

    // Sets by muscle group
    final setsByGroup = <MuscleGroup, int>{};
    // Exercise frequency
    final frequency = <String, int>{};
    // Personal records (max weight per exercise name)
    final records = <String, double>{};
    // Volume progression (per unique period/day)
    final volumeByDay = <String, VolumeDataPoint>{};
    var totalSetCount = 0;

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        final loggedSets = exercise.sets.where((s) => s.isLogged).toList();
        if (loggedSets.isEmpty) continue;

        // Sets per muscle group
        setsByGroup[exercise.muscleGroup] =
            (setsByGroup[exercise.muscleGroup] ?? 0) + loggedSets.length;
        if (exercise.secondaryMuscleGroup != null) {
          setsByGroup[exercise.secondaryMuscleGroup!] =
              (setsByGroup[exercise.secondaryMuscleGroup!] ?? 0) +
                  loggedSets.length;
        }

        totalSetCount += loggedSets.length;

        // Exercise frequency
        frequency[exercise.name] = (frequency[exercise.name] ?? 0) + 1;

        // Personal records
        for (final set in loggedSets) {
          if (set.weight != null && set.weight! > 0) {
            final current = records[exercise.name] ?? 0;
            if (set.weight! > current) {
              records[exercise.name] = set.weight!;
            }
          }
        }

        // Volume for this workout day
        final dayKey = '${workout.periodNumber}-${workout.dayNumber}';
        double dayVolume = 0;
        for (final set in loggedSets) {
          final weight = set.weight ?? 0;
          // Parse reps — take numeric part only
          final repsNum = _parseReps(set.reps);
          dayVolume += weight * repsNum;
        }

        if (volumeByDay.containsKey(dayKey)) {
          final existing = volumeByDay[dayKey]!;
          volumeByDay[dayKey] = VolumeDataPoint(
            periodNumber: existing.periodNumber,
            dayNumber: existing.dayNumber,
            totalVolume: existing.totalVolume + dayVolume,
            date: workout.completedDate ?? existing.date,
          );
        } else {
          volumeByDay[dayKey] = VolumeDataPoint(
            periodNumber: workout.periodNumber,
            dayNumber: workout.dayNumber,
            totalVolume: dayVolume,
            date: workout.completedDate,
          );
        }
      }
    }

    // Sort volume progression by period then day
    final volumeList = volumeByDay.values.toList()
      ..sort((a, b) {
        final periodCmp = a.periodNumber.compareTo(b.periodNumber);
        if (periodCmp != 0) return periodCmp;
        return a.dayNumber.compareTo(b.dayNumber);
      });

    return WorkoutStats(
      totalWorkouts: total,
      completedWorkouts: completed,
      skippedWorkouts: skipped,
      completionRate: rate,
      setsByMuscleGroup: setsByGroup,
      exerciseFrequency: frequency,
      volumeProgression: volumeList,
      personalRecords: records,
      totalSets: totalSetCount,
    );
  }

  /// Top N most frequent exercises, sorted by count descending.
  List<MapEntry<String, int>> topExercises([int n = 10]) {
    final sorted = exerciseFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }

  /// Top N personal records, sorted by weight descending.
  List<MapEntry<String, double>> topRecords([int n = 10]) {
    final sorted = personalRecords.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }

  static double _parseReps(String reps) {
    final trimmed = reps.trim();
    if (trimmed.isEmpty) return 0;

    // Handle range like "8-12" — take the lower bound
    if (trimmed.contains('-')) {
      final parts = trimmed.split('-');
      return double.tryParse(parts.first.trim()) ?? 0;
    }

    // Handle RIR like "2 RIR" — not a rep count, treat as 0 for volume
    if (trimmed.toUpperCase().contains('RIR')) return 0;

    return double.tryParse(trimmed) ?? 0;
  }
}

/// A single data point for volume progression charts.
class VolumeDataPoint {
  final int periodNumber;
  final int dayNumber;
  final double totalVolume;
  final DateTime? date;

  const VolumeDataPoint({
    required this.periodNumber,
    required this.dayNumber,
    required this.totalVolume,
    this.date,
  });

  /// Label for chart X-axis (e.g., "P1D3")
  String get label => 'P${periodNumber}D$dayNumber';
}
