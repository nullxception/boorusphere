import 'dart:io';

import 'package:boorusphere/utils/http/base.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class CustomHttpOverrides extends HttpOverrides {
  CustomHttpOverrides({required this.cookieJar});

  final CookieJar cookieJar;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return CustomHttpClient(
      super.createHttpClient(context),
      cookieJar: cookieJar,
    );
  }
}

class CustomHttpClient extends BaseHttpClient {
  CustomHttpClient(super.client, {required this.cookieJar});

  final CookieJar cookieJar;

  Future<HttpClientRequest> injectHeaders(
    Future<HttpClientRequest> httpClientRequest,
  ) async {
    final req = await httpClientRequest;

    final ua = req.headers[HttpHeaders.userAgentHeader];
    if (ua != null) {
      ua.removeWhere((it) => it.startsWith('Dart/'));
      req.headers.set(HttpHeaders.userAgentHeader, ua);
    }

    final cookies = await cookieJar.loadForRequest(req.uri);
    if (cookies.isNotEmpty) {
      req.headers
          .set(HttpHeaders.cookieHeader, CookieManager.getCookies(cookies));
    }
    return req;
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    return injectHeaders(super.get(host, port, path));
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    return injectHeaders(super.getUrl(url));
  }
}
