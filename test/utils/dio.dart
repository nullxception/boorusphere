import 'dart:typed_data';

import 'package:boorusphere/utils/extensions/string.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

import 'fake_data.dart';

class DioAdapterMock extends Mock implements HttpClientAdapter {
  DioAdapterMock(Dio dio) {
    dio.httpClientAdapter = this;
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
