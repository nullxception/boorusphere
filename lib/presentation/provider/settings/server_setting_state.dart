import 'package:boorusphere/data/repository/booru/entity/page_option.dart';
import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/provider/settings/entity/server_setting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server_setting_state.g.dart';

@riverpod
class ServerSettingState extends _$ServerSettingState {
  @override
  ServerSetting build() {
    final repo = ref.read(settingsRepoProvider);
    return ServerSetting(
      lastActiveId: repo.get(Setting.serverLastActiveId, or: ''),
      postLimit: repo.get(Setting.serverPostLimit, or: PageOption.defaultLimit),
      searchRating: repo.get(Setting.searchRating, or: BooruRating.safe),
    );
  }

  Future<void> setLastActiveId(String newId) async {
    final repo = ref.read(settingsRepoProvider);
    state = state.copyWith(lastActiveId: newId);
    await repo.put(Setting.serverLastActiveId, newId);
  }

  Future<void> setPostLimit(int value) async {
    final repo = ref.read(settingsRepoProvider);
    state = state.copyWith(postLimit: value);
    await repo.put(Setting.serverPostLimit, value);
  }

  Future<void> setRating(BooruRating value) async {
    final repo = ref.read(settingsRepoProvider);
    state = state.copyWith(searchRating: value);
    await repo.put(Setting.searchRating, value);
  }
}
