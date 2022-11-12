import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/utils/extensions/pick.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';

class DanbooruJsonParser extends BooruParser {
  DanbooruJsonParser(super.server);

  @override
  bool canParsePage(Response res) {
    final data = res.data;
    return data is List && data.toString().contains('preview_file_url');
  }

  @override
  List<Post> parsePage(res) {
    super.parsePage(res);
    final entries = List.from(res.data);
    final result = <Post>[];
    for (final post in entries.whereType<Map<String, dynamic>>()) {
      final id = pick(post, 'id').asIntOrNull() ?? -1;
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      String originalFile = pick(post, 'file_url').asStringOrNull() ?? '';
      final sampleFile = pick(post, 'large_file_url').asStringOrNull() ?? '';
      final previewFile = pick(post, 'preview_file_url').asStringOrNull() ?? '';
      final rating = pick(post, 'rating').asStringOrNull() ?? 'q';
      final source = pick(post, 'source').asStringOrNull() ?? '';
      final width = pick(post, 'image_width').asIntOrNull() ?? -1;
      final height = pick(post, 'image_height').asIntOrNull() ?? -1;
      final tags = pick(post, 'tag_string').toWordList();
      final tagsArtist = pick(post, 'tag_string_artist').toWordList();
      final tagsCharacter = pick(post, 'tag_string_character').toWordList();
      final tagsCopyright = pick(post, 'tag_string_copyright').toWordList();
      final tagsGeneral = pick(post, 'tag_string_general').toWordList();
      final tagsMeta = pick(post, 'tag_string_meta').toWordList();

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
    super.parseSuggestion(res);

    final entries = List.from(res.data);
    final result = <String>{};
    for (final Map<String, dynamic> entry in entries) {
      final tag = pick(entry, 'name').asStringOrNull() ?? '';
      final postCount = pick(entry, 'post_count').asIntOrNull() ?? 0;
      if (postCount > 0) result.add(tag);
    }

    return result;
  }
}
