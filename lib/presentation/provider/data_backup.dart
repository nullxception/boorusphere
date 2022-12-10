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
import 'package:boorusphere/domain/repository/version_repo.dart';
import 'package:boorusphere/presentation/provider/blocked_tags_state.dart';
import 'package:boorusphere/presentation/provider/favorite_post_state.dart';
import 'package:boorusphere/presentation/provider/search_history_state.dart';
import 'package:boorusphere/presentation/provider/server_data_state.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/download_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/utils/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_backup.g.dart';

@riverpod
DataBackup dataBackup(DataBackupRef ref) {
  return DataBackup(
    serverLocalSource: ref.watch(serverLocalSourceProvider),
    blockedTagsLocalSource: ref.watch(blockedTagsLocalSourceProvider),
    favoritePostLocalSource: ref.watch(favoritePostLocalSourceProvider),
    settingLocalSource: ref.watch(settingLocalSourceProvider),
    searchHistoryLocalSource: ref.watch(searchHistoryLocalSourceProvider),
    versionRepo: ref.watch(versionRepoProvider),
    invalidate: ref.invalidate,
  );
}

enum DataBackupResult {
  cancelled,
  invalid,
  success;
}

typedef BackupItem = MapEntry<String, Object>;

class DataBackup {
  const DataBackup({
    required this.serverLocalSource,
    required this.blockedTagsLocalSource,
    required this.favoritePostLocalSource,
    required this.settingLocalSource,
    required this.searchHistoryLocalSource,
    required this.versionRepo,
    this.invalidate,
  });

  final ServerLocalSource serverLocalSource;
  final BlockedTagsLocalSource blockedTagsLocalSource;
  final FavoritePostLocalSource favoritePostLocalSource;
  final SettingLocalSource settingLocalSource;
  final SearchHistoryLocalSource searchHistoryLocalSource;
  final VersionRepo versionRepo;
  final void Function(ProviderOrFamily)? invalidate;

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
    final downloadDir = (await DownloadUtils.downloadDir).absolute.path;
    final dir = Directory(join(downloadDir, 'backups'));
    await DownloadUtils.createDownloadDir();
    dir.createSync();
    return dir;
  }

  Future<BackupItem> _metadata() async {
    return BackupItem(appId, {'version': '${versionRepo.current}'});
  }

  void _invalidateProviders() {
    invalidate?.call(serverDataStateProvider);
    invalidate?.call(blockedTagsStateProvider);
    invalidate?.call(searchHistoryStateProvider);
    invalidate?.call(favoritePostStateProvider);
    invalidate?.call(uiSettingStateProvider);
    invalidate?.call(contentSettingStateProvider);
    invalidate?.call(downloadSettingStateProvider);
    invalidate?.call(serverSettingStateProvider);
  }

  Future<DataBackupResult> import({Future<bool?> Function()? onConfirm}) async {
    final backupsDir = await _backupDir();
    await FilePicker.platform.clearTemporaryFiles();

    final result = await FilePicker.platform.pickFiles(
      initialDirectory: backupsDir.absolute.path,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withReadStream: true,
    );

    final bytes = await result?.files.single.readStream?.first;
    if (bytes == null) return DataBackupResult.cancelled;

    final decoder = ZipDecoder().decodeBytes(bytes);
    if (!decoder.files.any((it) => it.name == '$appId.json')) {
      return DataBackupResult.invalid;
    }

    final confirm = onConfirm ?? () async => true;
    final continueRestore = await confirm.call() ?? false;
    if (!continueRestore) return DataBackupResult.cancelled;

    for (final json in decoder.files) {
      final content = utf8.decode(json.content);
      switch (json.name.replaceAll('.json', '')) {
        case ServerLocalSource.key:
          await serverLocalSource.import(content);
          break;
        case BlockedTagsLocalSource.key:
          await blockedTagsLocalSource.import(content);
          break;
        case FavoritePostLocalSource.key:
          await favoritePostLocalSource.import(content);
          break;
        case SettingLocalSource.key:
          await settingLocalSource.import(content);
          break;
        case SearchHistoryLocalSource.key:
          await searchHistoryLocalSource.import(content);
          break;
        default:
          break;
      }
    }

    _invalidateProviders();
    return DataBackupResult.success;
  }

  Future<String> export() async {
    final server = serverLocalSource.export();
    final blockedTags = blockedTagsLocalSource.export();
    final favoritePost = favoritePostLocalSource.export();
    final setting = settingLocalSource.export();
    final searchHistory = searchHistoryLocalSource.export();
    final temp = await _tempDir();
    final encoder = ZipFileEncoder();
    encoder.create('${temp.path}/data.zip');

    final entries = [
      _metadata(),
      server,
      blockedTags,
      favoritePost,
      setting,
      searchHistory,
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
    return zip.path;
  }

  static const appId = 'boorusphere';
}
