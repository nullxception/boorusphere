import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/utils/extensions/pick.dart';
import 'package:collection/collection.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';

class BooruOnRailsJsonParser extends BooruParser {
  BooruOnRailsJsonParser(super.server);

  @override
  bool canParsePage(Response res) {
    final data = res.data;
    return data is Map && data.keys.contains('images');
  }

  @override
  List<Post> parsePage(res) {
    super.parsePage(res);
    final entries = List.from(res.data['images']);
    final result = <Post>[];
    for (final post in entries.whereType<Map<String, dynamic>>()) {
      final id = pick(post, 'id').asIntOrNull() ?? -1;
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      final originalFile = pick(post, 'view_url').asStringOrNull() ?? '';
      final sampleFile =
          pick(post, 'representations', 'large').asStringOrNull() ?? '';
      final previewFile =
          pick(post, 'representations', 'thumb').asStringOrNull() ?? '';
      final tags = pick(post, 'tags').asStringList();
      final width = pick(post, 'width').asIntOrNull() ?? -1;
      final height = pick(post, 'height').asIntOrNull() ?? -1;
      final rating = tags.where(
          (tag) => tag == 'explicit' || tag == 'safe' || tag == 'questionable');
      final source = pick(post, 'source_url').asStringOrNull() ?? '';
      final score = pick(post, 'score').asIntOrNull() ?? 0;

      final hasFile = originalFile.isNotEmpty && previewFile.isNotEmpty;
      final hasContent = width > 0 && height > 0;
      final postUrl = server.postUrlOf(id);

      if (hasFile && hasContent) {
        result.add(
          Post(
            id: id,
            originalFile: normalizeUrl(originalFile),
            sampleFile: normalizeUrl(sampleFile),
            previewFile: normalizeUrl(previewFile),
            tags: tags.map(decodeTag).toList(),
            width: width,
            height: height,
            sampleWidth: -1,
            sampleHeight: -1,
            previewWidth: -1,
            previewHeight: -1,
            serverId: server.id,
            postUrl: postUrl,
            rateValue: rating.firstOrNull ?? '',
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
    return data is Map &&
        data.keys.contains('tags') &&
        data.toString().contains('images');
  }

  @override
  Set<String> parseSuggestion(Response res) {
    super.parseSuggestion(res);

    final entries = List.from(res.data['tags']);

    final result = <String>{};
    for (final Map<String, dynamic> entry in entries) {
      final tag = pick(entry, 'name').asStringOrNull() ?? '';
      final postCount = pick(entry, 'images').asIntOrNull() ?? 0;
      if (postCount > 0 && tag.isNotEmpty) result.add(decodeTag(tag));
    }

    return result;
  }
}
