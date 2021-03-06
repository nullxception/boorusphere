// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostAdapter extends TypeAdapter<_$_Post> {
  @override
  final int typeId = 3;

  @override
  _$_Post read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$_Post(
      id: fields[0] == null ? -1 : fields[0] as int,
      originalFile: fields[1] == null ? '' : fields[1] as String,
      sampleFile: fields[2] == null ? '' : fields[2] as String,
      previewFile: fields[3] == null ? '' : fields[3] as String,
      tags: fields[4] == null ? [] : (fields[4] as List).cast<String>(),
      width: fields[5] == null ? -1 : fields[5] as int,
      height: fields[6] == null ? -1 : fields[6] as int,
      serverName: fields[7] == null ? '' : fields[7] as String,
      postUrl: fields[8] == null ? '' : fields[8] as String,
      rateValue: fields[9] == null ? 'q' : fields[9] as String,
      sampleWidth: fields[10] == null ? -1 : fields[10] as int,
      sampleHeight: fields[11] == null ? -1 : fields[11] as int,
      previewWidth: fields[12] == null ? -1 : fields[12] as int,
      previewHeight: fields[13] == null ? -1 : fields[13] as int,
      source: fields[14] == null ? '' : fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, _$_Post obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalFile)
      ..writeByte(2)
      ..write(obj.sampleFile)
      ..writeByte(3)
      ..write(obj.previewFile)
      ..writeByte(5)
      ..write(obj.width)
      ..writeByte(6)
      ..write(obj.height)
      ..writeByte(7)
      ..write(obj.serverName)
      ..writeByte(8)
      ..write(obj.postUrl)
      ..writeByte(9)
      ..write(obj.rateValue)
      ..writeByte(10)
      ..write(obj.sampleWidth)
      ..writeByte(11)
      ..write(obj.sampleHeight)
      ..writeByte(12)
      ..write(obj.previewWidth)
      ..writeByte(13)
      ..write(obj.previewHeight)
      ..writeByte(14)
      ..write(obj.source)
      ..writeByte(4)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
