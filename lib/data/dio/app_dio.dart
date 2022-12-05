import 'package:boorusphere/data/dio/headers_interceptor.dart';
import 'package:boorusphere/data/repository/version/datasource/version_local_source.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

class AppDio with DioMixin implements Dio {
  AppDio({
    required CookieJar cookieJar,
    required VersionLocalSource versionLocalSource,
  }) {
    options = BaseOptions();
    httpClientAdapter = DefaultHttpClientAdapter();
    final retryDelays = List.generate(5, (index) {
      return Duration(milliseconds: 400 + (100 * (index + 1)));
    });

    interceptors
      ..add(CookieManager(cookieJar))
      ..add(HeadersInterceptor(versionLocalSource))
      ..add(RetryInterceptor(
        dio: this,
        retries: retryDelays.length,
        retryDelays: retryDelays,
      ));
  }
}
