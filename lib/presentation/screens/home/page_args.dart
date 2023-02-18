import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_args.freezed.dart';

@freezed
class PageArgs with _$PageArgs {
  const factory PageArgs({
    @Default('') String query,
    @Default('') String serverId,
  }) = _PageArgs;
  const PageArgs._();
}
