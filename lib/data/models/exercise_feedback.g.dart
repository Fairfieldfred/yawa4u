// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_feedback.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseFeedbackAdapter extends TypeAdapter<ExerciseFeedback> {
  @override
  final int typeId = 1;

  @override
  ExerciseFeedback read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseFeedback(
      jointPain: fields[0] as JointPain?,
      musclePump: fields[1] as MusclePump?,
      workload: fields[2] as Workload?,
      soreness: fields[3] as Soreness?,
      muscleGroupSoreness: (fields[4] as Map?)?.cast<String, Soreness>(),
      timestamp: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseFeedback obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.jointPain)
      ..writeByte(1)
      ..write(obj.musclePump)
      ..writeByte(2)
      ..write(obj.workload)
      ..writeByte(3)
      ..write(obj.soreness)
      ..writeByte(4)
      ..write(obj.muscleGroupSoreness)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseFeedbackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
