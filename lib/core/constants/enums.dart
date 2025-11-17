/// Status of a mesocycle
enum MesocycleStatus {
  draft,
  current,
  completed,
}

extension MesocycleStatusExtension on MesocycleStatus {
  String get displayName {
    switch (this) {
      case MesocycleStatus.draft:
        return 'Draft';
      case MesocycleStatus.current:
        return 'Current';
      case MesocycleStatus.completed:
        return 'Completed';
    }
  }

  bool get isDraft => this == MesocycleStatus.draft;
  bool get isCurrent => this == MesocycleStatus.current;
  bool get isCompleted => this == MesocycleStatus.completed;
}

/// Status of a workout
enum WorkoutStatus {
  incomplete,
  completed,
  skipped,
}

extension WorkoutStatusExtension on WorkoutStatus {
  String get displayName {
    switch (this) {
      case WorkoutStatus.incomplete:
        return 'Incomplete';
      case WorkoutStatus.completed:
        return 'Completed';
      case WorkoutStatus.skipped:
        return 'Skipped';
    }
  }

  bool get isIncomplete => this == WorkoutStatus.incomplete;
  bool get isCompleted => this == WorkoutStatus.completed;
  bool get isSkipped => this == WorkoutStatus.skipped;
}

/// Type of exercise set
enum SetType {
  regular,
  myorep,
  myorepMatch,
}

extension SetTypeExtension on SetType {
  String get displayName {
    switch (this) {
      case SetType.regular:
        return 'Regular';
      case SetType.myorep:
        return 'Myorep';
      case SetType.myorepMatch:
        return 'Myorep match';
    }
  }

  String get description {
    switch (this) {
      case SetType.regular:
        return 'perform sets normally by hitting rep target or week over week RIR target';
      case SetType.myorep:
        return 'take 5-15 second pauses between mini-sets of reps to hit rep target or week over week RIR target. Log total reps.';
      case SetType.myorepMatch:
        return 'take 5-15 second pauses between mini-sets of reps to match reps from your first set. Log total reps.';
    }
  }

  /// Badge to show on set row (null for regular)
  String? get badge {
    switch (this) {
      case SetType.regular:
        return null;
      case SetType.myorep:
        return 'M';
      case SetType.myorepMatch:
        return 'MM';
    }
  }

  bool get isRegular => this == SetType.regular;
  bool get isMyorep => this == SetType.myorep;
  bool get isMyorepMatch => this == SetType.myorepMatch;
}

/// Joint pain level feedback
enum JointPain {
  none,
  low,
  moderate,
  severe,
}

extension JointPainExtension on JointPain {
  String get displayName {
    switch (this) {
      case JointPain.none:
        return 'NONE';
      case JointPain.low:
        return 'LOW PAIN';
      case JointPain.moderate:
        return 'MODERATE PAIN';
      case JointPain.severe:
        return 'A LOT OF PAIN';
    }
  }

  int get severity {
    switch (this) {
      case JointPain.none:
        return 0;
      case JointPain.low:
        return 1;
      case JointPain.moderate:
        return 2;
      case JointPain.severe:
        return 3;
    }
  }
}

/// Muscle pump level feedback
enum MusclePump {
  low,
  moderate,
  amazing,
}

extension MusclePumpExtension on MusclePump {
  String get displayName {
    switch (this) {
      case MusclePump.low:
        return 'LOW PUMP';
      case MusclePump.moderate:
        return 'MODERATE PUMP';
      case MusclePump.amazing:
        return 'AMAZING PUMP';
    }
  }

  int get level {
    switch (this) {
      case MusclePump.low:
        return 1;
      case MusclePump.moderate:
        return 2;
      case MusclePump.amazing:
        return 3;
    }
  }
}

/// Workload difficulty feedback
enum Workload {
  easy,
  prettyGood,
  pushedLimits,
  tooMuch,
}

extension WorkloadExtension on Workload {
  String get displayName {
    switch (this) {
      case Workload.easy:
        return 'EASY';
      case Workload.prettyGood:
        return 'PRETTY GOOD';
      case Workload.pushedLimits:
        return 'PUSHED MY LIMITS';
      case Workload.tooMuch:
        return 'TOO MUCH';
    }
  }

  int get difficulty {
    switch (this) {
      case Workload.easy:
        return 1;
      case Workload.prettyGood:
        return 2;
      case Workload.pushedLimits:
        return 3;
      case Workload.tooMuch:
        return 4;
    }
  }
}

/// Muscle soreness level feedback
enum Soreness {
  neverGotSore,
  healedAWhileAgo,
  healedJustOnTime,
  stillSore,
}

extension SorenessExtension on Soreness {
  String get displayName {
    switch (this) {
      case Soreness.neverGotSore:
        return 'NEVER GOT SORE';
      case Soreness.healedAWhileAgo:
        return 'HEALED A WHILE AGO';
      case Soreness.healedJustOnTime:
        return 'HEALED JUST ON TIME';
      case Soreness.stillSore:
        return "I'M STILL SORE!";
    }
  }

  int get recovery {
    switch (this) {
      case Soreness.neverGotSore:
        return 0;
      case Soreness.healedAWhileAgo:
        return 1;
      case Soreness.healedJustOnTime:
        return 2;
      case Soreness.stillSore:
        return 3;
    }
  }
}

/// Gender for template filtering
enum Gender {
  male,
  female,
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'MALE';
      case Gender.female:
        return 'FEMALE';
    }
  }
}
