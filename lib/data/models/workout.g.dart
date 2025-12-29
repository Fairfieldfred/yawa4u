// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 103;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      id: fields[0] as String,
      trainingCycleId: fields[1] as String,
      periodNumber: fields[2] as int,
      dayNumber: fields[3] as int,
      dayName: fields[4] as String?,
      label: fields[5] as String?,
      status: fields[6] as WorkoutStatus,
      scheduledDate: fields[7] as DateTime?,
      completedDate: fields[8] as DateTime?,
      exercises: (fields[9] as List?)?.cast<Exercise>(),
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.trainingCycleId)
      ..writeByte(2)
      ..write(obj.periodNumber)
      ..writeByte(3)
      ..write(obj.dayNumber)
      ..writeByte(4)
      ..write(obj.dayName)
      ..writeByte(5)
      ..write(obj.label)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.scheduledDate)
      ..writeByte(8)
      ..write(obj.completedDate)
      ..writeByte(9)
      ..write(obj.exercises)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
