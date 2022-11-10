import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cookieJarProvider = Provider((ref) {
  return CookieJar();
});

final dioProvider = Provider((ref) {
  final dio = Dio();
  final cookieJar = ref.watch(cookieJarProvider);
  final retryDelays = List.generate(5, (index) {
    return Duration(milliseconds: 400 + (100 * (index + 1)));
  });

  dio.interceptors
    ..add(CookieManager(cookieJar))
    ..add(HeadersInterceptor())
    ..add(RetryInterceptor(
      dio: dio,
      retries: retryDelays.length,
      retryDelays: retryDelays,
    ));

  return dio;
});

class HeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Referer'] = options.path;
    return super.onRequest(options, handler);
  }
}
