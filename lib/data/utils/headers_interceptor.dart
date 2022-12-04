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
    options.headers['Referer'] = options.path;
    options.headers['User-Agent'] = buildUA(versionLocalSource);
    super.onRequest(options, handler);
  }

  static String buildUA(VersionLocalSource versionLocalSource) {
    final ver = versionLocalSource.get();
    return 'Boorusphere/$ver';
  }
}
