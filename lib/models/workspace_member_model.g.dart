// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_member_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkspaceMemberModelAdapter extends TypeAdapter<WorkspaceMemberModel> {
  @override
  final int typeId = 7;

  @override
  WorkspaceMemberModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkspaceMemberModel(
      id: fields[0] as String,
      workspaceId: fields[1] as String,
      studentId: fields[2] as String,
      isLeader: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WorkspaceMemberModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workspaceId)
      ..writeByte(2)
      ..write(obj.studentId)
      ..writeByte(3)
      ..write(obj.isLeader);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkspaceMemberModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
