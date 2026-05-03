// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkspaceModelAdapter extends TypeAdapter<WorkspaceModel> {
  @override
  final int typeId = 6;

  @override
  WorkspaceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkspaceModel(
      id: fields[0] as String,
      joinCode: fields[1] as String?,
      teamName: fields[2] as String,
      topicName: fields[3] as String?,
      topicDescription: fields[4] as String?,
      status: fields[5] as String,
      lecturerFeedback: fields[6] as String?,
      isCompleted: fields[7] as bool,
      clientCreatedAt: fields[8] as DateTime,
      serverReceivedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkspaceModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.joinCode)
      ..writeByte(2)
      ..write(obj.teamName)
      ..writeByte(3)
      ..write(obj.topicName)
      ..writeByte(4)
      ..write(obj.topicDescription)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.lecturerFeedback)
      ..writeByte(7)
      ..write(obj.isCompleted)
      ..writeByte(8)
      ..write(obj.clientCreatedAt)
      ..writeByte(9)
      ..write(obj.serverReceivedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
