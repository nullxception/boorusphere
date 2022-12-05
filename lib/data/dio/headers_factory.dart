import 'dart:io';

import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class HeadersFactory {
  HeadersFactory._();

  factory HeadersFactory.builder() => HeadersFactory._();

  final _data = <String, String>{};

  HeadersFactory setReferer(String referer) {
    if (referer.isNotEmpty) {
      _data['Referer'] = referer;
    }
    return this;
  }

  HeadersFactory setCookies(List<Cookie> cookies) {
    if (cookies.isNotEmpty) {
      _data['Cookie'] = CookieManager.getCookies(cookies);
    }
    return this;
  }

  HeadersFactory setUserAgent(AppVersion version) {
    _data['User-Agent'] = 'Boorusphere/$version';
    return this;
  }

  Map<String, String> build() {
    return _data;
  }
}
