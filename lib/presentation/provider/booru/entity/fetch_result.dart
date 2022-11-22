import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetch_result.freezed.dart';

@freezed
class FetchResult<T> with _$FetchResult<T> {
  const factory FetchResult.data(T data) = DataFetchResult;
  const factory FetchResult.loading(T data) = LoadingFetchResult;
  const factory FetchResult.error(
    T data, {
    Object? error,
    StackTrace? stackTrace,
    @Default(0) int code,
  }) = ErrorFetchResult;
}
