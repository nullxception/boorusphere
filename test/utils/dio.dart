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
  static ResponseBody fromFixture(
    String filePath,
    int statusCode, {
    Map<String, List<String>>? headers,
  }) {
    return ResponseBody(
      getFixture(filePath).openRead().map(Uint8List.fromList),
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
    final response = await holder.responseFor(options);
    if (!options.validateStatus(response.statusCode)) {
      handler.reject(DioException.badResponse(
        statusCode: response.statusCode ?? 200,
        requestOptions: options,
        response: response,
      ));
      return;
    }

    handler.resolve(response);
  }
}

class ResponseHolder {
  ResponseHolder(this.client);

  final Dio client;

  final Map<Uri, ResponseBody> responses = {};
  Response _notFoundResponse(RequestOptions options) {
    return Response(
      data: ResponseBody.fromBytes([], 404, isRedirect: true),
      requestOptions: options,
      isRedirect: true,
      redirects: [
        RedirectRecord(
          301,
          'GET',
          options.uri.replace(
            queryParameters: {},
            path: '/notfound',
            fragment: '',
          ),
        )
      ],
    );
  }

  Future<Response> responseFor(RequestOptions options) async {
    final body = responses[options.uri];
    if (body == null) {
      return _notFoundResponse(options);
    }

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
