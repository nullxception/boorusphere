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
    options.headers['User-Agent'] = await versionLocalSource.buildUserAgent();
    super.onRequest(options, handler);
  }
}

extension VersionLocalSourceExt on VersionLocalSource {
  Future<String> buildUserAgent() async {
    final ver = await get();
    return 'Boorusphere/$ver';
  }
}
