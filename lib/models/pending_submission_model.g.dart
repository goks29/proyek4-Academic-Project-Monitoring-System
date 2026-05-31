// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_submission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingSubmissionModelAdapter
    extends TypeAdapter<PendingSubmissionModel> {
  @override
  final int typeId = 10;

  @override
  PendingSubmissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingSubmissionModel(
      id: fields[0] as String,
      taskId: fields[1] as String,
      studentId: fields[2] as String,
      localFilePath: fields[3] as String,
      fileHash: fields[4] as String,
      estimatedSubmitAt: fields[5] as DateTime,
      syncNonce: fields[6] as String,
      notes: fields[7] as String?,
      fileName: fields[8] as String,
      mimeType: fields[9] as String,
      tokenUserId: fields[10] as String,
      tokenDeviceId: fields[11] as String,
      tokenServerTime: fields[12] as DateTime,
      tokenMonotonicAtIssue: fields[13] as int,
      tokenExpiresAt: fields[14] as DateTime,
      tokenSignature: fields[15] as String,
      createdAt: fields[16] as DateTime,
      syncStatus: fields[17] as String,
      syncError: fields[18] as String?,
      retryCount: fields[19] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PendingSubmissionModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.taskId)
      ..writeByte(2)
      ..write(obj.studentId)
      ..writeByte(3)
      ..write(obj.localFilePath)
      ..writeByte(4)
      ..write(obj.fileHash)
      ..writeByte(5)
      ..write(obj.estimatedSubmitAt)
      ..writeByte(6)
      ..write(obj.syncNonce)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.fileName)
      ..writeByte(9)
      ..write(obj.mimeType)
      ..writeByte(10)
      ..write(obj.tokenUserId)
      ..writeByte(11)
      ..write(obj.tokenDeviceId)
      ..writeByte(12)
      ..write(obj.tokenServerTime)
      ..writeByte(13)
      ..write(obj.tokenMonotonicAtIssue)
      ..writeByte(14)
      ..write(obj.tokenExpiresAt)
      ..writeByte(15)
      ..write(obj.tokenSignature)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.syncStatus)
      ..writeByte(18)
      ..write(obj.syncError)
      ..writeByte(19)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingSubmissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
