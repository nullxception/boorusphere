// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booru_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BooruPostAdapter extends TypeAdapter<_$_BooruPost> {
  @override
  final int typeId = 3;

  @override
  _$_BooruPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$_BooruPost(
      id: fields[0] == null ? -1 : fields[0] as int,
      src: fields[1] == null ? '' : fields[1] as String,
      displaySrc: fields[2] == null ? '' : fields[2] as String,
      thumbnail: fields[3] == null ? '' : fields[3] as String,
      tags: fields[4] == null ? [] : (fields[4] as List).cast<String>(),
      width: fields[5] == null ? -1 : fields[5] as int,
      height: fields[6] == null ? -1 : fields[6] as int,
      serverName: fields[7] == null ? '' : fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, _$_BooruPost obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.src)
      ..writeByte(2)
      ..write(obj.displaySrc)
      ..writeByte(3)
      ..write(obj.thumbnail)
      ..writeByte(5)
      ..write(obj.width)
      ..writeByte(6)
      ..write(obj.height)
      ..writeByte(7)
      ..write(obj.serverName)
      ..writeByte(4)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooruPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
