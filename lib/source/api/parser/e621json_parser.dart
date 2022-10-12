import 'package:dio/dio.dart';

import '../../../entity/post.dart';
import '../../../utils/extensions/map.dart';
import 'booru_parser.dart';

class E621JsonParser extends BooruParser {
  E621JsonParser(super.server);

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
      final id = post.tryGet('id', orElse: -1);
      if (result.any((it) => it.id == id)) {
        // duplicated result, skipping
        continue;
      }

      final fileMap = post.tryMap('file');
      final sampleMap = post.tryMap('sample');
      final previewMap = post.tryMap('preview');
      final tagsMap = post.tryMap('tags');

      final originalFile = fileMap.tryGet('url', orElse: '');
      final sampleFile = sampleMap.tryGet('url', orElse: '');
      final previewFile = previewMap.tryGet('url', orElse: '');
      final tagsArtist = tagsMap.tryList<String>('artist');
      final tagsCharacter = tagsMap.tryList<String>('character');
      final tagsCopyright = tagsMap.tryList<String>('copyright');
      final tagsMeta = tagsMap.tryGet('meta', orElse: <String>[]);
      final tagsGeneral = [
        ...tagsMap.tryList<String>('general'),
        ...tagsMap.tryList<String>('lore'),
        ...tagsMap.tryList<String>('species'),
      ];
      final width = fileMap.tryGet('width', orElse: 0);
      final height = fileMap.tryGet('height', orElse: 0);
      final sampleWidth = sampleMap.tryGet('width', orElse: 0);
      final sampleHeight = sampleMap.tryGet('height', orElse: 0);
      final previewWidth = previewMap.tryGet('width', orElse: 0);
      final previewHeight = previewMap.tryGet('height', orElse: 0);
      final rating = post.tryGet('rating', orElse: 'q');
      final sources = post.tryList<String>('sources');
      final source = sources.isNotEmpty ? sources.first : '';

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
            tags: [],
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
            tagsArtist: List.from(tagsArtist),
            tagsCharacter: List.from(tagsCharacter),
            tagsCopyright: List.from(tagsCopyright),
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
    return false;
  }

  @override
  Set<String> parseSuggestion(Response res) {
    return {};
  }
}
