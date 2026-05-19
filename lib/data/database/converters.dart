import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/constants/enums.dart';
import '../../core/constants/equipment_types.dart';
import '../../core/constants/muscle_groups.dart';
import '../../core/constants/sports.dart';

/// Type converter for TrainingCycleStatus enum
class TrainingCycleStatusConverter extends TypeConverter<TrainingCycleStatus, int> {
  const TrainingCycleStatusConverter();

  @override
  TrainingCycleStatus fromSql(int fromDb) {
    return TrainingCycleStatus.values[fromDb];
  }

  @override
  int toSql(TrainingCycleStatus value) {
    return value.index;
  }
}

/// Type converter for WorkoutStatus enum
class WorkoutStatusConverter extends TypeConverter<WorkoutStatus, int> {
  const WorkoutStatusConverter();

  @override
  WorkoutStatus fromSql(int fromDb) {
    return WorkoutStatus.values[fromDb];
  }

  @override
  int toSql(WorkoutStatus value) {
    return value.index;
  }
}

/// Type converter for SetType enum
class SetTypeConverter extends TypeConverter<SetType, int> {
  const SetTypeConverter();

  @override
  SetType fromSql(int fromDb) {
    return SetType.values[fromDb];
  }

  @override
  int toSql(SetType value) {
    return value.index;
  }
}

/// Type converter for MuscleGroup enum
class MuscleGroupConverter extends TypeConverter<MuscleGroup, int> {
  const MuscleGroupConverter();

  @override
  MuscleGroup fromSql(int fromDb) {
    return MuscleGroup.values[fromDb];
  }

  @override
  int toSql(MuscleGroup value) {
    return value.index;
  }
}

/// Type converter for EquipmentType enum
class EquipmentTypeConverter extends TypeConverter<EquipmentType, int> {
  const EquipmentTypeConverter();

  @override
  EquipmentType fromSql(int fromDb) {
    return EquipmentType.values[fromDb];
  }

  @override
  int toSql(EquipmentType value) {
    return value.index;
  }
}

/// Type converter for Gender enum
class GenderConverter extends TypeConverter<Gender, int> {
  const GenderConverter();

  @override
  Gender fromSql(int fromDb) {
    return Gender.values[fromDb];
  }

  @override
  int toSql(Gender value) {
    return value.index;
  }
}

/// Type converter for RecoveryPeriodType enum
class RecoveryPeriodTypeConverter extends TypeConverter<RecoveryPeriodType, int> {
  const RecoveryPeriodTypeConverter();

  @override
  RecoveryPeriodType fromSql(int fromDb) {
    return RecoveryPeriodType.values[fromDb];
  }

  @override
  int toSql(RecoveryPeriodType value) {
    return value.index;
  }
}

/// Type converter for JointPain enum
class JointPainConverter extends TypeConverter<JointPain, int> {
  const JointPainConverter();

  @override
  JointPain fromSql(int fromDb) {
    return JointPain.values[fromDb];
  }

  @override
  int toSql(JointPain value) {
    return value.index;
  }
}

/// Type converter for MusclePump enum
class MusclePumpConverter extends TypeConverter<MusclePump, int> {
  const MusclePumpConverter();

  @override
  MusclePump fromSql(int fromDb) {
    return MusclePump.values[fromDb];
  }

  @override
  int toSql(MusclePump value) {
    return value.index;
  }
}

/// Type converter for Workload enum
class WorkloadConverter extends TypeConverter<Workload, int> {
  const WorkloadConverter();

  @override
  Workload fromSql(int fromDb) {
    return Workload.values[fromDb];
  }

  @override
  int toSql(Workload value) {
    return value.index;
  }
}

/// Type converter for Soreness enum
class SorenessConverter extends TypeConverter<Soreness, int> {
  const SorenessConverter();

  @override
  Soreness fromSql(int fromDb) {
    return Soreness.values[fromDb];
  }

  @override
  int toSql(Soreness value) {
    return value.index;
  }
}

/// Type converter for Map<String, int> stored as JSON
class StringIntMapConverter extends TypeConverter<Map<String, int>, String> {
  const StringIntMapConverter();

  @override
  Map<String, int> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    final decoded = jsonDecode(fromDb) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  @override
  String toSql(Map<String, int> value) {
    return jsonEncode(value);
  }
}

/// Type converter for Map<String, Soreness> stored as JSON (by index)
class MuscleGroupSorenessMapConverter extends TypeConverter<Map<String, Soreness>, String> {
  const MuscleGroupSorenessMapConverter();

  @override
  Map<String, Soreness> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    final decoded = jsonDecode(fromDb) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, Soreness.values[value as int]),
    );
  }

  @override
  String toSql(Map<String, Soreness> value) {
    return jsonEncode(value.map((key, v) => MapEntry(key, v.index)));
  }
}

// ---------------------------------------------------------------------------
// v5 converters (multi-sport expansion).
// ---------------------------------------------------------------------------

/// Type converter for Sport enum.
class SportConverter extends TypeConverter<Sport, int> {
  const SportConverter();

  @override
  Sport fromSql(int fromDb) => Sport.values[fromDb];

  @override
  int toSql(Sport value) => value.index;
}

/// Type converter for SessionSource enum.
class SessionSourceConverter extends TypeConverter<SessionSource, int> {
  const SessionSourceConverter();

  @override
  SessionSource fromSql(int fromDb) => SessionSource.values[fromDb];

  @override
  int toSql(SessionSource value) => value.index;
}

/// Type converter for IntervalIntent enum.
class IntervalIntentConverter extends TypeConverter<IntervalIntent, int> {
  const IntervalIntentConverter();

  @override
  IntervalIntent fromSql(int fromDb) => IntervalIntent.values[fromDb];

  @override
  int toSql(IntervalIntent value) => value.index;
}

/// Type converter for IntervalTargetKind enum.
class IntervalTargetKindConverter extends TypeConverter<IntervalTargetKind, int> {
  const IntervalTargetKindConverter();

  @override
  IntervalTargetKind fromSql(int fromDb) => IntervalTargetKind.values[fromDb];

  @override
  int toSql(IntervalTargetKind value) => value.index;
}

/// Type converter for StrokeType enum.
class StrokeTypeConverter extends TypeConverter<StrokeType, int> {
  const StrokeTypeConverter();

  @override
  StrokeType fromSql(int fromDb) => StrokeType.values[fromDb];

  @override
  int toSql(StrokeType value) => value.index;
}

/// Type converter for TrainingPhase enum.
class TrainingPhaseConverter extends TypeConverter<TrainingPhase, int> {
  const TrainingPhaseConverter();

  @override
  TrainingPhase fromSql(int fromDb) => TrainingPhase.values[fromDb];

  @override
  int toSql(TrainingPhase value) => value.index;
}
