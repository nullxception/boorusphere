import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_option.freezed.dart';

@freezed
class PageOption with _$PageOption {
  const factory PageOption({
    @Default('') String query,
    @Default(false) bool clear,
    @Default(PageOption.defaultLimit) int limit,
    @Default(true) bool safeMode,
  }) = _PageOption;
  const PageOption._();

  static const defaultLimit = 40;
}
