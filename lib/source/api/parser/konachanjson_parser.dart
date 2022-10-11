import 'package:dio/dio.dart';

import '../../../entity/post.dart';
import '../../../utils/extensions/map.dart';
import 'booru_parser.dart';

class KonachanJsonParser extends BooruParser {
  KonachanJsonParser(super.server);

  @override
  bool canParsePage(Response res) {
    final data = res.data;
    return data is List && data.toString().contains('preview_url');
  }

  @override
  List<Post> parsePage(res) {
    final entries = List.from(res.data);
    final result = <Post>[];
    for (final post in entries.whereType<Map<String, dynamic>>()) {
      final id = post.take(['id'], orElse: -1);
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      final originalFile = post.take(['file_url'], orElse: '');
      final sampleFile = post.take(['sample_url'], orElse: '');
      final previewFile = post.take(['preview_url'], orElse: '');
      final tags = post.take(['tags'], orElse: <String>[]);
      final width = post.take(['width'], orElse: -1);
      final height = post.take(['height'], orElse: -1);
      final sampleWidth = post.take(['sample_width'], orElse: -1);
      final sampleHeight = post.take(['sample_height'], orElse: -1);
      final previewWidth = post.take(['preview_width'], orElse: -1);
      final previewHeight = post.take(['preview_height'], orElse: -1);
      final rating = post.take(['source'], orElse: 'q');
      final source = post.take(['rating'], orElse: '');

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
    return data is List &&
        data.toString().contains('name') &&
        data.toString().contains('count');
  }

  @override
  Set<String> parseSuggestion(Response res) {
    final entries = List.from(res.data);
    final result = <String>{};
    for (final Map<String, dynamic> entry in entries) {
      final tag = entry.take(['tag'], orElse: '');
      final postCount = entry.take(['count'], orElse: 0);
      if (postCount > 0) result.add(tag);
    }

    return result;
  }
}
