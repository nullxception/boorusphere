import 'package:dio/dio.dart';

class HeadersInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Referer'] = options.path;
    super.onRequest(options, handler);
  }
}
