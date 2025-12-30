// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 2;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      workoutId: fields[1] as String,
      name: fields[2] as String,
      muscleGroup: fields[3] as MuscleGroup,
      equipmentType: fields[4] as EquipmentType,
      sets: (fields[5] as List?)?.cast<ExerciseSet>(),
      orderIndex: fields[6] as int,
      bodyweight: fields[7] as double?,
      notes: fields[8] as String?,
      feedback: fields[9] as ExerciseFeedback?,
      lastPerformed: fields[10] as DateTime?,
      videoUrl: fields[11] as String?,
      isNotePinned: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workoutId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.muscleGroup)
      ..writeByte(4)
      ..write(obj.equipmentType)
      ..writeByte(5)
      ..write(obj.sets)
      ..writeByte(6)
      ..write(obj.orderIndex)
      ..writeByte(7)
      ..write(obj.bodyweight)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.feedback)
      ..writeByte(10)
      ..write(obj.lastPerformed)
      ..writeByte(11)
      ..write(obj.videoUrl)
      ..writeByte(12)
      ..write(obj.isNotePinned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
