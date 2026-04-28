// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_action_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncActionModelAdapter extends TypeAdapter<SyncActionModel> {
  @override
  final int typeId = 8;

  @override
  SyncActionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncActionModel(
      id: fields[0] as String,
      table: fields[1] as String,
      method: fields[2] as String,
      payload: (fields[3] as Map).cast<dynamic, dynamic>(),
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SyncActionModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.table)
      ..writeByte(2)
      ..write(obj.method)
      ..writeByte(3)
      ..write(obj.payload)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncActionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
