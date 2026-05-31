// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_token_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionTokenModelAdapter extends TypeAdapter<SessionTokenModel> {
  @override
  final int typeId = 9;

  @override
  SessionTokenModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionTokenModel(
      userId: fields[0] as String,
      deviceId: fields[1] as String,
      serverTime: fields[2] as DateTime,
      monotonicAtIssue: fields[3] as int,
      expiresAt: fields[4] as DateTime,
      signature: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SessionTokenModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.deviceId)
      ..writeByte(2)
      ..write(obj.serverTime)
      ..writeByte(3)
      ..write(obj.monotonicAtIssue)
      ..writeByte(4)
      ..write(obj.expiresAt)
      ..writeByte(5)
      ..write(obj.signature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionTokenModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
