import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final httpProvider = Provider((ref) {
  final dio = Dio();

  dio.interceptors.add(HeadersInterceptor());

  return dio;
});

class HeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Referer'] = options.path;
    return super.onRequest(options, handler);
  }
}
