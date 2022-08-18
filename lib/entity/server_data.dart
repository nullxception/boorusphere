import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'server_data.freezed.dart';
part 'server_data.g.dart';

@freezed
class ServerData with _$ServerData {
  @HiveType(typeId: 2, adapterName: 'ServersAdapter')
  const factory ServerData({
    @HiveField(0, defaultValue: '') @Default('') String name,
    @HiveField(1, defaultValue: '') @Default('') String homepage,
    @HiveField(2, defaultValue: '') @Default('') String postUrl,
    @HiveField(3, defaultValue: '') @Default('') String searchUrl,
    @HiveField(4, defaultValue: '') @Default('') String apiAddr,
    @HiveField(7, defaultValue: '') @Default('') String tagSuggestionUrl,
  }) = _ServerData;

  factory ServerData.fromJson(Map<String, dynamic> json) =>
      _$ServerDataFromJson(json);

  const ServerData._();

  bool get canSuggestTags => tagSuggestionUrl.contains('{tag-part}');

  String searchUrlOf(String query, int page, bool safeMode, int postLimit) {
    final tags = query.trim().isEmpty ? ServerData.defaultTag : query.trim();

    return '$homepage/$searchUrl'
        .replaceAll(
            '{tags}',
            safeMode && !homepage.contains('//safe')
                ? '$tags rating:safe'
                : tags)
        .replaceAll('{page-id}', '$page')
        .replaceAll('{post-limit}', '$postLimit');
  }

  String suggestionUrlOf(String query) {
    final url = '$homepage/$tagSuggestionUrl';
    if (canSuggestTags) {
      if (query.isEmpty) {
        return url.replaceAll(RegExp(r'[*%]{tag-part}[*%]'), '');
      }
      return url.replaceAll('{tag-part}', query);
    } else {
      throw Exception('no suggestion config for server $name');
    }
  }

  String postUrlOf(int id) {
    if (postUrl.isEmpty) {
      return '';
    }

    final query = postUrl.replaceAll('{post-id}', id.toString());
    return '$homepage/$query';
  }

  // Key used in hive box
  String get key {
    final asKey = name.replaceAll(RegExp('[^A-Za-z0-9]'), '-');
    return '@${asKey.toLowerCase()}';
  }

  String get apiAddress => apiAddr.isEmpty ? homepage : apiAddr;

  static const ServerData empty =
      ServerData(name: '', homepage: '', searchUrl: '');
  static const String defaultTag = '*';
}
