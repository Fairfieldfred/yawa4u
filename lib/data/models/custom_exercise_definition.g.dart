// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_exercise_definition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomExerciseDefinitionAdapter
    extends TypeAdapter<CustomExerciseDefinition> {
  @override
  final int typeId = 22;

  @override
  CustomExerciseDefinition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomExerciseDefinition(
      id: fields[0] as String,
      name: fields[1] as String,
      muscleGroup: fields[2] as MuscleGroup,
      equipmentType: fields[3] as EquipmentType,
      videoUrl: fields[4] as String?,
      createdAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomExerciseDefinition obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.muscleGroup)
      ..writeByte(3)
      ..write(obj.equipmentType)
      ..writeByte(4)
      ..write(obj.videoUrl)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomExerciseDefinitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
