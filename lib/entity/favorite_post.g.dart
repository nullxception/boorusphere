// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoritePostAdapter extends TypeAdapter<FavoritePost> {
  @override
  final int typeId = 5;

  @override
  FavoritePost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoritePost(
      post: fields[0] == null ? Post.empty : fields[0] as Post,
      timestamp: fields[1] == null ? 0 : fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FavoritePost obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.post)
      ..writeByte(1)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritePostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
