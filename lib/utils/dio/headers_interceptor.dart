import 'package:dio/dio.dart';

class HeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Referer'] = options.path;
    return super.onRequest(options, handler);
  }
}
