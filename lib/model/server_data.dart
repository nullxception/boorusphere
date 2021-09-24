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
    @HiveField(2, defaultValue: '') String? postUrl,
    @HiveField(3, defaultValue: '') required String searchUrl,
    @HiveField(7, defaultValue: '') String? tagSuggestionUrl,
  }) = _ServerData;

  factory ServerData.fromJson(Map<String, dynamic> json) =>
      _$ServerDataFromJson(json);

  const ServerData._();

  bool get canSuggestTags => tagSuggestionUrl?.contains('{tag-part}') ?? false;

  Uri? composePostUrl(int id) {
    if (postUrl == null) return null;

    final url = '$homepage/$postUrl';
    return Uri.parse(url.replaceAll('{post-id}', id.toString()));
  }

  Uri composeSearchUrl(ServerQuery query, int page) {
    return Uri.parse(
      '$homepage/$searchUrl'
          .replaceAll(
              '{tags}',
              query.safeMode && !homepage.contains('//safe')
                  ? '${query.tags} rating:safe'
                  : query.tags)
          .replaceAll('{page-id}', page.toString())
          .replaceAll('{post-limit}', '40'),
    );
  }

  Uri composeSuggestionUrl(String query) {
    final url = '$homepage/$tagSuggestionUrl';
    if (canSuggestTags) {
      return Uri.parse(url.replaceAll('{tag-part}', query));
    } else {
      throw Exception('no suggestion config for server $name');
    }
  }

  static const String defaultTag = '*';
}
