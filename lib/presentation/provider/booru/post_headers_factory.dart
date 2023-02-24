import 'dart:io';

import 'package:boorusphere/data/dio/headers_factory.dart';
import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_headers_factory.g.dart';

@riverpod
PostHeadersFactory postHeadersFactory(PostHeadersFactoryRef ref) {
  return PostHeadersFactory(
    cookieJar: ref.watch(cookieJarProvider),
    versionRepo: ref.watch(versionRepoProvider),
  );
}

class PostHeadersFactory {
  PostHeadersFactory({
    required this.cookieJar,
    required this.versionRepo,
  });

  final CookieJar cookieJar;
  final VersionRepo versionRepo;

  String _createReferer(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.replaceAll(RegExp('/+'), '/');
    return uri.replace(path: uri.hasAbsolutePath ? path : '/').toString();
  }

  Map<String, String> build(Post post, {List<Cookie> cookies = const []}) {
    final url = post.postUrl.isEmpty ? post.content.url : post.postUrl;
    final referer = _createReferer(url);

    return HeadersFactory.builder()
        .setCookies(cookies)
        .setReferer(referer)
        .setUserAgent(versionRepo.current)
        .build();
  }
}
