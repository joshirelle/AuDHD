// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensory_profile_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SensoryProfileResultAdapter extends TypeAdapter<SensoryProfileResult> {
  @override
  final int typeId = 2;

  @override
  SensoryProfileResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SensoryProfileResult(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      answers: (fields[2] as Map).cast<String, int>(),
      totalSeekingScore: fields[3] as int,
      totalAvoidingScore: fields[4] as int,
      primaryProfile: fields[5] as String,
      domainBreakdown: (fields[6] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SensoryProfileResult obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.answers)
      ..writeByte(3)
      ..write(obj.totalSeekingScore)
      ..writeByte(4)
      ..write(obj.totalAvoidingScore)
      ..writeByte(5)
      ..write(obj.primaryProfile)
      ..writeByte(6)
      ..write(obj.domainBreakdown);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensoryProfileResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
