// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServersAdapter extends TypeAdapter<_$_ServerData> {
  @override
  final int typeId = 2;

  @override
  _$_ServerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$_ServerData(
      name: fields[0] == null ? '' : fields[0] as String,
      homepage: fields[1] == null ? '' : fields[1] as String,
      postUrl: fields[2] == null ? '' : fields[2] as String,
      searchUrl: fields[3] == null ? '' : fields[3] as String,
      safeModeTag: fields[4] == null ? '' : fields[4] as String?,
      safeModeUrl: fields[5] == null ? '' : fields[5] as String?,
      safeMode: fields[6] == null ? '' : fields[6] as String?,
      tagSuggestionUrl: fields[7] == null ? '' : fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, _$_ServerData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.homepage)
      ..writeByte(2)
      ..write(obj.postUrl)
      ..writeByte(3)
      ..write(obj.searchUrl)
      ..writeByte(4)
      ..write(obj.safeModeTag)
      ..writeByte(5)
      ..write(obj.safeModeUrl)
      ..writeByte(6)
      ..write(obj.safeMode)
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

_$_ServerData _$_$_ServerDataFromJson(Map<String, dynamic> json) {
  return _$_ServerData(
    name: json['name'] as String,
    homepage: json['homepage'] as String,
    postUrl: json['post_url'] as String,
    searchUrl: json['search_url'] as String,
    safeModeTag: json['safe_mode_tag'] as String?,
    safeModeUrl: json['safe_mode_url'] as String?,
    safeMode: json['safe_mode'] as String?,
    tagSuggestionUrl: json['tag_suggestion_url'] as String?,
  );
}

Map<String, dynamic> _$_$_ServerDataToJson(_$_ServerData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'homepage': instance.homepage,
      'post_url': instance.postUrl,
      'search_url': instance.searchUrl,
      'safe_mode_tag': instance.safeModeTag,
      'safe_mode_url': instance.safeModeUrl,
      'safe_mode': instance.safeMode,
      'tag_suggestion_url': instance.tagSuggestionUrl,
    };
