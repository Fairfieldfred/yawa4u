// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseSetAdapter extends TypeAdapter<ExerciseSet> {
  @override
  final int typeId = 0;

  @override
  ExerciseSet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSet(
      id: fields[0] as String,
      setNumber: fields[1] as int,
      weight: fields[2] as double?,
      reps: fields[3] as String,
      setType: fields[4] as SetType,
      isLogged: fields[5] as bool,
      notes: fields[6] as String?,
      isSkipped: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSet obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.setNumber)
      ..writeByte(2)
      ..write(obj.weight)
      ..writeByte(3)
      ..write(obj.reps)
      ..writeByte(4)
      ..write(obj.setType)
      ..writeByte(5)
      ..write(obj.isLogged)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.isSkipped);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) => ExerciseSet(
      id: json['id'] as String,
      setNumber: (json['setNumber'] as num).toInt(),
      weight: (json['weight'] as num?)?.toDouble(),
      reps: json['reps'] as String,
      setType: $enumDecodeNullable(_$SetTypeEnumMap, json['setType']) ??
          SetType.regular,
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
};
