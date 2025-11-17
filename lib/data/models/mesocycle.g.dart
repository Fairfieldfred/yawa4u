// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mesocycle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MesocycleAdapter extends TypeAdapter<Mesocycle> {
  @override
  final int typeId = 4;

  @override
  Mesocycle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Mesocycle(
      id: fields[0] as String,
      name: fields[1] as String,
      weeksTotal: fields[2] as int,
      daysPerWeek: fields[3] as int,
      deloadWeek: fields[4] as int?,
      status: fields[5] as MesocycleStatus,
      gender: fields[6] as Gender?,
      createdDate: fields[7] as DateTime?,
      startDate: fields[8] as DateTime?,
      endDate: fields[9] as DateTime?,
      workouts: (fields[10] as List?)?.cast<Workout>(),
      muscleGroupPriorities: (fields[11] as Map?)?.cast<String, int>(),
      templateName: fields[12] as String?,
      notes: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Mesocycle obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.weeksTotal)
      ..writeByte(3)
      ..write(obj.daysPerWeek)
      ..writeByte(4)
      ..write(obj.deloadWeek)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.createdDate)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.endDate)
      ..writeByte(10)
      ..write(obj.workouts)
      ..writeByte(11)
      ..write(obj.muscleGroupPriorities)
      ..writeByte(12)
      ..write(obj.templateName)
      ..writeByte(13)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MesocycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
