import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:xml2json/xml2json.dart';

import '../../../entity/post.dart';
import '../../../entity/sphere_exception.dart';
import '../../../utils/extensions/map.dart';
import 'booru_parser.dart';

class GelbooruXmlParser extends BooruParser {
  GelbooruXmlParser(super.server);
  @override
  bool canParsePage(Response res) {
    final data = res.data;
    return data is String && data.toString().contains('<?xml');
  }

  @override
  List<Post> parsePage(res) {
    const cantParse = SphereException(message: 'Cannot parse result');

    final entries = [];
    final xjson = Xml2Json();
    xjson.parse(res.data.replaceAll('\\', ''));

    final jsonObj = jsonDecode(xjson.toGData());
    if (!jsonObj.values.first.keys.contains('post')) {
      throw cantParse;
    }

    final posts = jsonObj.values.first['post'];
    if (posts is LinkedHashMap) {
      entries.add(posts);
    } else if (posts is List) {
      entries.addAll(posts);
    } else {
      throw cantParse;
    }

    final result = <Post>[];

    for (final post in entries.whereType<Map<String, dynamic>>()) {
      final id = post.tryGet('id', orElse: -1);
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      final originalFile = post.tryGet('file_url', orElse: '');
      final sampleFile = post.tryGet('sample_url', orElse: '');
      final previewFile = post.tryGet('preview_url', orElse: '');
      final tags = post.tryGet('tags', orElse: <String>[]);
      final width = post.tryGet('width', orElse: -1);
      final height = post.tryGet('height', orElse: -1);
      final sampleWidth = post.tryGet('sample_width', orElse: -1);
      final sampleHeight = post.tryGet('sample_height', orElse: -1);
      final previewWidth = post.tryGet('preview_width', orElse: -1);
      final previewHeight = post.tryGet('preview_height', orElse: -1);
      final rating = post.tryGet('rating', orElse: 'q');
      final source = post.tryGet('source', orElse: '');

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
    return data is String &&
        data.toString().contains('<?xml') &&
        data.toString().contains('<tag');
  }

  @override
  Set<String> parseSuggestion(Response res) {
    final data = res.data;
    final entries = [];

    final xjson = Xml2Json();
    xjson.parse(data.replaceAll('\\', ''));

    final jsonObj = jsonDecode(xjson.toGData());
    if (!jsonObj.values.first.keys.contains('tag')) {
      throw StateError('no tags');
    }

    final tags = jsonObj.values.first['tag'];
    if (tags is LinkedHashMap) {
      entries.add(tags);
    } else if (tags is List) {
      entries.addAll(tags);
    } else {
      throw StateError('no tags');
    }

    final result = <String>{};
    for (final Map<String, dynamic> entry in entries) {
      final tag = entry.tryGet('name', orElse: '');
      final postCount = entry.tryGet('count', orElse: 0);
      if (postCount > 0) result.add(tag);
    }

    return result;
  }
}
