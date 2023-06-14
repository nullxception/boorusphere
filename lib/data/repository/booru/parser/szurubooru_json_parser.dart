import 'dart:convert';

import 'package:boorusphere/data/repository/booru/entity/booru_auth.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/utils/booru_util.dart';
import 'package:boorusphere/data/repository/server/entity/server.dart';
import 'package:boorusphere/data/repository/server/entity/server_auth.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';

class SzurubooruJsonParser extends BooruParser {
  @override
  final id = 'Szurubooru.json';

  @override
  final searchQuery =
      'api/posts/?offset={post-offset}&limit={post-limit}&query={tags}';

  @override
  final suggestionQuery =
      'api/tags/?offset=0&limit={post-limit}&query={tag-part}*';

  @override
  final postUrl = 'post/{post-id}';

  @override
  final headers = {
    'Accept': 'application/json',
    'Content-type': 'application/json',
  };

  @override
  BooruAuth buildAuth(ServerAuth auth) {
    if (auth == ServerAuth.empty) {
      return BooruAuth.none;
    }

    final encKey = base64Encode(utf8.encode('${auth.userId}:${auth.userKey}'));
    return BooruAuth(
      type: BooruAuthType.headers,
      data: {
        'Authorization': 'Token $encKey',
      },
    );
  }

  @override
  bool canParsePage(Response res) {
    final data = res.data;
    final rawString = data.toString();
    return data is Map &&
        data.containsKey('results') &&
        rawString.contains('contentUrl');
  }

  @override
  List<Post> parsePage(Server server, res) {
    final entries = List.from(res.data['results']);
    final result = <Post>[];
    for (final post in entries.whereType<Map<String, dynamic>>()) {
      final id = pick(post, 'id').asIntOrNull() ?? -1;
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      final originalFile = pick(post, 'contentUrl').asStringOrNull() ?? '';
      final previewFile = pick(post, 'thumbnailUrl').asStringOrNull() ?? '';
      final width = pick(post, 'canvasWidth').asIntOrNull() ?? -1;
      final height = pick(post, 'canvasHeight').asIntOrNull() ?? -1;
      final rating = pick(post, 'safety').asStringOrNull() ?? 'q';
      final score = pick(post, 'score').asIntOrNull() ?? 0;

      final tags = pick(post, 'tags').asListOrEmpty((x) {
        final obj = x.asMapOrEmpty()['names'];
        if (obj is List) {
          return obj.map((e) => BooruUtil.decodeTag(e.toString()));
        }

        return <String>[];
      }).fold(<String>{}, (x, a) => {...x, ...a});

      final hasFile = originalFile.isNotEmpty && previewFile.isNotEmpty;
      final hasContent = width > 0 && height > 0;
      final postUrl = server.postUrlOf(id);

      if (hasFile && hasContent) {
        result.add(
          Post(
            id: id,
            originalFile: BooruUtil.normalizeUrl(server, originalFile),
            previewFile: BooruUtil.normalizeUrl(server, previewFile),
            tags: tags.toList(),
            width: width,
            height: height,
            serverId: server.id,
            postUrl: postUrl,
            rateValue: rating.isEmpty ? 'q' : rating,
            score: score,
          ),
        );
      }
    }

    return result;
  }

  @override
  bool canParseSuggestion(Response res) {
    final data = res.data;
    final rawString = data.toString();
    return data is Map &&
        data.containsKey('results') &&
        rawString.contains('names');
  }

  @override
  Set<String> parseSuggestion(Server server, Response res) {
    final entries = List.from(res.data['results']);
    final result = <String>{};
    for (final entry in entries.whereType<Map<String, dynamic>>()) {
      final tags = pick(entry, 'names').asListOrEmpty((x) => x.asString());
      final usages = pick(entry, 'usages').asIntOrNull() ?? 0;
      if (usages > 0) {
        result.addAll(tags);
      }
    }

    return result;
  }
}
