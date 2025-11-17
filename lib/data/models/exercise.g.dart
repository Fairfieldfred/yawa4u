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
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.videoUrl);
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
