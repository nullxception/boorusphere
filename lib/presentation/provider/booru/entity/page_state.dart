import 'package:boorusphere/presentation/provider/booru/entity/page_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_state.freezed.dart';

@freezed
class PageState with _$PageState {
  const factory PageState.data(PageData data) = DataPageState;
  const factory PageState.loading(PageData data) = LoadingPageState;
  const factory PageState.error(
    PageData data,
    Object error,
    StackTrace? stackTrace,
  ) = ErrorPageState;
}
