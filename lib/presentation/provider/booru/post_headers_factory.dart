import 'package:boorusphere/data/dio/headers_factory.dart';
import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'post_headers_factory.g.dart';

@riverpod
PostHeadersFactory postHeadersFactory(PostHeadersFactoryRef ref) {
  return PostHeadersFactory(
    cookieJar: ref.watch(cookieJarProvider),
    serverData: ref.watch(serverDataStateProvider),
    versionRepo: ref.watch(versionRepoProvider),
  );
}

class PostHeadersFactory {
  PostHeadersFactory({
    required this.cookieJar,
    required this.serverData,
    required this.versionRepo,
  });

  final CookieJar cookieJar;
  final List<ServerData> serverData;
  final VersionRepo versionRepo;

  String _findReferer(Post post) {
    if (post.postUrl.isNotEmpty) {
      return post.postUrl;
    }
    final server = serverData.getById(post.serverId, or: ServerData.empty);
    if (server.homepage.isNotEmpty) {
      return server.homepage;
    } else {
      return post.originalFile.toUri().origin;
    }
  }

  Future<Map<String, String>> build(Post post) async {
    final referer = _findReferer(post);
    final cookies = await cookieJar.loadForRequest(referer.toUri());

    return HeadersFactory.builder()
        .setReferer(referer)
        .setCookies(cookies)
        .setUserAgent(versionRepo.current)
        .build();
  }
}
