import 'package:boorusphere/data/dio/headers_factory.dart';
import 'package:boorusphere/domain/repository/env_repo.dart';
import 'package:dio/dio.dart';

class HeadersInterceptor extends Interceptor {
  HeadersInterceptor(this.envRepo);

  final EnvRepo envRepo;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.addAll(
      HeadersFactory.builder()
          .setReferer(options.path)
          .setUserAgent(envRepo.appVersion)
          .build(),
    );
    super.onRequest(options, handler);
  }
}
