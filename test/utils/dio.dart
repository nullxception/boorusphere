import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';

class DioAdapterMock extends Mock implements HttpClientAdapter {
  DioAdapterMock();

  factory DioAdapterMock.on(Dio dio) {
    final adapter = DioAdapterMock();
    dio.httpClientAdapter = adapter;
    return adapter;
  }
}
