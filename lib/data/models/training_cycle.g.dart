// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_cycle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingCycleAdapter extends TypeAdapter<TrainingCycle> {
  @override
  final int typeId = 104;

  @override
  TrainingCycle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrainingCycle(
      id: fields[0] as String,
      name: fields[1] as String,
      periodsTotal: fields[2] as int,
      daysPerPeriod: fields[3] as int,
      recoveryPeriod: fields[4] as int?,
      status: fields[5] as TrainingCycleStatus,
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
  void write(BinaryWriter writer, TrainingCycle obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.periodsTotal)
      ..writeByte(3)
      ..write(obj.daysPerPeriod)
      ..writeByte(4)
      ..write(obj.recoveryPeriod)
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
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj._recoveryPeriodType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingCycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
