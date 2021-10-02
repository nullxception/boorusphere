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
      postUrl: fields[2] == null ? '' : fields[2] as String?,
      searchUrl: fields[3] == null ? '' : fields[3] as String,
      tagSuggestionUrl: fields[7] == null ? '' : fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, _$_ServerData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.homepage)
      ..writeByte(2)
      ..write(obj.postUrl)
      ..writeByte(3)
      ..write(obj.searchUrl)
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

_$_ServerData _$$_ServerDataFromJson(Map<String, dynamic> json) =>
    _$_ServerData(
      name: json['name'] as String,
      homepage: json['homepage'] as String,
      postUrl: json['postUrl'] as String?,
      searchUrl: json['searchUrl'] as String,
      tagSuggestionUrl: json['tagSuggestionUrl'] as String?,
    );

Map<String, dynamic> _$$_ServerDataToJson(_$_ServerData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'homepage': instance.homepage,
      'postUrl': instance.postUrl,
      'searchUrl': instance.searchUrl,
      'tagSuggestionUrl': instance.tagSuggestionUrl,
    };
