/// Template for creating a trainingCycle program
class TrainingCycleTemplate {
  final String id;
  final String name;
  final String description;
  final int weeksTotal;
  final int daysPerWeek;
  final int? deloadWeek;
  final List<WorkoutTemplate> workouts;

  TrainingCycleTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.weeksTotal,
    required this.daysPerWeek,
    this.deloadWeek,
    required this.workouts,
  });

  factory TrainingCycleTemplate.fromJson(Map<String, dynamic> json) {
    return TrainingCycleTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      weeksTotal: json['weeksTotal'] as int,
      daysPerWeek: json['daysPerWeek'] as int,
      deloadWeek: json['deloadWeek'] as int?,
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
      'weeksTotal': weeksTotal,
      'daysPerWeek': daysPerWeek,
      'deloadWeek': deloadWeek,
      'workouts': workouts.map((w) => w.toJson()).toList(),
    };
  }
}

/// Template for a single workout within a trainingCycle
class WorkoutTemplate {
  final int weekNumber;
  final int dayNumber;
  final String? dayName;
  final List<ExerciseTemplate> exercises;

  WorkoutTemplate({
    required this.weekNumber,
    required this.dayNumber,
    this.dayName,
    required this.exercises,
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      weekNumber: json['weekNumber'] as int,
      dayNumber: json['dayNumber'] as int,
      dayName: json['dayName'] as String?,
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekNumber': weekNumber,
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

  ExerciseTemplate({
    required this.name,
    required this.muscleGroup,
    required this.equipmentType,
    required this.sets,
    required this.reps,
    this.setType = 'regular',
  });

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return ExerciseTemplate(
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      equipmentType: json['equipmentType'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as String,
      setType: json['setType'] as String? ?? 'regular',
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
    };
  }
}
