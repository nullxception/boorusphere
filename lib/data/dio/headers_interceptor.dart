import 'package:boorusphere/data/dio/headers_factory.dart';
import 'package:boorusphere/data/repository/version/datasource/version_local_source.dart';
import 'package:dio/dio.dart';

class HeadersInterceptor extends Interceptor {
  HeadersInterceptor(this.versionLocalSource);

  final VersionLocalSource versionLocalSource;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.addAll(
      HeadersFactory.builder()
          .setReferer(options.path)
          .setUserAgent(versionLocalSource.get())
          .build(),
    );
    super.onRequest(options, handler);
  }
}
