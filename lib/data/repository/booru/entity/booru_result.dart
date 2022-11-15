import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'booru_result.freezed.dart';

@freezed
class BooruResult<T> with _$BooruResult<T> {
  const factory BooruResult.data(String src, T data) = DataBooruResult;
  const factory BooruResult.error(
    Response res, {
    Object? error,
    StackTrace? stackTrace,
  }) = ErrorBooruResult;
}
