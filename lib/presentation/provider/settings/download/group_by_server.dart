import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/repository/setting_repo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GroupByServerSettingNotifier extends StateNotifier<bool> {
  GroupByServerSettingNotifier(super.state, this.repo);

  final SettingRepo repo;

  Future<void> update(bool value) async {
    state = value;
    await repo.put(Setting.downloadsGroupByServer, value);
  }
}
