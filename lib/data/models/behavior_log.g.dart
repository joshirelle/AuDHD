// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behavior_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BehaviorLogAdapter extends TypeAdapter<BehaviorLog> {
  @override
  final int typeId = 1;

  @override
  BehaviorLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BehaviorLog(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      antecedent: fields[2] as String,
      behavior: fields[3] as String,
      consequence: fields[4] as String,
      sensoryTriggers: (fields[5] as List).cast<String>(),
      intensity: fields[6] as int,
      durationMinutes: fields[7] as int,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BehaviorLog obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.antecedent)
      ..writeByte(3)
      ..write(obj.behavior)
      ..writeByte(4)
      ..write(obj.consequence)
      ..writeByte(5)
      ..write(obj.sensoryTriggers)
      ..writeByte(6)
      ..write(obj.intensity)
      ..writeByte(7)
      ..write(obj.durationMinutes)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BehaviorLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
