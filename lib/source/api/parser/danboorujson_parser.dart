import 'package:dio/dio.dart';

import '../../../entity/post.dart';
import '../../../utils/extensions/map.dart';
import 'booru_parser.dart';

class DanbooruJsonParser extends BooruParser {
  DanbooruJsonParser(super.server);

  @override
  bool canParsePage(Response res) {
    final data = res.data;
    return data is List && data.toString().contains('preview_file_url');
  }

  @override
  List<Post> parsePage(res) {
    final entries = List.from(res.data);
    final result = <Post>[];
    for (final post in entries.whereType<Map<String, dynamic>>()) {
      final id = post.tryGet('id', orElse: -1);
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      final originalFile = post.tryGet('file_url', orElse: '');
      final sampleFile = post.tryGet('large_file_url', orElse: '');
      final previewFile = post.tryGet('preview_file_url', orElse: '');
      final tags = post.tryGet('tag_string', orElse: <String>[]);
      final width = post.tryGet('image_width', orElse: -1);
      final height = post.tryGet('image_height', orElse: -1);
      final rating = post.tryGet('rating', orElse: 'q');
      final source = post.tryGet('source', orElse: '');
      final tagsArtist = post.tryGet('tag_string_artist', orElse: <String>[]);
      final tagsCharacter =
          post.tryGet('tag_string_character', orElse: <String>[]);
      final tagsCopyright =
          post.tryGet('tag_string_copyright', orElse: <String>[]);
      final tagsGeneral = post.tryGet('tag_string_general', orElse: <String>[]);
      final tagsMeta = post.tryGet('tag_string_meta', orElse: <String>[]);

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
            sampleWidth: 0,
            sampleHeight: 0,
            previewWidth: 0,
            previewHeight: 0,
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
    return data is List &&
        data.toString().contains('name') &&
        data.toString().contains('post_count');
  }

  @override
  Set<String> parseSuggestion(Response res) {
    final entries = List.from(res.data);
    final result = <String>{};
    for (final Map<String, dynamic> entry in entries) {
      final tag = entry.tryGet('name', orElse: '');
      final postCount = entry.tryGet('post_count', orElse: 0);
      if (postCount > 0) result.add(tag);
    }

    return result;
  }
}
