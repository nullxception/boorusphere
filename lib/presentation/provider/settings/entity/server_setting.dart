import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_setting.freezed.dart';

@freezed
class ServerSetting with _$ServerSetting {
  const factory ServerSetting({
    @Default('') String lastActiveId,
    @Default(PageOption.defaultLimit) int postLimit,
    @Default(BooruRating.safe) BooruRating searchRating,
  }) = _ServerSetting;
  const ServerSetting._();
}
