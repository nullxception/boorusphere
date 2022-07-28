import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import '../data/post.dart';
import '../data/server_data.dart';
import '../data/sphere_exception.dart';
import '../utils/map_ext.dart';
import '../utils/retry_future.dart';
import 'blocked_tags.dart';
import 'search_history.dart';
import 'server_data.dart';
import 'settings/active_server.dart';
import 'settings/safe_mode.dart';

final pageLoadingProvider = StateProvider((_) => false);
final pageErrorProvider = StateProvider((_) => []);
final pageManagerProvider = Provider((ref) => PageManager(ref));
final pageQueryProvider = StateProvider((_) => '');

class PageManager {
  PageManager(this.ref);

  final Ref ref;
  final List<Post> posts = [];

  int _page = 0;

  List<Post> _parse(ServerData server, http.Response res) {
    final blockedTags = ref.read(blockedTagsProvider);

    if (res.statusCode != 200) {
      throw SphereException(
          message: 'Cannot fetch page (HTTP ${res.statusCode})');
    } else if (!res.body.contains(RegExp('https?'))) {
      // no url founds in the document means no image(s) available to display
      throw SphereException(
          message: posts.isNotEmpty ? 'No more result' : 'No result found');
    }

    const cantParse = SphereException(message: 'Cannot parse result');

    List<dynamic> entries;
    if (res.body.contains(RegExp('[a-z][\'"]s*:'))) {
      entries = res.body.contains('@attributes')
          ? jsonDecode(res.body)['post']
          : jsonDecode(res.body);
    } else if (res.body.contains('<?xml')) {
      final xjson = Xml2Json();
      xjson.parse(res.body.replaceAll('\\', ''));

      final jsonObj = jsonDecode(xjson.toGData());
      if (!jsonObj.values.first.keys.contains('post')) {
        throw cantParse;
      }

      final posts = jsonObj.values.first['post'];
      if (posts is LinkedHashMap) {
        entries = [posts];
      } else if (posts is List) {
        entries = posts;
      } else {
        throw cantParse;
      }
    } else {
      throw cantParse;
    }

    final result = <Post>[];

    final idKey = ['id'];
    final originalFileKey = ['file_url'];
    final sampleFileKey = ['large_file_url', 'sample_url'];
    final previewFileKey = ['preview_url', 'preview_file_url'];
    final tagsKey = ['tags', 'tag_string'];
    final widthKey = ['image_width', 'width'];
    final heightKey = ['image_height', 'height'];
    final sampleWidthKey = ['sample_width'];
    final sampleHeightKey = ['sample_height'];
    final previewWidthKey = ['preview_width'];
    final previewHeightKey = ['preview_height'];
    final sourceKey = ['source'];

    final ratingKey = ['rating'];

    for (final Map<String, dynamic> post in entries) {
      final id = post.take(idKey, orElse: -1);
      final originalFile = post.take(originalFileKey, orElse: '');
      final sampleFile = post.take(sampleFileKey, orElse: '');
      final previewFile = post.take(previewFileKey, orElse: '');
      final tags = post.take(tagsKey, orElse: <String>[]);
      final width = post.take(widthKey, orElse: -1);
      final height = post.take(heightKey, orElse: -1);
      final sampleWidth = post.take(sampleWidthKey, orElse: -1);
      final sampleHeight = post.take(sampleHeightKey, orElse: -1);
      final previewWidth = post.take(previewWidthKey, orElse: -1);
      final previewHeight = post.take(previewHeightKey, orElse: -1);
      final rating = post.take(ratingKey, orElse: 'q');
      final source = post.take(sourceKey, orElse: '');

      final hasFile = originalFile.isNotEmpty && previewFile.isNotEmpty;
      final hasContent = width > 0 && height > 0;
      final notBlocked = !tags.any(blockedTags.listedEntries.contains);
      final postUrl = id < 0 ? '' : server.postUrlOf(id);

      if (hasFile && hasContent && notBlocked) {
        result.add(
          Post(
            id: id,
            originalFile: originalFile,
            sampleFile: sampleFile,
            previewFile: previewFile,
            tags: tags,
            width: width,
            height: height,
            sampleWidth: sampleWidth,
            sampleHeight: sampleHeight,
            previewWidth: previewWidth,
            previewHeight: previewHeight,
            serverName: server.name,
            postUrl: postUrl,
            rateValue: rating.isEmpty ? 'q' : rating,
            source: source,
          ),
        );
      }
    }

    return result;
  }

  Future<void> fetch({String? query, bool clear = false}) async {
    final pageLoading = ref.read(pageLoadingProvider.state);
    final pageQuery = ref.read(pageQueryProvider);
    final pageError = ref.read(pageErrorProvider.state);
    final activeServer = ref.read(activeServerProvider);
    final safeMode = ref.read(safeModeProvider);

    if (query != null && pageQuery != query) {
      ref.read(pageQueryProvider.notifier).state = query;
      ref.read(searchHistoryProvider).push(query);
    }

    if (clear) posts.clear();
    if (posts.isEmpty) _page = 0;
    pageLoading.state = true;
    pageError.state = [];
    try {
      final url = activeServer.searchUrlOf(query ?? pageQuery, _page, safeMode);
      Fimber.d('Fetching $url');
      final res = await retryFuture(
        () => http.get(Uri.parse(url)).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      final data = _parse(activeServer, res);
      posts.addAll(data);
    } catch (exception, stackTrace) {
      if (exception is SphereException) {
        final message = [
          exception.message,
          if (pageQuery.isNotEmpty) 'for $pageQuery',
          if (safeMode) 'in safe mode'
        ].join(' ');
        pageError.state = [exception.copyWith(message: message), stackTrace];
      } else {
        pageError.state = [exception, stackTrace];
      }
    }

    pageLoading.state = false;
  }

  void loadMore() {
    final pageLoading = ref.read(pageLoadingProvider);
    final pageError = ref.read(pageErrorProvider);
    if (pageError.isEmpty && !pageLoading) {
      _page++;
      fetch();
    }
  }

  void initialize() async {
    await ref.read(serverDataProvider.notifier).populateData();
    ref.read(activeServerProvider.notifier).restoreFromPreference();

    posts.clear();
    fetch();
  }
}
