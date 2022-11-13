import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/page.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

extension PostExt on Post {
  Map<String, String> getHeaders(ref) {
    final cookie = ref.read(BooruPage.cookieProvider);
    return {
      'Referer': postUrl,
      'Cookie': CookieManager.getCookies(cookie),
    };
  }
}
