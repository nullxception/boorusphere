import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

extension PostExt on Post {
  Map<String, String> getHeaders(ref) {
    final cookie =
        ref.read(pageStateProvider.select((value) => value.data.cookies));
    return {
      'Referer': postUrl,
      'Cookie': CookieManager.getCookies(cookie),
    };
  }
}
