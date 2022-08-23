// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadEntryAdapter extends TypeAdapter<_$_DownloadEntry> {
  @override
  final int typeId = 4;

  @override
  _$_DownloadEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$_DownloadEntry(
      id: fields[0] == null ? '' : fields[0] as String,
      post: fields[1] == null ? Post.empty : fields[1] as Post,
      destination: fields[2] == null ? '' : fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, _$_DownloadEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.post)
      ..writeByte(2)
      ..write(obj.destination);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
