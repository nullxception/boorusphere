import 'package:boorusphere/data/dio/headers_factory.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:cookie_jar/cookie_jar.dart';

extension PostExt on Post {
  String _findReferer(ServerData server) {
    if (postUrl.isNotEmpty) {
      return postUrl;
    }
    if (server.homepage.isNotEmpty) {
      return server.homepage;
    } else {
      return originalFile.toUri().origin;
    }
  }

  Future<Map<String, String>> buildHeaders({
    required CookieJar cookieJar,
    required AppVersion version,
    required ServerData server,
  }) async {
    final referer = _findReferer(server);
    final cookies = await cookieJar.loadForRequest(referer.toUri());

    return HeadersFactory.builder()
        .setReferer(referer)
        .setCookies(cookies)
        .setUserAgent(version)
        .build();
  }
}
