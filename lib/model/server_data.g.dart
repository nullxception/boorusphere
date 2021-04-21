// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_data.dart';

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
