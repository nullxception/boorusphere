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
      final id = post.take(['id'], orElse: -1);
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      final originalFile = post.take(['file_url'], orElse: '');
      final sampleFile =
          post.take(['large_file_url', 'sample_url'], orElse: '');
      final previewFile =
          post.take(['preview_url', 'preview_file_url'], orElse: '');
      final tags = post.take(['tags', 'tag_string'], orElse: <String>[]);
      final width = post.take(['image_width', 'width'], orElse: -1);
      final height = post.take(['image_height', 'height'], orElse: -1);
      final sampleWidth = post.take(['sample_width'], orElse: -1);
      final sampleHeight = post.take(['sample_height'], orElse: -1);
      final previewWidth = post.take(['preview_width'], orElse: -1);
      final previewHeight = post.take(['preview_height'], orElse: -1);
      final rating = post.take(['rating'], orElse: 'q');
      final source = post.take(['source'], orElse: '');
      final tagsArtist = post.take(['tag_string_artist'], orElse: <String>[]);
      final tagsCharacter =
          post.take(['tag_string_character'], orElse: <String>[]);
      final tagsCopyright =
          post.take(['tag_string_copyright'], orElse: <String>[]);
      final tagsGeneral = post.take(['tag_string_general'], orElse: <String>[]);
      final tagsMeta = post.take(['tag_string_meta'], orElse: <String>[]);

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
            tagsArtist: tagsArtist,
            tagsCharacter: tagsCharacter,
            tagsCopyright: tagsCopyright,
            tagsGeneral: tagsGeneral,
            tagsMeta: tagsMeta,
          ),
        );
      }
    }

    return result;
  }

  @override
  bool canParseSuggestion(Response res) {
    final data = res.data;
    return data is Map &&
        data.toString().contains('tag') &&
        data.toString().contains('name') &&
        data.toString().contains('count');
  }

  @override
  Set<String> parseSuggestion(Response res) {
    final entries = List.from(res.data['tag']);

    final result = <String>{};
    for (final Map<String, dynamic> entry in entries) {
      final tag = entry.take(['name'], orElse: '');
      final postCount = entry.take(['count'], orElse: 0);
      if (postCount > 0) result.add(tag);
    }

    return result;
  }
}
