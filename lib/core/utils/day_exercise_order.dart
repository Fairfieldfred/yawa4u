import '../../data/models/exercise.dart';
import '../../data/models/workout.dart';

/// A training day's strength exercises in display order.
///
/// A day stores one [Workout] per muscle group, but `Exercise.orderIndex` is a position within the whole
/// day — so a template that alternates muscle groups (Chest, Back, Chest, …) keeps that sequence.
///
/// Days written before day-wide numbering carry per-workout indices (0, 1, … in each workout) that
/// collide across workouts; those keep the legacy workout-by-workout order until a reorder renumbers
/// them via [renumberDayExercises].
List<Exercise> orderedDayExercises(Iterable<Workout> dayWorkouts) {
  final flattened = [for (final workout in dayWorkouts) ...workout.exercises];
  final distinctIndices = flattened.map((e) => e.orderIndex).toSet();
  if (distinctIndices.length != flattened.length) return flattened;
  return flattened..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
}

/// The next free day-wide `orderIndex` after every exercise in [dayWorkouts], for appending.
int nextDayOrderIndex(Iterable<Workout> dayWorkouts, {String? excludingExerciseId}) {
  var next = 0;
  for (final workout in dayWorkouts) {
    for (final exercise in workout.exercises) {
      if (exercise.id == excludingExerciseId) continue;
      if (exercise.orderIndex >= next) next = exercise.orderIndex + 1;
    }
  }
  return next;
}

/// [ordered] with [exerciseId] swapped with its neighbour — [offset] -1 moves it up, +1 down.
///
/// Returns null when the exercise is missing or already at that end of the day.
List<Exercise>? moveDayExercise(List<Exercise> ordered, String exerciseId, int offset) {
  final from = ordered.indexWhere((e) => e.id == exerciseId);
  final to = from + offset;
  if (from == -1 || to < 0 || to >= ordered.length) return null;
  final moved = [...ordered];
  moved.insert(to, moved.removeAt(from));
  return moved;
}

/// [dayWorkouts] with every exercise's `orderIndex` set to its position in [ordered].
///
/// Exercises stay in their own workout. Only workouts whose exercises changed are returned, so callers
/// can persist just those.
List<Workout> renumberDayExercises(Iterable<Workout> dayWorkouts, List<Exercise> ordered) {
  final position = {for (var i = 0; i < ordered.length; i++) ordered[i].id: i};
  final changed = <Workout>[];
  for (final workout in dayWorkouts) {
    final renumbered = [
      for (final exercise in workout.exercises) exercise.copyWith(orderIndex: position[exercise.id]),
    ]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final isUnchanged = [
      for (var i = 0; i < renumbered.length; i++)
        renumbered[i].id == workout.exercises[i].id && renumbered[i].orderIndex == workout.exercises[i].orderIndex,
    ].every((same) => same);
    if (!isUnchanged) changed.add(workout.copyWith(exercises: renumbered));
  }
  return changed;
}
