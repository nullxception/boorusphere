import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/settings/download/group_by_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadSettingsProvider {
  static final groupByServer =
      StateNotifierProvider<GroupByServerSettingNotifier, bool>((ref) {
    final repo = ref.read(settingRepoProvider);
    final saved = repo.get(Setting.downloadsGroupByServer, or: false);
    return GroupByServerSettingNotifier(saved, repo);
  });
}
