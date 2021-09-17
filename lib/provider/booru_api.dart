import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import '../model/booru_post.dart';
import '../model/server_query.dart';
import '../util/map_utils.dart';
import 'blocked_tags.dart';
import 'search_tag.dart';
import 'server_data.dart';

final _pageNumberProvider = StateProvider((_) => 1);
final pageLoadingProvider = StateProvider((_) => false);
final pageErrorProvider = StateProvider((_) => '');
final postsProvider = Provider<List<BooruPost>>((_) => []);

class BooruApi {
  final Reader read;

  BooruApi(this.read);

  Future<List<BooruPost>> _parseHttpResponse(http.Response res) async {
    final booruPosts = read(postsProvider);
    final searchTag = read(searchTagProvider);
    final blockedTags = read(blockedTagsProvider);
    final blocked = await blockedTags.listedEntries;

    if (res.statusCode != 200) {
      throw HttpException('Something went wrong [${res.statusCode}]');
    } else if (!res.body.contains(RegExp('https?:\/\/.*'))) {
      // no url founds in the document means no image(s) available to display
      throw HttpException(booruPosts.isNotEmpty
          ? 'No more result for "$searchTag"'
          : 'No result for "$searchTag"');
    }

    List<dynamic> entries;
    if (res.body.contains(RegExp('[a-z][\'"]\s*:'))) {
      // json body, like on danbooru or yandere
      entries = jsonDecode(res.body);
    } else if (res.body.startsWith('<?xm')) {
      // xml body, like safebooru for example
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
    for (final Map<String, dynamic> post in entries) {
      final id = MapUtils.getInt(post, r'^id$');
      final src = MapUtils.getUrl(post, '^(file_url|url)');
      final displaySrc = MapUtils.getUrl(post, '^large_file');
      final thumbnail = MapUtils.getUrl(post, '^(preview_fi|preview)');
      final tags = MapUtils.findEntry(post, '^(tags|tag_str)');
      final width = MapUtils.getInt(post, '^(image_wid|width)');
      final height = MapUtils.getInt(post, '^(image_hei|height)');
      final tagList = tags.value.toString().trim().split(' ');

      final hasContent = width > 0 && height > 0;
      final notBlocked = !tagList.any(blocked.contains);

      if (src != null && thumbnail != null && hasContent && notBlocked) {
        result.add(
          BooruPost(
            id: id,
            src: src,
            displaySrc: displaySrc ?? src,
            thumbnail: thumbnail,
            tags: tagList,
            width: width,
            height: height,
          ),
        );
      }
    }

    return result;
  }

  Future<Either<Exception, List<BooruPost>>> _fetch(ServerQuery query) async {
    final server = read(serverDataProvider);
    try {
      final res = await http.get(server.active.composeSearchUrl(query));
      final data = await _parseHttpResponse(res);
      return right(data);
    } on Exception catch (e) {
      Fimber.d('Caught Exception', ex: e);
      return left(e);
    }
  }

  String _parseException(Exception fail) {
    try {
      final message = fail
          .toString()
          .split(':')
          .skipWhile((it) => it.contains(RegExp(r'xception$')))
          .join(':')
          .trim();

      if (message.isNotEmpty) {
        return message;
      } else {
        throw Exception('An empty exception was throwed');
      }
    } on Exception catch (e) {
      Fimber.d('Caught Exception', ex: e);
      return 'Something went wrong';
    }
  }

  Future<void> fetch({bool clear = false}) async {
    final page = read(_pageNumberProvider);
    final pageLoading = read(pageLoadingProvider);
    final searchTag = read(searchTagProvider);
    final server = read(serverDataProvider);
    final errorMessage = read(pageErrorProvider);
    final booruPosts = read(postsProvider);

    if (clear && page.state > 1) {
      page.state = 1;
    } else if (!clear) {
      page.state++;
    }
    if (!pageLoading.state) {
      pageLoading.state = true;
    }
    if (errorMessage.state.isNotEmpty) {
      errorMessage.state = '';
    }
    if (clear && booruPosts.isNotEmpty) {
      booruPosts.clear();
    }

    final res = await _fetch(
      ServerQuery(
          page: page.state, tags: searchTag, safeMode: server.useSafeMode),
    );
    res.fold(
      (fail) => errorMessage.state = _parseException(fail),
      booruPosts.addAll,
    );
    pageLoading.state = false;
  }

  void loadMore() {
    final pageLoading = read(pageLoadingProvider);
    if (!pageLoading.state) {
      fetch();
    }
  }
}

final booruApiProvider = Provider((ref) => BooruApi(ref.read));
