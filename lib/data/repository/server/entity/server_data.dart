import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'server_data.freezed.dart';
part 'server_data.g.dart';

@freezed
class ServerData with _$ServerData {
  @HiveType(typeId: 2, adapterName: 'ServersAdapter')
  const factory ServerData({
    @HiveField(0, defaultValue: '') @Default('') String id,
    @HiveField(1, defaultValue: '') @Default('') String homepage,
    @HiveField(2, defaultValue: '') @Default('') String postUrl,
    @HiveField(3, defaultValue: '') @Default('') String searchUrl,
    @HiveField(4, defaultValue: '') @Default('') String apiAddr,
    @HiveField(7, defaultValue: '') @Default('') String tagSuggestionUrl,
    @HiveField(8, defaultValue: '') @Default('') String alias,
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

  List<String> suggestionUrlsOf(String query) {
    final url = '$homepage/$tagSuggestionUrl'
        .replaceAll('{post-limit}', '20')
        .replaceAll('{tag-limit}', '20');

    if (canSuggestTags) {
      if (query.isEmpty) {
        return [url.replaceAll(RegExp(r'[*%]{tag-part}[*%]'), '')];
      }
      return [
        url.replaceAll(RegExp(r'[*%]{tag-part}'), query),
        url.replaceAll(RegExp(r'{tag-part}[*%]'), query),
        url.replaceAll('{tag-part}', query),
      ];
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
    final asKey = id.replaceAll(RegExp('[^A-Za-z0-9]'), '-');
    return '@${asKey.toLowerCase()}';
  }

  String get apiAddress => apiAddr.isEmpty ? homepage : apiAddr;

  String get name => alias.isNotEmpty ? alias : id;

  static const ServerData empty = ServerData();
  static const String defaultTag = '*';
}
