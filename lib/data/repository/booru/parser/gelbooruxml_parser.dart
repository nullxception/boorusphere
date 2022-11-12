import 'dart:collection';
import 'dart:convert';

import 'package:boorusphere/data/entity/sphere_exception.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/utils/extensions/pick.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:xml2json/xml2json.dart';

class GelbooruXmlParser extends BooruParser {
  GelbooruXmlParser(super.server);
  @override
  bool canParsePage(Response res) {
    final data = res.data;
    final rawString = data.toString();
    return data is String &&
        rawString.contains('<?xml') &&
        rawString.contains('<file_url>');
  }

  @override
  List<Post> parsePage(res) {
    super.parsePage(res);
    const cantParse = SphereException(message: 'Cannot parse result');

    final entries = [];
    final xjson = Xml2Json();
    xjson.parse(res.data.replaceAll('\\', ''));

    final fromParkerConv = jsonDecode(xjson.toParker());
    if (!fromParkerConv.values.first.keys.contains('post')) {
      throw cantParse;
    }

    final posts = fromParkerConv.values.first['post'];

    if (posts is LinkedHashMap) {
      entries.add(posts);
    } else if (posts is List) {
      entries.addAll(posts);
    } else {
      throw cantParse;
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

      final hasFile = originalFile.isNotEmpty && previewFile.isNotEmpty;
      final hasContent = width > 0 && height > 0;
      final postUrl = id < 0 ? '' : server.postUrlOf(id);

      if (hasFile && hasContent) {
        result.add(
          Post(
            id: id,
            originalFile: normalizeUrl(originalFile),
            sampleFile: normalizeUrl(sampleFile),
            previewFile: normalizeUrl(previewFile),
            tags: tags,
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
        rawString.contains('<tag') &&
        rawString.contains('<name>');
  }

  @override
  Set<String> parseSuggestion(Response res) {
    super.parseSuggestion(res);

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
      if (postCount > 0) result.add(tag);
    }

    return result;
  }
}
