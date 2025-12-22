// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equipment_types.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EquipmentTypeAdapter extends TypeAdapter<EquipmentType> {
  @override
  final int typeId = 21;

  @override
  EquipmentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EquipmentType.barbell;
      case 1:
        return EquipmentType.bodyweightLoadable;
      case 2:
        return EquipmentType.bodyweightOnly;
      case 3:
        return EquipmentType.cable;
      case 4:
        return EquipmentType.dumbbell;
      case 5:
        return EquipmentType.freemotion;
      case 6:
        return EquipmentType.machine;
      case 7:
        return EquipmentType.machineAssistance;
      case 8:
        return EquipmentType.smithMachine;
      case 9:
        return EquipmentType.bandAssistance;
      default:
        return EquipmentType.barbell;
    }
  }

  @override
  void write(BinaryWriter writer, EquipmentType obj) {
    switch (obj) {
      case EquipmentType.barbell:
        writer.writeByte(0);
        break;
      case EquipmentType.bodyweightLoadable:
        writer.writeByte(1);
        break;
      case EquipmentType.bodyweightOnly:
        writer.writeByte(2);
        break;
      case EquipmentType.cable:
        writer.writeByte(3);
        break;
      case EquipmentType.dumbbell:
        writer.writeByte(4);
        break;
      case EquipmentType.freemotion:
        writer.writeByte(5);
        break;
      case EquipmentType.machine:
        writer.writeByte(6);
        break;
      case EquipmentType.machineAssistance:
        writer.writeByte(7);
        break;
      case EquipmentType.smithMachine:
        writer.writeByte(8);
        break;
      case EquipmentType.bandAssistance:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
