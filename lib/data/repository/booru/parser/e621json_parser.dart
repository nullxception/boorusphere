import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/booru/parser/booru_parser.dart';
import 'package:boorusphere/data/repository/booru/utils/booru_util.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/utils/extensions/pick.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';

class E621JsonParser extends BooruParser {
  E621JsonParser(this.server);
  @override
  final id = 'E621.json';

  @override
  final ServerData server;

  @override
  bool canParsePage(Response res) {
    final data = res.data;
    return data is Map && data.keys.contains('posts');
  }

  @override
  List<Post> parsePage(res) {
    final entries = List.from(res.data['posts']);
    final result = <Post>[];
    for (final post in entries.whereType<Map<String, dynamic>>()) {
      final id = pick(post, 'id').asIntOrNull() ?? -1;
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      final fileMap = pick(post, 'file').asMapOrEmpty();
      final sampleMap = pick(post, 'sample').asMapOrEmpty();
      final previewMap = pick(post, 'preview').asMapOrEmpty();
      final tagsMap = pick(post, 'tags').asMapOrEmpty();

      final originalFile = pick(fileMap, 'url').asStringOrNull() ?? '';
      final sampleFile = pick(sampleMap, 'url').asStringOrNull() ?? '';
      final previewFile = pick(previewMap, 'url').asStringOrNull() ?? '';
      final tagsArtist = pick(tagsMap, 'artist').asStringList();
      final tagsCharacter = pick(tagsMap, 'character').asStringList();
      final tagsCopyright = pick(tagsMap, 'copyright').asStringList();
      final tagsMeta = pick(tagsMap, 'meta').asStringList();
      final tagsGeneral = [
        ...pick(tagsMap, 'general').asStringList(),
        ...pick(tagsMap, 'lore').asStringList(),
        ...pick(tagsMap, 'species').asStringList(),
      ];
      final width = pick(fileMap, 'width').asIntOrNull() ?? 0;
      final height = pick(fileMap, 'height').asIntOrNull() ?? 0;
      final sampleWidth = pick(sampleMap, 'width').asIntOrNull() ?? 0;
      final sampleHeight = pick(sampleMap, 'height').asIntOrNull() ?? 0;
      final previewWidth = pick(previewMap, 'width').asIntOrNull() ?? 0;
      final previewHeight = pick(previewMap, 'height').asIntOrNull() ?? 0;
      final rating = pick(post, 'rating').asStringOrNull() ?? 'q';
      final sources = pick(post, 'sources').asStringList();
      final source = sources.isNotEmpty ? sources.first : '';

      final hasFile = originalFile.isNotEmpty && previewFile.isNotEmpty;
      final hasContent = width > 0 && height > 0;
      final postUrl = server.postUrlOf(id);
      final score = pick(post, 'score', 'total').asIntOrNull() ?? 0;

      if (hasFile && hasContent) {
        result.add(
          Post(
            id: id,
            originalFile: BooruUtil.normalizeUrl(server, originalFile),
            sampleFile: BooruUtil.normalizeUrl(server, sampleFile),
            previewFile: BooruUtil.normalizeUrl(server, previewFile),
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
    return false;
  }

  @override
  Iterable<String> parseSuggestion(Response res) {
    throw UnimplementedError();
  }
}
