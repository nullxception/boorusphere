import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import '../model/booru_post.dart';
import '../model/server_data.dart';
import '../util/map_ext.dart';
import '../util/retry_future.dart';
import 'blocked_tags.dart';
import 'query.dart';
import 'server_data.dart';
import 'settings/active_server.dart';

final pageLoadingProvider = StateProvider((_) => false);
final pageErrorProvider = StateProvider((_) => '');
final pageManagerProvider = Provider((ref) => PageManager(ref));

class PageManager {
  PageManager(this.ref);

  final Ref ref;
  final List<BooruPost> posts = [];

  int _page = 1;

  List<BooruPost> _parse(ServerData server, http.Response res) {
    final query = ref.read(queryProvider);
    final blockedTags = ref.read(blockedTagsProvider);

    if (res.statusCode != 200) {
      throw HttpException('Something went wrong [${res.statusCode}]');
    } else if (!res.body.contains(RegExp('https?'))) {
      // no url founds in the document means no image(s) available to display
      throw HttpException(posts.isNotEmpty
          ? 'No more result for "${query.tags}"'
          : 'No result for "${query.tags}"');
    }

    List<dynamic> entries;
    if (res.body.contains(RegExp('[a-z][\'"]s*:'))) {
      entries = res.body.contains('@attributes')
          ? jsonDecode(res.body)['post']
          : jsonDecode(res.body);
    } else if (res.body.contains('<?xml')) {
      final xjson = Xml2Json();
      xjson.parse(res.body.replaceAll('\\', ''));

      final jsonObj = jsonDecode(xjson.toGData());
      if (jsonObj.values.first.keys.contains('post')) {
        entries = jsonObj.values.first['post'];
      } else {
        throw const FormatException('Unknown document format');
      }
    } else {
      throw const FormatException('Unknown document format');
    }

    final result = <BooruPost>[];

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

      final hasFile = originalFile.isNotEmpty && previewFile.isNotEmpty;
      final hasContent = width > 0 && height > 0;
      final notBlocked = !tags.any(blockedTags.listedEntries.contains);
      final postUrl = id < 0 ? '' : _composePostUrl(server, id);

      if (hasFile && hasContent && notBlocked) {
        result.add(
          BooruPost(
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
          ),
        );
      }
    }

    return result;
  }

  String _composePostUrl(ServerData server, int id) {
    if (server.postUrl.isEmpty) {
      return '';
    }

    final query = server.postUrl.replaceAll('{post-id}', id.toString());
    return '${server.homepage}/$query';
  }

  String _getExceptionMessage(Exception e) => e
      .toString()
      .split(':')
      .skipWhile((it) => it.contains(RegExp(r'xception$')))
      .join(':')
      .trim();

  void fetch() async {
    final pageLoading = ref.read(pageLoadingProvider.state);
    final query = ref.read(queryProvider);
    final errorMessage = ref.read(pageErrorProvider.state);
    final activeServer = ref.read(activeServerProvider);

    if (posts.isEmpty) {
      _page = 1;
    }
    if (!pageLoading.state) {
      pageLoading.state = true;
    }
    if (errorMessage.state.isNotEmpty) {
      errorMessage.state = '';
    }

    try {
      final url = activeServer.composeSearchUrl(query, _page);
      Fimber.d('Fetching $url');
      final res = await retryFuture(
        () => http.get(url).timeout(const Duration(seconds: 5)),
        retryIf: (e) => e is SocketException || e is TimeoutException,
      );
      final data = _parse(activeServer, res);
      posts.addAll(data);
    } on Exception catch (e) {
      Fimber.d('Caught Exception', ex: e);
      final msg = _getExceptionMessage(e);
      errorMessage.state = query.safeMode ? '(Safe Mode) $msg' : msg;
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
    final serverDataNotifier = ref.read(serverDataProvider.notifier);
    final activeServerNotifier = ref.read(activeServerProvider.notifier);

    await serverDataNotifier.populateData();
    activeServerNotifier.restoreFromPreference();

    posts.clear();
    fetch();
  }
}
