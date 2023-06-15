import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'server.freezed.dart';
part 'server.g.dart';

@freezed
class Server with _$Server {
  @HiveType(typeId: 2, adapterName: 'ServerAdapter')
  const factory Server({
    @HiveField(0, defaultValue: '') @Default('') String id,
    @HiveField(1, defaultValue: '') @Default('') String homepage,
    @HiveField(2, defaultValue: '') @Default('') String postUrl,
    @HiveField(3, defaultValue: '') @Default('') String searchUrl,
    @HiveField(4, defaultValue: '') @Default('') String apiAddr,
    @HiveField(7, defaultValue: '') @Default('') String tagSuggestionUrl,
    @HiveField(8, defaultValue: '') @Default('') String alias,
    @HiveField(9, defaultValue: '') @Default('') String searchParserId,
    @HiveField(10, defaultValue: '') @Default('') String suggestionParserId,
  }) = _Server;

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);

  const Server._();

  bool get canSuggestTags => tagSuggestionUrl.contains('{tag-part}');

  String searchUrlOf(PageOption option, {required int page}) {
    String tags =
        option.query.trim().isEmpty ? Server.defaultTag : option.query.trim();
    if (searchUrl.contains(RegExp(r'.*[\?&]offset=.*#opt\?json=1'))) {
      // Szurubooru has exclusive-way (but still same shit) of rating
      tags += ' ${_szuruRateString(option.searchRating)}';
    } else if (searchUrl.contains('api/v1/json/search')) {
      // booru-on-rails didn't support rating
      tags = tags.replaceAll('rating:', '');
    } else {
      tags += ' ${_rateString(option.searchRating)}';
    }

    return '$homepage/$searchUrl'
        .replaceAll('{tags}', Uri.encodeComponent(tags.trim()))
        .replaceAll('{page-id}', '$page')
        .replaceAll('{post-offset}', (page * option.limit).toString())
        .replaceAll('{post-limit}', '${option.limit}');
  }

  String suggestionUrlsOf(String query) {
    final url = '$homepage/$tagSuggestionUrl'
        .replaceAll('{post-limit}', '$tagSuggestionLimit')
        .replaceAll('{tag-limit}', '$tagSuggestionLimit');

    final encq = Uri.encodeComponent(query);
    if (!canSuggestTags) {
      throw Exception('no suggestion config for server $name');
    }

    if (query.isEmpty) {
      if (url.contains('name_pattern=')) {
        return url.replaceAll(RegExp(r'[*%]*{tag-part}[*%]*'), '');
      }
      return url.replaceAll(RegExp(r'[*%]*{tag-part}[*%]*'), '*');
    }
    return url.replaceAll('{tag-part}', encq);
  }

  String postUrlOf(int id) {
    if (postUrl.isEmpty) {
      return homepage;
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

  static const Server empty = Server();
  static const String defaultTag = '*';
  static const tagSuggestionLimit = 20;
}

String _rateString(BooruRating searchRating) {
  return switch (searchRating) {
    BooruRating.safe => 'rating:safe',
    BooruRating.questionable => 'rating:questionable',
    BooruRating.explicit => 'rating:explicit',
    BooruRating.sensitive => 'rating:sensitive',
    _ => ''
  };
}

String _szuruRateString(BooruRating searchRating) {
  return switch (searchRating) {
    BooruRating.safe => 'safety:safe',
    BooruRating.questionable => 'safety:sketchy',
    BooruRating.sensitive || BooruRating.explicit => 'safety:unsafe',
    _ => ''
  };
}
