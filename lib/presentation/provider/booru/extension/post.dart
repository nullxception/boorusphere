import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

extension PostExt on Post {
  Future<Map<String, String>> getHeaders(WidgetRef ref) async {
    final cookies = CookieManager.getCookies(
      await ref.read(cookieJarProvider).loadForRequest(postUrl.toUri()),
    );

    return {
      'Referer': postUrl,
      'Cookie': cookies,
    };
  }
}
