// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_allocation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAllocationModelAdapter extends TypeAdapter<TaskAllocationModel> {
  @override
  final int typeId = 2;

  @override
  TaskAllocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskAllocationModel(
      id: fields[0] as String,
      phaseId: fields[1] as String,
      studentId: fields[2] as String,
      taskDescription: fields[3] as String,
      percentage: fields[4] as int,
      requireEvidence: fields[5] as bool,
      isDone: fields[6] as bool,
      status: fields[7] as String,
      lecturerFeedback: fields[8] as String?,
      clientCreatedAt: fields[9] as DateTime,
      serverReceivedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskAllocationModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.phaseId)
      ..writeByte(2)
      ..write(obj.studentId)
      ..writeByte(3)
      ..write(obj.taskDescription)
      ..writeByte(4)
      ..write(obj.percentage)
      ..writeByte(5)
      ..write(obj.requireEvidence)
      ..writeByte(6)
      ..write(obj.isDone)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.lecturerFeedback)
      ..writeByte(9)
      ..write(obj.clientCreatedAt)
      ..writeByte(10)
      ..write(obj.serverReceivedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAllocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
