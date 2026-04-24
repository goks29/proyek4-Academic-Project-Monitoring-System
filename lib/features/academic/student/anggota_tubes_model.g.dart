// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anggota_tubes_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnggotaTubesModelAdapter extends TypeAdapter<AnggotaTubesModel> {
  @override
  final int typeId = 1;

  @override
  AnggotaTubesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnggotaTubesModel(
      projectId: fields[0] as String,
      profileId: fields[1] as String,
      role: fields[2] as String,
      joinedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AnggotaTubesModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.projectId)
      ..writeByte(1)
      ..write(obj.profileId)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.joinedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnggotaTubesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
