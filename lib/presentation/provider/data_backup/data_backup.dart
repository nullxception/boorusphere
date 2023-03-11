import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:boorusphere/data/provider.dart';
import 'package:boorusphere/data/repository/blocked_tags/datasource/blocked_tags_local_source.dart';
import 'package:boorusphere/data/repository/favorite_post/datasource/favorite_post_local_source.dart';
import 'package:boorusphere/data/repository/search_history/datasource/search_history_local_source.dart';
import 'package:boorusphere/data/repository/server/datasource/server_local_source.dart';
import 'package:boorusphere/data/repository/setting/datasource/setting_local_source.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/blocked_tags_state.dart';
import 'package:boorusphere/presentation/provider/data_backup/entity/backup_option.dart';
import 'package:boorusphere/presentation/provider/data_backup/entity/backup_result.dart';
import 'package:boorusphere/presentation/provider/favorite_post_state.dart';
import 'package:boorusphere/presentation/provider/search_history_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/download_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/utils/file_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_backup.g.dart';

typedef BackupItem = MapEntry<String, Object>;

@riverpod
class DataBackupState extends _$DataBackupState {
  @override
  BackupResult build() {
    return const BackupResult.idle();
  }

  Future<Directory> _tempDir() async {
    final basedir = await getTemporaryDirectory();
    final temp = Directory(join(basedir.path, '.backup.tmp'));
    if (temp.existsSync()) {
      temp.deleteSync(recursive: true);
    }
    temp.createSync();
    return temp;
  }

  Future<Directory> _backupDir() async {
    final downloadDir = (await FileUtils.downloadDir).absolute.path;
    final dir = Directory(join(downloadDir, 'backups'));
    await FileUtils.createDownloadDir();
    dir.createSync();
    return dir;
  }

  Future<BackupItem> _metadata() async {
    final versionRepo = ref.read(versionRepoProvider);
    return BackupItem(appId, {'version': '${versionRepo.current}'});
  }

  void _invalidateProviders() {
    ref.invalidate(serverDataStateProvider);
    ref.invalidate(blockedTagsStateProvider);
    ref.invalidate(searchHistoryStateProvider);
    ref.invalidate(favoritePostStateProvider);
    ref.invalidate(uiSettingStateProvider);
    ref.invalidate(contentSettingStateProvider);
    ref.invalidate(downloadSettingStateProvider);
    ref.invalidate(serverSettingStateProvider);
  }

  Future<void> import({Future<bool?> Function()? onConfirm}) async {
    final backupsDir = await _backupDir();
    await FilePicker.platform.clearTemporaryFiles();

    final result = await FilePicker.platform.pickFiles(
      initialDirectory: backupsDir.absolute.path,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    final path = result?.files.single.path;
    if (path == null) {
      state = const BackupResult.idle();
      return;
    }
    final stream = InputFileStream(path);
    final decoder = ZipDecoder().decodeBuffer(stream);
    if (!decoder.files.any((it) => it.name == '$appId.json')) {
      state = const BackupResult.error();
      return;
    }

    final confirm = onConfirm ?? () async => true;
    final continueRestore = await confirm.call() ?? false;
    if (!continueRestore) {
      state = const BackupResult.idle();
      return;
    }

    for (final json in decoder.files) {
      final content = utf8.decode(json.content);
      switch (json.name.replaceAll('.json', '')) {
        case ServerLocalSource.key:
          await ref.read(serverLocalSourceProvider).import(content);
          break;
        case BlockedTagsLocalSource.key:
          await ref.read(blockedTagsLocalSourceProvider).import(content);
          break;
        case FavoritePostLocalSource.key:
          await ref.read(favoritePostLocalSourceProvider).import(content);
          break;
        case SettingLocalSource.key:
          await ref.read(settingLocalSourceProvider).import(content);
          break;
        case SearchHistoryLocalSource.key:
          await ref.read(searchHistoryLocalSourceProvider).import(content);
          break;
        default:
          break;
      }
    }

    _invalidateProviders();
    state = const BackupResult.imported();
  }

  Future<void> export({BackupOption option = const BackupOption()}) async {
    if (!option.isValid()) return;

    final server = ref.read(serverLocalSourceProvider).export();
    final blockedTags = ref.read(blockedTagsLocalSourceProvider).export();
    final favoritePost = ref.read(favoritePostLocalSourceProvider).export();
    final setting = ref.read(settingLocalSourceProvider).export();
    final searchHistory = ref.read(searchHistoryLocalSourceProvider).export();
    final temp = await _tempDir();
    final encoder = ZipFileEncoder();
    encoder.create('${temp.path}/data.zip');

    final entries = [
      _metadata(),
      if (option.server) server,
      if (option.blockedTags) blockedTags,
      if (option.favoritePost) favoritePost,
      if (option.setting) setting,
      if (option.searchHistory) searchHistory,
    ];

    await Future.wait(entries.map((entry) async {
      final item = await entry;
      final data = item.value;
      if (data is List && data.isEmpty) return;

      final file = File('${temp.path}/${item.key}.json');
      await file.writeAsString(jsonEncode(data));
      return encoder.addFile(file);
    }));

    encoder.close();

    final dir = await _backupDir();
    final time = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
    final name = '${appId}_backup_$time.zip';
    final zip = File(join(dir.path, name));
    if (zip.existsSync()) {
      zip.deleteSync();
    }

    await File(encoder.zipPath).copy(zip.path);
    temp.deleteSync(recursive: true);
    await FileUtils.rescanDir(zip.parent);
    state = BackupResult.exported(zip.path);
  }

  static const appId = 'boorusphere';
}
