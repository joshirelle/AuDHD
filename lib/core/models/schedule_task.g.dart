// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleTaskAdapter extends TypeAdapter<ScheduleTask> {
  @override
  final int typeId = 3;

  @override
  ScheduleTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleTask(
      id: fields[0] as String,
      titleTagalog: fields[1] as String,
      iconKey: fields[2] as String,
      timeOfDay: fields[3] as ScheduleTimeOfDay,
      starReward: fields[4] as int,
      minuteOfDay: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleTask obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titleTagalog)
      ..writeByte(2)
      ..write(obj.iconKey)
      ..writeByte(3)
      ..write(obj.timeOfDay)
      ..writeByte(4)
      ..write(obj.starReward)
      ..writeByte(5)
      ..write(obj.minuteOfDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ScheduleTimeOfDayAdapter extends TypeAdapter<ScheduleTimeOfDay> {
  @override
  final int typeId = 4;

  @override
  ScheduleTimeOfDay read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ScheduleTimeOfDay.morning;
      case 1:
        return ScheduleTimeOfDay.afternoon;
      case 2:
        return ScheduleTimeOfDay.evening;
      default:
        return ScheduleTimeOfDay.morning;
    }
  }

  @override
  void write(BinaryWriter writer, ScheduleTimeOfDay obj) {
    switch (obj) {
      case ScheduleTimeOfDay.morning:
        writer.writeByte(0);
        break;
      case ScheduleTimeOfDay.afternoon:
        writer.writeByte(1);
        break;
      case ScheduleTimeOfDay.evening:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleTimeOfDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
