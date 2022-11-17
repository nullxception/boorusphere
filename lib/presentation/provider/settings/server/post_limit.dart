import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ServerPostLimitSettingNotifier extends StateNotifier<int> {
  ServerPostLimitSettingNotifier(super.state, this.repo);

  final SettingRepo repo;

  Future<void> update(int value) async {
    state = value;
    await repo.put(Setting.serverPostLimit, value);
  }

  static const defaultLimit = 40;
}
