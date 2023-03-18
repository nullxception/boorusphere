import 'package:dio/dio.dart';

extension StringExt on String {
  String withDioErrorCode(DioError err) {
    final code = err.response?.statusCode ?? 0;
    return this + (code > 0 ? ' (HTTP $code)' : '');
  }
}
