import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/utils/booru_util.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/utils/extensions/pick.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';

class DanbooruJsonParser extends BooruParser {
  DanbooruJsonParser(this.server);

  @override
  final postUrl = 'posts/{post-id}';

  @override
  final suggestionQuery =
      'tags.json?search[name_matches]=*{tag-part}*&search[order]=count&limit={post-limit}';

  @override
  final searchQuery =
      'posts.json?tags={tags}&page={page-id}&limit={post-limit}';

  @override
  final ServerData server;

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
            tags: tags,
            width: width,
            height: height,
            serverId: server.id,
            postUrl: postUrl,
            rateValue: rating.isEmpty ? 'q' : rating,
            source: source,
            tagsArtist: tagsArtist.map(BooruUtil.decodeTag).toList(),
            tagsCharacter: tagsCharacter.map(BooruUtil.decodeTag).toList(),
            tagsCopyright: tagsCopyright.map(BooruUtil.decodeTag).toList(),
            tagsGeneral: tagsGeneral.map(BooruUtil.decodeTag).toList(),
            tagsMeta: tagsMeta.map(BooruUtil.decodeTag).toList(),
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
    return data is List &&
        data.toString().contains('name') &&
        data.toString().contains('post_count');
  }

  @override
  Set<String> parseSuggestion(Response res) {
    final entries = List.from(res.data);
    final result = <String>{};
    for (final Map<String, dynamic> entry in entries) {
      final tag = pick(entry, 'name').asStringOrNull() ?? '';
      final postCount = pick(entry, 'post_count').asIntOrNull() ?? 0;
      if (postCount > 0 && tag.isNotEmpty) {
        result.add(BooruUtil.decodeTag(tag));
      }
    }

    return result;
  }
}
