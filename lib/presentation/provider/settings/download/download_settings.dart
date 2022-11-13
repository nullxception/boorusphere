import 'package:boorusphere/data/repository/setting/entity/setting.dart';
import 'package:boorusphere/domain/provider/setting.dart';
import 'package:boorusphere/presentation/provider/settings/download/group_by_server.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadSettingsProvider {
  static final groupByServer =
      StateNotifierProvider<GroupByServerState, bool>((ref) {
    final repo = ref.watch(settingRepoProvider);
    final saved = repo.get(Setting.downloadsGroupByServer, or: false);
    return GroupByServerState(saved, repo);
  });
}