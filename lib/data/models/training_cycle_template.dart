/// Template for creating a trainingCycle program.
///
/// v6 added [primarySport] — a UI hint used when instantiating the
/// resulting [TrainingCycle]. Optional; null-safe via "strength" default
/// behavior at the call site.
class TrainingCycleTemplate {
  final String id;
  final String name;
  final String description;
  final int periodsTotal;
  final int daysPerPeriod;
  final int? recoveryPeriod;
  final String? primarySport;
  final List<WorkoutTemplate> workouts;

  TrainingCycleTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.periodsTotal,
    required this.daysPerPeriod,
    this.recoveryPeriod,
    this.primarySport,
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
      primarySport: json['primarySport'] as String?,
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
      if (primarySport != null) 'primarySport': primarySport,
      'workouts': workouts.map((w) => w.toJson()).toList(),
    };
  }
}

/// Template for a single workout within a trainingCycle.
///
/// v6 additions:
/// - [sport] — string name of the sport this day represents. Defaults to
///   `"strength"` for back-compat with v5 templates.
/// - [cardioTemplateId] — for non-strength days, the id of a cardio
///   session template under `assets/cardio_sessions/`. The template
///   loader resolves this into a real [CardioSession] when the cycle is
///   instantiated.
class WorkoutTemplate {
  final int periodNumber;
  final int dayNumber;
  final String? dayName;
  final String sport;
  final String? cardioTemplateId;
  final String? notes;
  final List<ExerciseTemplate> exercises;

  WorkoutTemplate({
    required this.periodNumber,
    required this.dayNumber,
    this.dayName,
    this.sport = 'strength',
    this.cardioTemplateId,
    this.notes,
    this.exercises = const [],
  });

  bool get isCardio => sport != 'strength';

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      periodNumber: json['periodNumber'] as int,
      dayNumber: json['dayNumber'] as int,
      dayName: json['dayName'] as String?,
      sport: (json['sport'] as String?) ?? 'strength',
      cardioTemplateId: json['cardioTemplateId'] as String?,
      notes: json['notes'] as String?,
      exercises: (json['exercises'] as List?)
              ?.map((e) => ExerciseTemplate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'periodNumber': periodNumber,
      'dayNumber': dayNumber,
      'dayName': dayName,
      'sport': sport,
      if (cardioTemplateId != null) 'cardioTemplateId': cardioTemplateId,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
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
