/// Template for creating a trainingCycle program
class TrainingCycleTemplate {
  final String id;
  final String name;
  final String description;
  final int periodsTotal;
  final int daysPerPeriod;
  final int? recoveryPeriod;
  final List<WorkoutTemplate> workouts;

  TrainingCycleTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.periodsTotal,
    required this.daysPerPeriod,
    this.recoveryPeriod,
    required this.workouts,
  });

  factory TrainingCycleTemplate.fromJson(Map<String, dynamic> json) {
    return TrainingCycleTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      periodsTotal: json['periodsTotal'] as int,
      daysPerPeriod: json['daysPerPeriod'] as int,
      recoveryPeriod: json['recoveryPeriod'] as int?,
      workouts: (json['workouts'] as List)
          .map((w) => WorkoutTemplate.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'periodsTotal': periodsTotal,
      'daysPerPeriod': daysPerPeriod,
      'recoveryPeriod': recoveryPeriod,
      'workouts': workouts.map((w) => w.toJson()).toList(),
    };
  }
}

/// Template for a single workout within a trainingCycle
class WorkoutTemplate {
  final int periodNumber;
  final int dayNumber;
  final String? dayName;
  final List<ExerciseTemplate> exercises;

  WorkoutTemplate({
    required this.periodNumber,
    required this.dayNumber,
    this.dayName,
    required this.exercises,
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      periodNumber: json['periodNumber'] as int,
      dayNumber: json['dayNumber'] as int,
      dayName: json['dayName'] as String?,
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodNumber': periodNumber,
      'dayNumber': dayNumber,
      'dayName': dayName,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

/// Template for a single exercise within a workout
class ExerciseTemplate {
  final String name;
  final String muscleGroup;
  final String equipmentType;
  final int sets;
  final String reps;
  final String setType;
  final String? notes;

  ExerciseTemplate({
    required this.name,
    required this.muscleGroup,
    required this.equipmentType,
    required this.sets,
    required this.reps,
    this.setType = 'regular',
    this.notes,
  });

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return ExerciseTemplate(
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      equipmentType: json['equipmentType'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as String,
      setType: json['setType'] as String? ?? 'regular',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'equipmentType': equipmentType,
      'sets': sets,
      'reps': reps,
      'setType': setType,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
