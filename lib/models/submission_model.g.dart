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
      phaseId: fields[1] as String,
      studentId: fields[2] as String,
      submittedAt: fields[3] as String,
      evidenceFileUrl: fields[4] as String?,
      studentNotes: fields[5] as String?,
      status: fields[6] as String,
      lecturerFeedback: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SubmissionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.phaseId)
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
      ..write(obj.lecturerFeedback);
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
