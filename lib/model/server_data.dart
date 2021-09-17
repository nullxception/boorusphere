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
    @HiveField(2, defaultValue: '') required String postUrl,
    @HiveField(3, defaultValue: '') required String searchUrl,
    @HiveField(6, defaultValue: '') String? safeMode,
    @HiveField(7, defaultValue: '') String? tagSuggestionUrl,
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
    if (query.safeMode &&
        safeMode != null &&
        safeMode!.contains(RegExp('[?=/]'))) {
      _url = '$homepage/$safeMode';
    } else if (query.safeMode && safeMode != null) {
      _tags += ' $safeMode';
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
    final trquery = query.trim();
    if (canSuggestTags) {
      return Uri.parse(url.replaceAll('{tag-part}', trquery));
    } else {
      throw Exception('no suggestion config for server $name');
    }
  }

  static const String defaultTag = '*';
}
