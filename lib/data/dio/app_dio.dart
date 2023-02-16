import 'package:boorusphere/data/dio/headers_interceptor.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

class AppDio with DioMixin implements Dio {
  AppDio({
    required CookieJar cookieJar,
    required EnvRepo envRepo,
  }) {
    options = BaseOptions();
    httpClientAdapter = IOHttpClientAdapter();
    final retryDelays = List.generate(5, (index) {
      return Duration(milliseconds: 400 + (100 * (index + 1)));
    });

    interceptors
      ..add(CookieManager(cookieJar))
      ..add(HeadersInterceptor(envRepo))
      ..add(RetryInterceptor(
        dio: this,
        retries: retryDelays.length,
        retryDelays: retryDelays,
      ));
  }
}
