import 'package:dio/dio.dart';

import '../../../entity/post.dart';
import '../../../utils/extensions/map.dart';
import 'booru_parser.dart';

class GelbooruJsonParser extends BooruParser {
  GelbooruJsonParser(super.server);

  @override
  bool canParsePage(Response res) {
    final data = res.data;
    return data is Map && data.keys.contains('post');
  }

  @override
  List<Post> parsePage(res) {
    final entries = List.from(res.data['post']);
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
    return data is Map && data.keys.contains('tag');
  }

  @override
  Set<String> parseSuggestion(Response res) {
    final entries = List.from(res.data['tag']);

    final result = <String>{};
    for (final Map<String, dynamic> entry in entries) {
      final tag = entry.tryGet('name', orElse: '');
      final postCount = entry.tryGet('count', orElse: 0);
      if (postCount > 0) result.add(tag);
    }

    return result;
  }
}
