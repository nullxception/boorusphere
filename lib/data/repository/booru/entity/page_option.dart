import 'package:boorusphere/presentation/provider/settings/server/post_limit.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_option.freezed.dart';

@freezed
class PageOption with _$PageOption {
  const factory PageOption({
    @Default('') String query,
    @Default(false) bool clear,
    @Default(ServerPostLimitSettingNotifier.defaultLimit) int limit,
    @Default(true) bool safeMode,
  }) = _PageOption;
  const PageOption._();
}
