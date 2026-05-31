// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_phase_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressPhaseModelAdapter extends TypeAdapter<ProgressPhaseModel> {
  @override
  final int typeId = 1;

  @override
  ProgressPhaseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressPhaseModel(
      id: fields[0] as String,
      workspaceId: fields[1] as String,
      phaseName: fields[2] as String,
      sortOrder: fields[3] as int,
      status: fields[4] as String,
      lecturerFeedback: fields[5] as String?,
      clientCreatedAt: fields[6] as DateTime,
      serverReceivedAt: fields[7] as DateTime?,
      deadline: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProgressPhaseModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.workspaceId)
      ..writeByte(2)
      ..write(obj.phaseName)
      ..writeByte(3)
      ..write(obj.sortOrder)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.lecturerFeedback)
      ..writeByte(6)
      ..write(obj.clientCreatedAt)
      ..writeByte(7)
      ..write(obj.serverReceivedAt)
      ..writeByte(8)
      ..write(obj.deadline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressPhaseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
