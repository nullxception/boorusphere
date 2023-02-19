import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/server/entity/server_data.dart';
import 'package:boorusphere/presentation/provider/settings/entity/search_rating.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_setting.freezed.dart';

@freezed
class ServerSetting with _$ServerSetting {
  const factory ServerSetting({
    @Default(ServerData.empty) ServerData active,
    @Default(PageOption.defaultLimit) int postLimit,
    @Default(SearchRating.safe) SearchRating searchRating,
  }) = _ServerSetting;
  const ServerSetting._();
}
