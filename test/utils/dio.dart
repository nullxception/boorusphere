import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

class DioAdapterMock extends Mock implements HttpClientAdapter {
  DioAdapterMock(Dio dio) {
    dio.httpClientAdapter = this;
  }
}
