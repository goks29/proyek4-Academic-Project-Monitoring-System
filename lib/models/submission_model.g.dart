// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubmissionModelAdapter extends TypeAdapter<SubmissionModel> {
  @override
  final int typeId = 3;

  @override
  SubmissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubmissionModel(
      id: fields[0] as String,
      taskId: fields[1] as String,
      studentId: fields[2] as String,
      submittedAt: fields[3] as DateTime,
      evidenceFileUrl: fields[4] as String?,
      studentNotes: fields[5] as String?,
      status: fields[6] as String,
      lecturerFeedback: fields[7] as String?,
      lecturerId: fields[8] as String?,
      serverReceivedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SubmissionModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.studentId)
      ..writeByte(3)
      ..write(obj.submittedAt)
      ..writeByte(4)
      ..write(obj.evidenceFileUrl)
      ..writeByte(5)
      ..write(obj.studentNotes)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.lecturerFeedback)
      ..writeByte(8)
      ..write(obj.lecturerId)
      ..writeByte(9)
      ..write(obj.serverReceivedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
