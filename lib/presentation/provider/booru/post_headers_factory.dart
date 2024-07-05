import 'dart:io';

import 'package:boorusphere/data/dio/headers_factory.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_headers_factory.g.dart';

String createReferer(String url) {
  final uri = Uri.parse(url);
  final path = uri.path.replaceAll(RegExp('/+'), '/');
  return uri.replace(path: uri.hasAbsolutePath ? path : '/').toString();
}

@riverpod
Map<String, String> postHeadersFactory(
  PostHeadersFactoryRef ref,
  Post post, {
  List<Cookie> cookies = const [],
}) {
  final versionRepo = ref.watch(versionRepoProvider);
  final url = post.postUrl.isEmpty ? post.content.url : post.postUrl;
  final referer = createReferer(url);

  return HeadersFactory.builder()
      .setCookies(cookies)
      .setReferer(referer)
      .setUserAgent(versionRepo.current)
      .build();
}
