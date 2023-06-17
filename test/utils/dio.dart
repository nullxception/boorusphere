import 'dart:typed_data';

import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'fake_data.dart';

class DioAdapterMock extends Mock implements HttpClientAdapter {
  DioAdapterMock(this.client, {this.byIntercepting = false}) {
    client.httpClientAdapter = this;
    if (byIntercepting) {
      client.interceptors.add(FakeResponseInterceptor(holder));
    }
  }

  final Dio client;
  final bool byIntercepting;

  late ResponseHolder holder = ResponseHolder(client);

  void put(String url, ResponseBody body) {
    assert(byIntercepting);
    holder.put(url, body);
  }
}

class FakeResponseBody {
  static ResponseBody fromFakeData(
    String filePath,
    int statusCode, {
    Map<String, List<String>>? headers,
  }) {
    return ResponseBody(
      getFakeData(filePath).openRead().map(Uint8List.fromList),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [filePath.mimeType],
        ...?headers,
      },
    );
  }
}

class FakeResponseInterceptor extends Interceptor {
  const FakeResponseInterceptor(this.holder);

  final ResponseHolder holder;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    handler.resolve(await holder.responseFor(options));
  }
}

class ResponseHolder {
  ResponseHolder(this.client);

  final Dio client;

  final Map<Uri, ResponseBody> responses = {};

  Future<Response> responseFor(RequestOptions options) async {
    final notFound = ResponseBody.fromBytes([], 404);
    final body = responses[options.uri] ?? notFound;

    return Response(
      data: await client.transformer.transformResponse(options, body),
      requestOptions: options,
      statusCode: body.statusCode,
    );
  }

  void put(String url, ResponseBody responseBody) {
    responses[url.toUri()] = responseBody;
  }
}
