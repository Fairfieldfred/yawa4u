// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_groups.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MuscleGroupAdapter extends TypeAdapter<MuscleGroup> {
  @override
  final int typeId = 20;

  @override
  MuscleGroup read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MuscleGroup.chest;
      case 1:
        return MuscleGroup.triceps;
      case 2:
        return MuscleGroup.shoulders;
      case 3:
        return MuscleGroup.back;
      case 4:
        return MuscleGroup.biceps;
      case 5:
        return MuscleGroup.quads;
      case 6:
        return MuscleGroup.hamstrings;
      case 7:
        return MuscleGroup.glutes;
      case 8:
        return MuscleGroup.calves;
      case 9:
        return MuscleGroup.traps;
      case 10:
        return MuscleGroup.forearms;
      case 11:
        return MuscleGroup.abs;
      default:
        return MuscleGroup.chest;
    }
  }

  @override
  void write(BinaryWriter writer, MuscleGroup obj) {
    switch (obj) {
      case MuscleGroup.chest:
        writer.writeByte(0);
        break;
      case MuscleGroup.triceps:
        writer.writeByte(1);
        break;
      case MuscleGroup.shoulders:
        writer.writeByte(2);
        break;
      case MuscleGroup.back:
        writer.writeByte(3);
        break;
      case MuscleGroup.biceps:
        writer.writeByte(4);
        break;
      case MuscleGroup.quads:
        writer.writeByte(5);
        break;
      case MuscleGroup.hamstrings:
        writer.writeByte(6);
        break;
      case MuscleGroup.glutes:
        writer.writeByte(7);
        break;
      case MuscleGroup.calves:
        writer.writeByte(8);
        break;
      case MuscleGroup.traps:
        writer.writeByte(9);
        break;
      case MuscleGroup.forearms:
        writer.writeByte(10);
        break;
      case MuscleGroup.abs:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MuscleGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
