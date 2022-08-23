import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_data.g.dart';

@HiveType(typeId: 2, adapterName: 'ServersAdapter')
@JsonSerializable()
class ServerData {
  const ServerData({
    this.name = '',
    this.homepage = '',
    this.postUrl = '',
    this.searchUrl = '',
    this.apiAddr = '',
    this.tagSuggestionUrl = '',
  });

  factory ServerData.fromJson(Map<String, dynamic> json) =>
      _$ServerDataFromJson(json);

  @HiveField(0, defaultValue: '')
  final String name;
  @HiveField(1, defaultValue: '')
  final String homepage;
  @HiveField(2, defaultValue: '')
  final String postUrl;
  @HiveField(3, defaultValue: '')
  final String searchUrl;
  @HiveField(4, defaultValue: '')
  final String apiAddr;
  @HiveField(7, defaultValue: '')
  final String tagSuggestionUrl;

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

  ServerData copyWith({
    String? name,
    String? homepage,
    String? postUrl,
    String? searchUrl,
    String? apiAddr,
    String? tagSuggestionUrl,
  }) {
    return ServerData(
      name: name ?? this.name,
      homepage: homepage ?? this.homepage,
      postUrl: postUrl ?? this.postUrl,
      searchUrl: searchUrl ?? this.searchUrl,
      apiAddr: apiAddr ?? this.apiAddr,
      tagSuggestionUrl: tagSuggestionUrl ?? this.tagSuggestionUrl,
    );
  }

  @override
  bool operator ==(covariant ServerData other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.homepage == homepage &&
        other.postUrl == postUrl &&
        other.searchUrl == searchUrl &&
        other.apiAddr == apiAddr &&
        other.tagSuggestionUrl == tagSuggestionUrl;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        homepage.hashCode ^
        postUrl.hashCode ^
        searchUrl.hashCode ^
        apiAddr.hashCode ^
        tagSuggestionUrl.hashCode;
  }

  static const ServerData empty = ServerData();
  static const String defaultTag = '*';
}
