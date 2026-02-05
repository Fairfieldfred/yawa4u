import '../../core/constants/enums.dart';
import 'exercise.dart';

/// Represents a workout session within a trainingCycle
///
/// Contains workout details, exercises, and completion status.
class Workout {
  final String id;
  final String trainingCycleId;
  final int periodNumber;
  final int dayNumber;
  final String? dayName;
  final String? label;
  final WorkoutStatus status;
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final List<Exercise> exercises;
  final String? notes;

  Workout({
    required this.id,
    required this.trainingCycleId,
    required this.periodNumber,
    required this.dayNumber,
    this.dayName,
    this.label,
    this.status = WorkoutStatus.incomplete,
    this.scheduledDate,
    this.completedDate,
    List<Exercise>? exercises,
    this.notes,
  }) : exercises = exercises ?? [];

  /// Check if workout is completed
  bool get isCompleted => status == WorkoutStatus.completed;

  /// Check if workout is skipped
  bool get isSkipped => status == WorkoutStatus.skipped;

  /// Get total number of exercises
  int get totalExercises => exercises.length;

  /// Get number of completed exercises
  int get completedExercises => exercises.where((e) => e.isCompleted).length;

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    if (exercises.isEmpty) return 0.0;
    return completedExercises / totalExercises;
  }

  /// Check if workout has any Myorep sets
  bool get hasMyorepSets {
    return exercises.any((e) => e.hasMyorepSets);
  }

  /// Get display name for the workout
  String get displayName {
    if (label != null && label!.isNotEmpty) return label!;
    if (dayName != null && dayName!.isNotEmpty) return dayName!;
    return 'Day $dayNumber';
  }

  /// Add an exercise to the workout
  Workout addExercise(Exercise exercise) {
    return copyWith(exercises: [...exercises, exercise]);
  }

  /// Remove an exercise by index
  Workout removeExercise(int index) {
    if (index < 0 || index >= exercises.length) return this;
    final newExercises = List<Exercise>.from(exercises);
    newExercises.removeAt(index);
    return copyWith(exercises: newExercises);
  }

  /// Update an exercise at a specific index
  Workout updateExercise(int index, Exercise exercise) {
    if (index < 0 || index >= exercises.length) return this;
    final newExercises = List<Exercise>.from(exercises);
    newExercises[index] = exercise;
    return copyWith(exercises: newExercises);
  }

  /// Reorder exercises
  Workout reorderExercise(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= exercises.length ||
        newIndex < 0 ||
        newIndex >= exercises.length) {
      return this;
    }
    final newExercises = List<Exercise>.from(exercises);
    final exercise = newExercises.removeAt(oldIndex);
    newExercises.insert(newIndex, exercise);
    return copyWith(exercises: newExercises);
  }

  /// Mark workout as completed
  Workout complete() {
    return copyWith(
      status: WorkoutStatus.completed,
      completedDate: DateTime.now(),
    );
  }

  /// Mark workout as skipped
  Workout skip() {
    return copyWith(status: WorkoutStatus.skipped);
  }

  /// Reset workout to incomplete
  Workout reset() {
    return copyWith(status: WorkoutStatus.incomplete, completedDate: null);
  }

  /// Create a copy with updated fields
  ///
  /// Use [clearScheduledDate] to explicitly set scheduledDate to null
  /// (since passing null for scheduledDate will keep the current value)
  Workout copyWith({
    String? id,
    String? trainingCycleId,
    int? periodNumber,
    int? dayNumber,
    String? dayName,
    String? label,
    WorkoutStatus? status,
    DateTime? scheduledDate,
    bool clearScheduledDate = false,
    DateTime? completedDate,
    List<Exercise>? exercises,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      trainingCycleId: trainingCycleId ?? this.trainingCycleId,
      periodNumber: periodNumber ?? this.periodNumber,
      dayNumber: dayNumber ?? this.dayNumber,
      dayName: dayName ?? this.dayName,
      label: label ?? this.label,
      status: status ?? this.status,
      scheduledDate: clearScheduledDate
          ? null
          : (scheduledDate ?? this.scheduledDate),
      completedDate: completedDate ?? this.completedDate,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainingCycleId': trainingCycleId,
      'periodNumber': periodNumber,
      'dayNumber': dayNumber,
      'dayName': dayName,
      'label': label,
      'status': status.name,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  /// Create from JSON for import
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      trainingCycleId: json['trainingCycleId'] as String,
      periodNumber: json['periodNumber'] as int,
      dayNumber: json['dayNumber'] as int,
      dayName: json['dayName'] as String?,
      label: json['label'] as String?,
      status: WorkoutStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => WorkoutStatus.incomplete,
      ),
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : null,
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'Workout(period: $periodNumber, day: $dayNumber, status: ${status.name}, exercises: ${exercises.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Workout &&
        other.id == id &&
        other.trainingCycleId == trainingCycleId &&
        other.periodNumber == periodNumber &&
        other.dayNumber == dayNumber;
  }

  @override
  int get hashCode {
    return Object.hash(id, trainingCycleId, periodNumber, dayNumber);
  }
}
