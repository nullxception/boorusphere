import 'package:boorusphere/presentation/utils/extensions/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('string', () {
    final res = Response(requestOptions: RequestOptions(), statusCode: 502);
    final plain = DioException(requestOptions: res.requestOptions);
    final withStatusCode = plain.copyWith(response: res);
    const msg = 'Something happen';

    test('withDioExceptionCode', () {
      expect(msg.withDioExceptionCode(plain), msg);
      expect(msg.withDioExceptionCode(withStatusCode), '$msg (HTTP 502)');
    });
  });
}
