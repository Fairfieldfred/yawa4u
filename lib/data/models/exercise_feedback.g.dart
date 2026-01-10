// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_feedback.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseFeedbackAdapter extends TypeAdapter<ExerciseFeedback> {
  @override
  final int typeId = 1;

  @override
  ExerciseFeedback read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseFeedback(
      jointPain: fields[0] as JointPain?,
      musclePump: fields[1] as MusclePump?,
      workload: fields[2] as Workload?,
      soreness: fields[3] as Soreness?,
      muscleGroupSoreness: (fields[4] as Map?)?.cast<String, Soreness>(),
      timestamp: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseFeedback obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.jointPain)
      ..writeByte(1)
      ..write(obj.musclePump)
      ..writeByte(2)
      ..write(obj.workload)
      ..writeByte(3)
      ..write(obj.soreness)
      ..writeByte(4)
      ..write(obj.muscleGroupSoreness)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseFeedbackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseFeedback _$ExerciseFeedbackFromJson(Map<String, dynamic> json) =>
    ExerciseFeedback(
      jointPain: $enumDecodeNullable(_$JointPainEnumMap, json['jointPain']),
      musclePump: $enumDecodeNullable(_$MusclePumpEnumMap, json['musclePump']),
      workload: $enumDecodeNullable(_$WorkloadEnumMap, json['workload']),
      soreness: $enumDecodeNullable(_$SorenessEnumMap, json['soreness']),
      muscleGroupSoreness:
          (json['muscleGroupSoreness'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$SorenessEnumMap, e)),
      ),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ExerciseFeedbackToJson(ExerciseFeedback instance) =>
    <String, dynamic>{
      'jointPain': _$JointPainEnumMap[instance.jointPain],
      'musclePump': _$MusclePumpEnumMap[instance.musclePump],
      'workload': _$WorkloadEnumMap[instance.workload],
      'soreness': _$SorenessEnumMap[instance.soreness],
      'muscleGroupSoreness': instance.muscleGroupSoreness
          ?.map((k, e) => MapEntry(k, _$SorenessEnumMap[e]!)),
      'timestamp': instance.timestamp?.toIso8601String(),
    };

const _$JointPainEnumMap = {
  JointPain.none: 'none',
  JointPain.low: 'low',
  JointPain.moderate: 'moderate',
  JointPain.severe: 'severe',
};

const _$MusclePumpEnumMap = {
  MusclePump.low: 'low',
  MusclePump.moderate: 'moderate',
  MusclePump.amazing: 'amazing',
};

const _$WorkloadEnumMap = {
  Workload.easy: 'easy',
  Workload.prettyGood: 'prettyGood',
  Workload.pushedLimits: 'pushedLimits',
  Workload.tooMuch: 'tooMuch',
};

const _$SorenessEnumMap = {
  Soreness.neverGotSore: 'neverGotSore',
  Soreness.healedAWhileAgo: 'healedAWhileAgo',
  Soreness.healedJustOnTime: 'healedJustOnTime',
  Soreness.stillSore: 'stillSore',
};
