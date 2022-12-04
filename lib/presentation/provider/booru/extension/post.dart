import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/data/utils/headers_interceptor.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension PostExt on Post {
  String _findReferer(WidgetRef ref) {
    if (postUrl.isNotEmpty) {
      return postUrl;
    }
    final server = ref
        .read(serverDataStateProvider)
        .getById(serverId, or: ServerData.empty);
    if (server.homepage.isNotEmpty) {
      return server.homepage;
    } else {
      return originalFile.toUri().origin;
    }
  }

  Future<Map<String, String>> getHeaders(WidgetRef ref) async {
    final referer = _findReferer(ref);
    final cookies =
        await ref.read(cookieJarProvider).loadForRequest(referer.toUri());
    final userAgent = ref.read(versionLocalSourceProvider).buildUserAgent();

    return {
      'Referer': referer,
      'Cookie': CookieManager.getCookies(cookies),
      'User-Agent': userAgent,
    };
  }
}
