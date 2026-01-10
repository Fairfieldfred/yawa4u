// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_measurement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserMeasurementAdapter extends TypeAdapter<UserMeasurement> {
  @override
  final int typeId = 24;

  @override
  UserMeasurement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserMeasurement(
      id: fields[0] as String,
      heightCm: fields[1] as double,
      weightKg: fields[2] as double,
      timestamp: fields[3] as DateTime,
      notes: fields[4] as String?,
      bodyFatPercent: fields[5] as double?,
      leanMassKg: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, UserMeasurement obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.heightCm)
      ..writeByte(2)
      ..write(obj.weightKg)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.bodyFatPercent)
      ..writeByte(6)
      ..write(obj.leanMassKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMeasurementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
