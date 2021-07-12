import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'server_query.dart';

part 'server_data.freezed.dart';
part 'server_data.g.dart';

@freezed
class ServerData with _$ServerData {
  @HiveType(typeId: 2, adapterName: 'ServersAdapter')
  const factory ServerData({
    @HiveField(0, defaultValue: '') required String name,
    @HiveField(1, defaultValue: '') required String homepage,
    @HiveField(2, defaultValue: '')
    @JsonKey(name: 'post_url')
        required String postUrl,
    @HiveField(3, defaultValue: '')
    @JsonKey(name: 'search_url')
        required String searchUrl,
    @HiveField(4, defaultValue: '')
    @JsonKey(name: 'safe_mode_tag')
        String? safeModeTag,
    @HiveField(5, defaultValue: '')
    @JsonKey(name: 'safe_mode_url')
        String? safeModeUrl,
    @HiveField(6, defaultValue: '')
    @JsonKey(name: 'safe_mode')
        String? safeMode,
    @HiveField(7, defaultValue: '')
    @JsonKey(name: 'tag_suggestion_url')
        String? tagSuggestionUrl,
  }) = _ServerData;

  factory ServerData.fromJson(Map<String, dynamic> json) =>
      _$ServerDataFromJson(json);

  const ServerData._();

  bool get canSuggestTags => tagSuggestionUrl?.contains('{tag-part}') ?? false;

  Uri composePostUrl(int id) {
    final url = '$homepage/$postUrl';
    return Uri.parse(url.replaceAll('{post-id}', id.toString()));
  }

  Uri composeSearchUrl(ServerQuery query) {
    var _url = '$homepage/$searchUrl';
    var _tags = query.tags;
    if (query.safeMode && safeMode == 'url') {
      _url = '$homepage/$safeModeUrl';
    } else if (query.safeMode && safeMode == 'tag') {
      _tags += ' $safeModeTag';
    }

    return Uri.parse(
      _url
          .replaceAll('{tags}', _tags)
          .replaceAll('{page-id}', query.page.toString())
          .replaceAll('{post-limit}', query.limit.toString()),
    );
  }

  Uri composeSuggestionUrl(String query) {
    final url = '$homepage/$tagSuggestionUrl';
    final _query = query.trim();
    if (_query.isNotEmpty && canSuggestTags) {
      return Uri.parse(url.replaceAll('{tag-part}', _query));
    } else {
      throw Exception('no suggestion config for server $name');
    }
  }

  static const String defaultTag = '*';
}
