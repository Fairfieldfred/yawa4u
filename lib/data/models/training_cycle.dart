import 'package:hive/hive.dart';

import '../../core/constants/enums.dart';
import '../../core/utils/date_helpers.dart';
import 'workout.dart';

part 'training_cycle.g.dart';

/// Represents a trainingCycle (multi-period training program)
///
/// Contains trainingCycle configuration, workouts, and progression tracking.
@HiveType(typeId: 104)
class TrainingCycle {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int periodsTotal;

  @HiveField(3)
  final int daysPerPeriod;

  @HiveField(4)
  final int recoveryPeriod;

  @HiveField(5)
  final TrainingCycleStatus status;

  @HiveField(6)
  final Gender? gender;

  @HiveField(7)
  final DateTime createdDate;

  @HiveField(8)
  final DateTime? startDate;

  @HiveField(9)
  final DateTime? endDate;

  @HiveField(10)
  final List<Workout> workouts;

  /// Map of muscle group to priority level (used for template selection)
  @HiveField(11)
  final Map<String, int>? muscleGroupPriorities;

  @HiveField(12)
  final String? templateName;

  @HiveField(13)
  final String? notes;

  @HiveField(14)
  final RecoveryPeriodType? _recoveryPeriodType;

  /// Recovery period type with default fallback for existing records
  RecoveryPeriodType get recoveryPeriodType =>
      _recoveryPeriodType ?? RecoveryPeriodType.deload;

  TrainingCycle({
    required this.id,
    required this.name,
    required this.periodsTotal,
    required this.daysPerPeriod,
    int? recoveryPeriod,
    RecoveryPeriodType? recoveryPeriodType,
    this.status = TrainingCycleStatus.draft,
    this.gender,
    DateTime? createdDate,
    this.startDate,
    this.endDate,
    List<Workout>? workouts,
    this.muscleGroupPriorities,
    this.templateName,
    this.notes,
  }) : _recoveryPeriodType = recoveryPeriodType ?? RecoveryPeriodType.deload,
       recoveryPeriod = recoveryPeriod ?? periodsTotal,
       createdDate = createdDate ?? DateTime.now(),
       workouts = workouts ?? [];

  /// Calculate end date based on start date and periods
  DateTime? getEndDate() {
    if (startDate == null) return null;
    return DateHelpers.getTrainingCycleEndDate(
      startDate!,
      periodsTotal,
      daysPerPeriod,
    );
  }

  /// Get current period number (1-based) based on today's date
  int? getCurrentPeriod() {
    if (startDate == null) return null;
    final now = DateTime.now();
    if (now.isBefore(startDate!)) return null;

    final endDate = getEndDate();
    if (endDate != null && now.isAfter(endDate)) return null;

    final daysSinceStart = now.difference(startDate!).inDays;
    final periodNumber = (daysSinceStart / daysPerPeriod).floor() + 1;
    return periodNumber.clamp(1, periodsTotal);
  }

  /// Get progress percentage (0.0 to 1.0)
  double getProgress() {
    if (workouts.isEmpty) return 0.0;
    final completedWorkouts = workouts
        .where((w) => w.status == WorkoutStatus.completed)
        .length;
    return completedWorkouts / workouts.length;
  }

  /// Check if trainingCycle is active (current status)
  bool get isActive => status == TrainingCycleStatus.current;

  /// Check if trainingCycle is completed
  bool get isCompleted => status == TrainingCycleStatus.completed;

  /// Check if trainingCycle is draft
  bool get isDraft => status == TrainingCycleStatus.draft;

  /// Get total number of workouts completed
  int get completedWorkoutCount {
    return workouts.where((w) => w.status == WorkoutStatus.completed).length;
  }

  /// Get total number of workouts skipped
  int get skippedWorkoutCount {
    return workouts.where((w) => w.status == WorkoutStatus.skipped).length;
  }

  /// Get total number of workouts
  int get totalWorkoutCount => workouts.length;

  /// Start the trainingCycle
  TrainingCycle start({DateTime? date}) {
    return copyWith(
      status: TrainingCycleStatus.current,
      startDate: date ?? DateTime.now(),
      endDate: getEndDate(),
    );
  }

  /// Complete the trainingCycle
  TrainingCycle complete() {
    return copyWith(status: TrainingCycleStatus.completed);
  }

  /// Add a workout
  TrainingCycle addWorkout(Workout workout) {
    return copyWith(workouts: [...workouts, workout]);
  }

  /// Update a workout at a specific index
  TrainingCycle updateWorkout(int index, Workout workout) {
    if (index < 0 || index >= workouts.length) return this;
    final newWorkouts = List<Workout>.from(workouts);
    newWorkouts[index] = workout;
    return copyWith(workouts: newWorkouts);
  }

  /// Find a workout by period and day
  Workout? getWorkout(int periodNumber, int dayNumber) {
    return workouts.cast<Workout?>().firstWhere(
      (w) => w!.periodNumber == periodNumber && w.dayNumber == dayNumber,
      orElse: () => null,
    );
  }

  /// Get all workouts for a specific period
  List<Workout> getWorkoutsForPeriod(int periodNumber) {
    return workouts.where((w) => w.periodNumber == periodNumber).toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
  }

  /// Create a copy with updated fields
  TrainingCycle copyWith({
    String? id,
    String? name,
    int? periodsTotal,
    int? daysPerPeriod,
    int? recoveryPeriod,
    RecoveryPeriodType? recoveryPeriodType,
    TrainingCycleStatus? status,
    Gender? gender,
    DateTime? createdDate,
    DateTime? startDate,
    DateTime? endDate,
    List<Workout>? workouts,
    Map<String, int>? muscleGroupPriorities,
    String? templateName,
    String? notes,
  }) {
    return TrainingCycle(
      id: id ?? this.id,
      name: name ?? this.name,
      periodsTotal: periodsTotal ?? this.periodsTotal,
      daysPerPeriod: daysPerPeriod ?? this.daysPerPeriod,
      recoveryPeriod: recoveryPeriod ?? this.recoveryPeriod,
      recoveryPeriodType: recoveryPeriodType ?? this.recoveryPeriodType,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      createdDate: createdDate ?? this.createdDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      workouts: workouts ?? this.workouts,
      muscleGroupPriorities:
          muscleGroupPriorities ?? this.muscleGroupPriorities,
      templateName: templateName ?? this.templateName,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'periodsTotal': periodsTotal,
      'daysPerPeriod': daysPerPeriod,
      'recoveryPeriod': recoveryPeriod,
      'recoveryPeriodType': recoveryPeriodType.name,
      'status': status.name,
      'gender': gender?.name,
      'createdDate': createdDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'workouts': workouts.map((w) => w.toJson()).toList(),
      'muscleGroupPriorities': muscleGroupPriorities,
      'templateName': templateName,
      'notes': notes,
    };
  }

  /// Create from JSON for import
  factory TrainingCycle.fromJson(Map<String, dynamic> json) {
    return TrainingCycle(
      id: json['id'] as String,
      name: json['name'] as String,
      periodsTotal: json['periodsTotal'] as int,
      daysPerPeriod: json['daysPerPeriod'] as int,
      recoveryPeriod: json['recoveryPeriod'] as int?,
      recoveryPeriodType: json['recoveryPeriodType'] != null
          ? RecoveryPeriodType.values.firstWhere(
              (e) => e.name == json['recoveryPeriodType'],
              orElse: () => RecoveryPeriodType.deload,
            )
          : RecoveryPeriodType.deload,
      status: TrainingCycleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TrainingCycleStatus.draft,
      ),
      gender: json['gender'] != null
          ? Gender.values.firstWhere(
              (e) => e.name == json['gender'],
              orElse: () => Gender.male,
            )
          : null,
      createdDate: DateTime.parse(json['createdDate'] as String),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      workouts:
          (json['workouts'] as List?)
              ?.map((w) => Workout.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      muscleGroupPriorities:
          (json['muscleGroupPriorities'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ),
      templateName: json['templateName'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  String toString() {
    return 'TrainingCycle(name: $name, periods: $periodsTotal, days/period: $daysPerPeriod, status: ${status.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainingCycle &&
        other.id == id &&
        other.name == name &&
        other.periodsTotal == periodsTotal &&
        other.daysPerPeriod == daysPerPeriod;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, periodsTotal, daysPerPeriod);
  }
}
