import 'dart:collection';
import 'dart:convert';

import 'package:boorusphere/data/repository/booru/entity/booru_error.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/utils/booru_util.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/utils/extensions/pick.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:xml2json/xml2json.dart';

class GelbooruXmlParser extends BooruParser {
  GelbooruXmlParser(this.server);
  @override
  final id = 'Gelbooru.xml';

  @override
  final postUrl = 'index.php?page=post&s=view&id={post-id}';

  @override
  final suggestionQuery =
      'index.php?page=dapi&s=tag&q=index&name_pattern=%{tag-part}%&orderby=count&limit={post-limit}';

  @override
  final searchQuery =
      'index.php?page=dapi&s=post&q=index&tags={tags}&pid={page-id}&limit={post-limit}';

  @override
  final ServerData server;

  @override
  bool canParsePage(Response res) {
    final data = res.data;
    final rawString = data.toString();
    return data is String &&
        rawString.contains('<?xml') &&
        rawString.contains('<posts ') &&
        rawString.contains('<post>') &&
        rawString.contains('<file_url>');
  }

  @override
  List<Post> parsePage(res) {
    final entries = [];
    final xjson = Xml2Json();
    xjson.parse(res.data.replaceAll('\\', ''));

    final fromParkerConv = jsonDecode(xjson.toParker());
    if (!fromParkerConv.values.first.keys.contains('post')) {
      throw BooruError.empty;
    }

    final posts = fromParkerConv.values.first['post'];

    if (posts is LinkedHashMap) {
      entries.add(posts);
    } else if (posts is List) {
      entries.addAll(posts);
    } else {
      throw BooruError.empty;
    }

    final result = <Post>[];

    for (final post in entries.whereType<Map<String, dynamic>>()) {
      final id = pick(post, 'id').asIntOrNull() ?? -1;
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      final originalFile = pick(post, 'file_url').asStringOrNull() ?? '';
      final sampleFile = pick(post, 'sample_url').asStringOrNull() ?? '';
      final previewFile = pick(post, 'preview_url').asStringOrNull() ?? '';
      final tags = pick(post, 'tags').toWordList();
      final width = pick(post, 'width').asIntOrNull() ?? -1;
      final height = pick(post, 'height').asIntOrNull() ?? -1;
      final sampleWidth = pick(post, 'sample_width').asIntOrNull() ?? -1;
      final sampleHeight = pick(post, 'sample_height').asIntOrNull() ?? -1;
      final previewWidth = pick(post, 'preview_width').asIntOrNull() ?? -1;
      final previewHeight = pick(post, 'preview_height').asIntOrNull() ?? -1;
      final rating = pick(post, 'rating').asStringOrNull() ?? 'q';
      final source = pick(post, 'source').asStringOrNull() ?? '';
      final score = pick(post, 'score').asIntOrNull() ?? 0;

      final hasFile = originalFile.isNotEmpty && previewFile.isNotEmpty;
      final hasContent = width > 0 && height > 0;
      final postUrl = server.postUrlOf(id);

      if (hasFile && hasContent) {
        result.add(
          Post(
            id: id,
            originalFile: BooruUtil.normalizeUrl(server, originalFile),
            sampleFile: BooruUtil.normalizeUrl(server, sampleFile),
            previewFile: BooruUtil.normalizeUrl(server, previewFile),
            tags: tags.map(BooruUtil.decodeTag).toList(),
            width: width,
            height: height,
            sampleWidth: sampleWidth,
            sampleHeight: sampleHeight,
            previewWidth: previewWidth,
            previewHeight: previewHeight,
            serverId: server.id,
            postUrl: postUrl,
            rateValue: rating.isEmpty ? 'q' : rating,
            source: source,
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
    return data is String &&
        rawString.contains('<?xml') &&
        rawString.contains('<tags') &&
        rawString.contains('<tag>') &&
        rawString.contains('<name>');
  }

  @override
  Set<String> parseSuggestion(Response res) {
    final data = res.data;
    final entries = [];

    final xjson = Xml2Json();
    xjson.parse(data.replaceAll('\\', ''));

    final fromParkerConv = jsonDecode(xjson.toParker());
    if (!fromParkerConv.values.first.keys.contains('tag')) {
      throw StateError('no tags');
    }

    final tags = fromParkerConv.values.first['tag'];

    if (tags is LinkedHashMap) {
      entries.add(tags);
    } else if (tags is List) {
      entries.addAll(tags);
    } else {
      throw StateError('no tags');
    }

    final result = <String>{};
    for (final Map<String, dynamic> entry in entries) {
      final tag = pick(entry, 'name').asStringOrNull() ?? '';
      final postCount = pick(entry, 'count').asIntOrNull() ?? 0;
      if (postCount > 0 && tag.isNotEmpty) {
        result.add(BooruUtil.decodeTag(tag));
      }
    }

    return result;
  }
}
