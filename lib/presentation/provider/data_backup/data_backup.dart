import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:boorusphere/data/repository/favorite_post/user_favorite_post_repo.dart';
import 'package:boorusphere/data/repository/search_history/user_search_history.dart';
import 'package:boorusphere/data/repository/server/user_server_data_repo.dart';
import 'package:boorusphere/data/repository/setting/user_setting_repo.dart';
import 'package:boorusphere/data/repository/tags_blocker/booru_tags_blocker_repo.dart';
import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/provider/data_backup/entity/backup_option.dart';
import 'package:boorusphere/presentation/provider/data_backup/entity/backup_result.dart';
import 'package:boorusphere/presentation/provider/favorite_post_state.dart';
import 'package:boorusphere/presentation/provider/search_history_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/download_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/provider/shared_storage_handle.dart';
import 'package:boorusphere/presentation/provider/tags_blocker_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_backup.g.dart';

typedef BackupItem = MapEntry<String, Object>;

enum DataBackupType { backup, restore }

@riverpod
class DataBackupState extends _$DataBackupState {
  @override
  BackupResult build() {
    return const BackupResult.idle();
  }

  Future<Directory> _tempDir() async {
    final basedir = await getTemporaryDirectory();
    final temp = Directory(path.join(basedir.path, '.backup.tmp'));
    if (temp.existsSync()) {
      temp.deleteSync(recursive: true);
    }
    temp.createSync();
    return temp;
  }

  Future<Directory> _backupDir() async {
    final sharedStorageHandle = ref.read(sharedStorageHandleProvider);
    await sharedStorageHandle.init();
    return sharedStorageHandle.createSubDir('backups');
  }

  Future<BackupItem> _metadata() async {
    final versionRepo = ref.read(versionRepoProvider);
    return BackupItem(appId, {'version': '${versionRepo.current}'});
  }

  void _invalidateProviders() {
    ref.invalidate(serverDataStateProvider);
    ref.invalidate(tagsBlockerStateProvider);
    ref.invalidate(searchHistoryStateProvider);
    ref.invalidate(favoritePostStateProvider);
    ref.invalidate(uiSettingStateProvider);
    ref.invalidate(contentSettingStateProvider);
    ref.invalidate(downloadSettingStateProvider);
    ref.invalidate(serverSettingStateProvider);
  }

  Future<void> restore({Future<bool?> Function()? onConfirm}) async {
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

    state = const BackupResult.loading(DataBackupType.restore);
    for (final json in decoder.files) {
      final content = utf8.decode(json.content);
      switch (json.name.replaceAll('.json', '')) {
        case UserServerDataRepo.key:
          await ref.read(serverDataRepoProvider).import(content);
          break;
        case BooruTagsBlockerRepo.boxKey:
          await ref.read(tagsBlockerRepoProvider).import(content);
          break;
        case UserFavoritePostRepo.key:
          await ref.read(favoritePostRepoProvider).import(content);
          break;
        case UserSettingsRepo.key:
          await ref.read(settingsRepoProvider).import(content);
          break;
        case UserSearchHistoryRepo.key:
          await ref.read(searchHistoryRepoProvider).import(content);
          break;
        default:
          break;
      }
    }

    _invalidateProviders();
    state = const BackupResult.imported();
  }

  Future<void> backup({BackupOption option = const BackupOption()}) async {
    if (!option.isValid()) return;

    state = const BackupResult.loading(DataBackupType.backup);
    final server = ref.read(serverDataRepoProvider).export();
    final blockedTags = ref.read(tagsBlockerRepoProvider).export();
    final favoritePost = ref.read(favoritePostRepoProvider).export();
    final setting = ref.read(settingsRepoProvider).export();
    final searchHistory = ref.read(searchHistoryRepoProvider).export();
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
    final zip = File(path.join(dir.path, name));
    if (zip.existsSync()) {
      zip.deleteSync();
    }

    await File(encoder.zipPath).copy(zip.path);
    temp.deleteSync(recursive: true);
    await ref.read(sharedStorageHandleProvider).rescan();
    state = BackupResult.exported(zip.path);
  }

  static const appId = 'boorusphere';
}
