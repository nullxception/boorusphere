// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServersAdapter extends TypeAdapter<ServerData> {
  @override
  final int typeId = 2;

  @override
  ServerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerData(
      name: fields[0] == null ? '' : fields[0] as String,
      homepage: fields[1] == null ? '' : fields[1] as String,
      postUrl: fields[2] == null ? '' : fields[2] as String,
      searchUrl: fields[3] == null ? '' : fields[3] as String,
      apiAddr: fields[4] == null ? '' : fields[4] as String,
      tagSuggestionUrl: fields[7] == null ? '' : fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ServerData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.homepage)
      ..writeByte(2)
      ..write(obj.postUrl)
      ..writeByte(3)
      ..write(obj.searchUrl)
      ..writeByte(4)
      ..write(obj.apiAddr)
      ..writeByte(7)
      ..write(obj.tagSuggestionUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerData _$ServerDataFromJson(Map<String, dynamic> json) => ServerData(
      name: json['name'] as String? ?? '',
      homepage: json['homepage'] as String? ?? '',
      postUrl: json['postUrl'] as String? ?? '',
      searchUrl: json['searchUrl'] as String? ?? '',
      apiAddr: json['apiAddr'] as String? ?? '',
      tagSuggestionUrl: json['tagSuggestionUrl'] as String? ?? '',
    );

Map<String, dynamic> _$ServerDataToJson(ServerData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'homepage': instance.homepage,
      'postUrl': instance.postUrl,
      'searchUrl': instance.searchUrl,
      'apiAddr': instance.apiAddr,
      'tagSuggestionUrl': instance.tagSuggestionUrl,
    };
