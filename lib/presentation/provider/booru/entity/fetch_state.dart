import 'package:freezed_annotation/freezed_annotation.dart';

part 'fetch_state.freezed.dart';

@freezed
class FetchState<T> with _$FetchState<T> {
  const factory FetchState.data(T data) = DataFetchState;
  const factory FetchState.loading(T data) = LoadingFetchState;
  const factory FetchState.error(
    T data, {
    Object? error,
    StackTrace? stackTrace,
    @Default(0) int code,
  }) = ErrorFetchState;
}
