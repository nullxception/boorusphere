import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

part 'page_args.freezed.dart';

@freezed
class PageArgs with _$PageArgs {
  const factory PageArgs({
    @Default('') String query,
    @Default('') String serverId,
  }) = _PageArgs;
  const PageArgs._();
}

final pageArgsProvider =
    Provider.autoDispose<PageArgs>((ref) => throw UnimplementedError());
