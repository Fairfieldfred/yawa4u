// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_feedback.dart';

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
      'muscleGroupSoreness': instance.muscleGroupSoreness?.map(
        (k, e) => MapEntry(k, _$SorenessEnumMap[e]!),
      ),
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
