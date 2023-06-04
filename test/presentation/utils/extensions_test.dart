import 'package:boorusphere/presentation/utils/extensions/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('string', () {
    final res = Response(requestOptions: RequestOptions(), statusCode: 502);
    final plain = DioError(requestOptions: res.requestOptions);
    final withStatusCode = plain.copyWith(response: res);
    const msg = 'Something happen';

    test('withDioErrorCode', () {
      expect(msg.withDioErrorCode(plain), msg);
      expect(msg.withDioErrorCode(withStatusCode), '$msg (HTTP 502)');
    });
  });
}
