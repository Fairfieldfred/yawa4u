/// Status of a trainingCycle
enum TrainingCycleStatus {
  draft,
  current,
  completed,
}

extension TrainingCycleStatusExtension on TrainingCycleStatus {
  String get displayName {
    switch (this) {
      case TrainingCycleStatus.draft:
        return 'Draft';
      case TrainingCycleStatus.current:
        return 'Current';
      case TrainingCycleStatus.completed:
        return 'Completed';
    }
  }

  bool get isDraft => this == TrainingCycleStatus.draft;
  bool get isCurrent => this == TrainingCycleStatus.current;
  bool get isCompleted => this == TrainingCycleStatus.completed;
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
  maxReps,
  endWithPartials,
  dropSet,
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
      case SetType.maxReps:
        return 'Max reps';
      case SetType.endWithPartials:
        return 'End with partials';
      case SetType.dropSet:
        return 'Drop set';
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
      case SetType.maxReps:
        return 'perform as many reps as possible until failure';
      case SetType.endWithPartials:
        return 'after reaching failure, continue with partial reps to further fatigue the muscle';
      case SetType.dropSet:
        return 'immediately reduce weight and continue reps without rest to extend the set';
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
      case SetType.maxReps:
        return 'MX';
      case SetType.endWithPartials:
        return 'EP';
      case SetType.dropSet:
        return 'DS';
    }
  }

  bool get isRegular => this == SetType.regular;
  bool get isMyorep => this == SetType.myorep;
  bool get isMyorepMatch => this == SetType.myorepMatch;
  bool get isMaxReps => this == SetType.maxReps;
  bool get isEndWithPartials => this == SetType.endWithPartials;
  bool get isDropSet => this == SetType.dropSet;
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

/// Recovery period type for training cycles
enum RecoveryPeriodType {
  deload,
  taper,
  recovery,
}

extension RecoveryPeriodTypeExtension on RecoveryPeriodType {
  String get displayName {
    switch (this) {
      case RecoveryPeriodType.deload:
        return 'Deload';
      case RecoveryPeriodType.taper:
        return 'Taper';
      case RecoveryPeriodType.recovery:
        return 'Recovery';
    }
  }

  /// Abbreviation for calendar display
  String get abbreviation {
    switch (this) {
      case RecoveryPeriodType.deload:
        return 'DL';
      case RecoveryPeriodType.taper:
        return 'TP';
      case RecoveryPeriodType.recovery:
        return 'R';
    }
  }

  String get description {
    switch (this) {
      case RecoveryPeriodType.deload:
        return 'Reduce weight while maintaining volume';
      case RecoveryPeriodType.taper:
        return 'Reduce volume while maintaining intensity';
      case RecoveryPeriodType.recovery:
        return 'Light training to promote active recovery';
    }
  }
}
