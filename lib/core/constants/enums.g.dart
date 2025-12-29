// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrainingCycleStatusAdapter extends TypeAdapter<TrainingCycleStatus> {
  @override
  final int typeId = 10;

  @override
  TrainingCycleStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TrainingCycleStatus.draft;
      case 1:
        return TrainingCycleStatus.current;
      case 2:
        return TrainingCycleStatus.completed;
      default:
        return TrainingCycleStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, TrainingCycleStatus obj) {
    switch (obj) {
      case TrainingCycleStatus.draft:
        writer.writeByte(0);
        break;
      case TrainingCycleStatus.current:
        writer.writeByte(1);
        break;
      case TrainingCycleStatus.completed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrainingCycleStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutStatusAdapter extends TypeAdapter<WorkoutStatus> {
  @override
  final int typeId = 11;

  @override
  WorkoutStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkoutStatus.incomplete;
      case 1:
        return WorkoutStatus.completed;
      case 2:
        return WorkoutStatus.skipped;
      default:
        return WorkoutStatus.incomplete;
    }
  }

  @override
  void write(BinaryWriter writer, WorkoutStatus obj) {
    switch (obj) {
      case WorkoutStatus.incomplete:
        writer.writeByte(0);
        break;
      case WorkoutStatus.completed:
        writer.writeByte(1);
        break;
      case WorkoutStatus.skipped:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetTypeAdapter extends TypeAdapter<SetType> {
  @override
  final int typeId = 12;

  @override
  SetType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SetType.regular;
      case 1:
        return SetType.myorep;
      case 2:
        return SetType.myorepMatch;
      case 3:
        return SetType.maxReps;
      case 4:
        return SetType.endWithPartials;
      default:
        return SetType.regular;
    }
  }

  @override
  void write(BinaryWriter writer, SetType obj) {
    switch (obj) {
      case SetType.regular:
        writer.writeByte(0);
        break;
      case SetType.myorep:
        writer.writeByte(1);
        break;
      case SetType.myorepMatch:
        writer.writeByte(2);
        break;
      case SetType.maxReps:
        writer.writeByte(3);
        break;
      case SetType.endWithPartials:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class JointPainAdapter extends TypeAdapter<JointPain> {
  @override
  final int typeId = 13;

  @override
  JointPain read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return JointPain.none;
      case 1:
        return JointPain.low;
      case 2:
        return JointPain.moderate;
      case 3:
        return JointPain.severe;
      default:
        return JointPain.none;
    }
  }

  @override
  void write(BinaryWriter writer, JointPain obj) {
    switch (obj) {
      case JointPain.none:
        writer.writeByte(0);
        break;
      case JointPain.low:
        writer.writeByte(1);
        break;
      case JointPain.moderate:
        writer.writeByte(2);
        break;
      case JointPain.severe:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JointPainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MusclePumpAdapter extends TypeAdapter<MusclePump> {
  @override
  final int typeId = 14;

  @override
  MusclePump read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MusclePump.low;
      case 1:
        return MusclePump.moderate;
      case 2:
        return MusclePump.amazing;
      default:
        return MusclePump.low;
    }
  }

  @override
  void write(BinaryWriter writer, MusclePump obj) {
    switch (obj) {
      case MusclePump.low:
        writer.writeByte(0);
        break;
      case MusclePump.moderate:
        writer.writeByte(1);
        break;
      case MusclePump.amazing:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusclePumpAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkloadAdapter extends TypeAdapter<Workload> {
  @override
  final int typeId = 15;

  @override
  Workload read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Workload.easy;
      case 1:
        return Workload.prettyGood;
      case 2:
        return Workload.pushedLimits;
      case 3:
        return Workload.tooMuch;
      default:
        return Workload.easy;
    }
  }

  @override
  void write(BinaryWriter writer, Workload obj) {
    switch (obj) {
      case Workload.easy:
        writer.writeByte(0);
        break;
      case Workload.prettyGood:
        writer.writeByte(1);
        break;
      case Workload.pushedLimits:
        writer.writeByte(2);
        break;
      case Workload.tooMuch:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkloadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SorenessAdapter extends TypeAdapter<Soreness> {
  @override
  final int typeId = 16;

  @override
  Soreness read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Soreness.neverGotSore;
      case 1:
        return Soreness.healedAWhileAgo;
      case 2:
        return Soreness.healedJustOnTime;
      case 3:
        return Soreness.stillSore;
      default:
        return Soreness.neverGotSore;
    }
  }

  @override
  void write(BinaryWriter writer, Soreness obj) {
    switch (obj) {
      case Soreness.neverGotSore:
        writer.writeByte(0);
        break;
      case Soreness.healedAWhileAgo:
        writer.writeByte(1);
        break;
      case Soreness.healedJustOnTime:
        writer.writeByte(2);
        break;
      case Soreness.stillSore:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SorenessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenderAdapter extends TypeAdapter<Gender> {
  @override
  final int typeId = 17;

  @override
  Gender read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Gender.male;
      case 1:
        return Gender.female;
      default:
        return Gender.male;
    }
  }

  @override
  void write(BinaryWriter writer, Gender obj) {
    switch (obj) {
      case Gender.male:
        writer.writeByte(0);
        break;
      case Gender.female:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecoveryPeriodTypeAdapter extends TypeAdapter<RecoveryPeriodType> {
  @override
  final int typeId = 123;

  @override
  RecoveryPeriodType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecoveryPeriodType.deload;
      case 1:
        return RecoveryPeriodType.taper;
      case 2:
        return RecoveryPeriodType.recovery;
      default:
        return RecoveryPeriodType.deload;
    }
  }

  @override
  void write(BinaryWriter writer, RecoveryPeriodType obj) {
    switch (obj) {
      case RecoveryPeriodType.deload:
        writer.writeByte(0);
        break;
      case RecoveryPeriodType.taper:
        writer.writeByte(1);
        break;
      case RecoveryPeriodType.recovery:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecoveryPeriodTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
