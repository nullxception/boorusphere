import 'package:freezed_annotation/freezed_annotation.dart';

part 'suggestion_state.freezed.dart';

@freezed
class SuggestionState with _$SuggestionState {
  const factory SuggestionState.data(Set<String> data) = DataSuggestionState;
  const factory SuggestionState.loading(Set<String> data) =
      LoadingSuggestionState;
  const factory SuggestionState.error(
    Set<String> data, {
    Object? error,
    StackTrace? stackTrace,
  }) = ErrorSuggestionState;
}
