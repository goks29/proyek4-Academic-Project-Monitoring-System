// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkspaceModelAdapter extends TypeAdapter<WorkspaceModel> {
  @override
  final int typeId = 0;

  @override
  WorkspaceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkspaceModel(
      id: fields[0] as String,
      projectId: fields[1] as String,
      teamName: fields[2] as String,
      topicName: fields[3] as String?,
      topicDescription: fields[4] as String?,
      progressionMode: fields[5] as String,
      isCompleted: fields[6] as bool,
      clientCreatedAt: fields[7] as DateTime,
      serverReceivedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkspaceModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.teamName)
      ..writeByte(3)
      ..write(obj.topicName)
      ..writeByte(4)
      ..write(obj.topicDescription)
      ..writeByte(5)
      ..write(obj.progressionMode)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.clientCreatedAt)
      ..writeByte(8)
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
