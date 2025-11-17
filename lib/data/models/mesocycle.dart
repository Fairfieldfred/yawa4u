import 'package:hive/hive.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/date_helpers.dart';
import 'workout.dart';

part 'mesocycle.g.dart';

/// Represents a mesocycle (multi-week training program)
///
/// Contains mesocycle configuration, workouts, and progression tracking.
@HiveType(typeId: 4)
class Mesocycle {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int weeksTotal;

  @HiveField(3)
  final int daysPerWeek;

  @HiveField(4)
  final int deloadWeek;

  @HiveField(5)
  final MesocycleStatus status;

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

  Mesocycle({
    required this.id,
    required this.name,
    required this.weeksTotal,
    required this.daysPerWeek,
    int? deloadWeek,
    this.status = MesocycleStatus.draft,
    this.gender,
    DateTime? createdDate,
    this.startDate,
    this.endDate,
    List<Workout>? workouts,
    this.muscleGroupPriorities,
    this.templateName,
    this.notes,
  })  : deloadWeek = deloadWeek ?? weeksTotal,
        createdDate = createdDate ?? DateTime.now(),
        workouts = workouts ?? [];

  /// Calculate end date based on start date and weeks
  DateTime? getEndDate() {
    if (startDate == null) return null;
    return DateHelpers.getMesocycleEndDate(startDate!, weeksTotal);
  }

  /// Get current week number (1-based) based on today's date
  int? getCurrentWeek() {
    if (startDate == null) return null;
    final now = DateTime.now();
    if (now.isBefore(startDate!)) return null;

    final endDate = getEndDate();
    if (endDate != null && now.isAfter(endDate)) return null;

    final daysSinceStart = now.difference(startDate!).inDays;
    final weekNumber = (daysSinceStart / 7).floor() + 1;
    return weekNumber.clamp(1, weeksTotal);
  }

  /// Get progress percentage (0.0 to 1.0)
  double getProgress() {
    if (workouts.isEmpty) return 0.0;
    final completedWorkouts =
        workouts.where((w) => w.status == WorkoutStatus.completed).length;
    return completedWorkouts / workouts.length;
  }

  /// Check if mesocycle is active (current status)
  bool get isActive => status == MesocycleStatus.current;

  /// Check if mesocycle is completed
  bool get isCompleted => status == MesocycleStatus.completed;

  /// Check if mesocycle is draft
  bool get isDraft => status == MesocycleStatus.draft;

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

  /// Start the mesocycle
  Mesocycle start({DateTime? date}) {
    return copyWith(
      status: MesocycleStatus.current,
      startDate: date ?? DateTime.now(),
      endDate: getEndDate(),
    );
  }

  /// Complete the mesocycle
  Mesocycle complete() {
    return copyWith(
      status: MesocycleStatus.completed,
    );
  }

  /// Add a workout
  Mesocycle addWorkout(Workout workout) {
    return copyWith(
      workouts: [...workouts, workout],
    );
  }

  /// Update a workout at a specific index
  Mesocycle updateWorkout(int index, Workout workout) {
    if (index < 0 || index >= workouts.length) return this;
    final newWorkouts = List<Workout>.from(workouts);
    newWorkouts[index] = workout;
    return copyWith(workouts: newWorkouts);
  }

  /// Find a workout by week and day
  Workout? getWorkout(int weekNumber, int dayNumber) {
    return workouts.cast<Workout?>().firstWhere(
          (w) => w!.weekNumber == weekNumber && w.dayNumber == dayNumber,
          orElse: () => null,
        );
  }

  /// Get all workouts for a specific week
  List<Workout> getWorkoutsForWeek(int weekNumber) {
    return workouts.where((w) => w.weekNumber == weekNumber).toList()
      ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
  }

  /// Create a copy with updated fields
  Mesocycle copyWith({
    String? id,
    String? name,
    int? weeksTotal,
    int? daysPerWeek,
    int? deloadWeek,
    MesocycleStatus? status,
    Gender? gender,
    DateTime? createdDate,
    DateTime? startDate,
    DateTime? endDate,
    List<Workout>? workouts,
    Map<String, int>? muscleGroupPriorities,
    String? templateName,
    String? notes,
  }) {
    return Mesocycle(
      id: id ?? this.id,
      name: name ?? this.name,
      weeksTotal: weeksTotal ?? this.weeksTotal,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      deloadWeek: deloadWeek ?? this.deloadWeek,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      createdDate: createdDate ?? this.createdDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      workouts: workouts ?? this.workouts,
      muscleGroupPriorities: muscleGroupPriorities ?? this.muscleGroupPriorities,
      templateName: templateName ?? this.templateName,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weeksTotal': weeksTotal,
      'daysPerWeek': daysPerWeek,
      'deloadWeek': deloadWeek,
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
  factory Mesocycle.fromJson(Map<String, dynamic> json) {
    return Mesocycle(
      id: json['id'] as String,
      name: json['name'] as String,
      weeksTotal: json['weeksTotal'] as int,
      daysPerWeek: json['daysPerWeek'] as int,
      deloadWeek: json['deloadWeek'] as int?,
      status: MesocycleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MesocycleStatus.draft,
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
      workouts: (json['workouts'] as List?)
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
    return 'Mesocycle(name: $name, weeks: $weeksTotal, days/week: $daysPerWeek, status: ${status.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Mesocycle &&
        other.id == id &&
        other.name == name &&
        other.weeksTotal == weeksTotal &&
        other.daysPerWeek == daysPerWeek;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      weeksTotal,
      daysPerWeek,
    );
  }
}
