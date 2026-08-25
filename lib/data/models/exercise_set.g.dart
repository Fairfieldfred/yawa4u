// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) => ExerciseSet(
  id: json['id'] as String,
  setNumber: (json['setNumber'] as num).toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  reps: json['reps'] as String,
  setType:
      $enumDecodeNullable(_$SetTypeEnumMap, json['setType']) ?? SetType.regular,
  isLogged: json['isLogged'] as bool? ?? false,
  notes: json['notes'] as String?,
  isSkipped: json['isSkipped'] as bool? ?? false,
);

Map<String, dynamic> _$ExerciseSetToJson(ExerciseSet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'setNumber': instance.setNumber,
      'weight': instance.weight,
      'reps': instance.reps,
      'setType': _$SetTypeEnumMap[instance.setType]!,
      'isLogged': instance.isLogged,
      'notes': instance.notes,
      'isSkipped': instance.isSkipped,
    };

const _$SetTypeEnumMap = {
  SetType.regular: 'regular',
  SetType.myorep: 'myorep',
  SetType.myorepMatch: 'myorepMatch',
  SetType.maxReps: 'maxReps',
  SetType.endWithPartials: 'endWithPartials',
  SetType.dropSet: 'dropSet',
};
