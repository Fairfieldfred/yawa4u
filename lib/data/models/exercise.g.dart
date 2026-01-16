// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
  id: json['id'] as String,
  workoutId: json['workoutId'] as String,
  name: json['name'] as String,
  muscleGroup: $enumDecode(_$MuscleGroupEnumMap, json['muscleGroup']),
  equipmentType: $enumDecode(_$EquipmentTypeEnumMap, json['equipmentType']),
  sets: (json['sets'] as List<dynamic>?)
      ?.map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
      .toList(),
  orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
  bodyweight: (json['bodyweight'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  feedback: json['feedback'] == null
      ? null
      : ExerciseFeedback.fromJson(json['feedback'] as Map<String, dynamic>),
  lastPerformed: json['lastPerformed'] == null
      ? null
      : DateTime.parse(json['lastPerformed'] as String),
  videoUrl: json['videoUrl'] as String?,
  isNotePinned: json['isNotePinned'] as bool? ?? false,
);

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
  'id': instance.id,
  'workoutId': instance.workoutId,
  'name': instance.name,
  'muscleGroup': _$MuscleGroupEnumMap[instance.muscleGroup]!,
  'equipmentType': _$EquipmentTypeEnumMap[instance.equipmentType]!,
  'sets': instance.sets.map((e) => e.toJson()).toList(),
  'orderIndex': instance.orderIndex,
  'bodyweight': instance.bodyweight,
  'notes': instance.notes,
  'feedback': instance.feedback?.toJson(),
  'lastPerformed': instance.lastPerformed?.toIso8601String(),
  'videoUrl': instance.videoUrl,
  'isNotePinned': instance.isNotePinned,
};

const _$MuscleGroupEnumMap = {
  MuscleGroup.chest: 'chest',
  MuscleGroup.triceps: 'triceps',
  MuscleGroup.shoulders: 'shoulders',
  MuscleGroup.back: 'back',
  MuscleGroup.biceps: 'biceps',
  MuscleGroup.quads: 'quads',
  MuscleGroup.hamstrings: 'hamstrings',
  MuscleGroup.glutes: 'glutes',
  MuscleGroup.calves: 'calves',
  MuscleGroup.traps: 'traps',
  MuscleGroup.forearms: 'forearms',
  MuscleGroup.abs: 'abs',
};

const _$EquipmentTypeEnumMap = {
  EquipmentType.barbell: 'barbell',
  EquipmentType.bodyweightLoadable: 'bodyweightLoadable',
  EquipmentType.bodyweightOnly: 'bodyweightOnly',
  EquipmentType.cable: 'cable',
  EquipmentType.dumbbell: 'dumbbell',
  EquipmentType.freemotion: 'freemotion',
  EquipmentType.machine: 'machine',
  EquipmentType.machineAssistance: 'machineAssistance',
  EquipmentType.smithMachine: 'smithMachine',
  EquipmentType.bandAssistance: 'bandAssistance',
};
