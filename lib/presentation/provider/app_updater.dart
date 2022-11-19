import 'dart:io';

import 'package:boorusphere/constant/app.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/utils/download.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_updater.g.dart';

@riverpod
AppUpdater appUpdater(AppUpdaterRef ref) {
  return AppUpdater(ref);
}

@riverpod
DownloadProgress appUpdateProgress(AppUpdateProgressRef ref) {
  final id = ref.watch(appUpdaterProvider.select((it) => it.id));
  return ref.watch(downloadStateProvider).getProgressById(id);
}

class AppUpdater {
  AppUpdater(this.ref);

  final Ref ref;

  String id = '';
  AppVersion _version = AppVersion.zero;

  String _fileName(AppVersion version) {
    return 'boorusphere-$version-$kAppArch.apk';
  }

  Future<Directory> get _dir async {
    final dir = await getApplicationSupportDirectory();
    return Directory(path.join(dir.absolute.path, 'app-update'));
  }

  _clear({bool removeFile = false}) async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE file_name LIKE \'%.apk\'');
    if (tasks == null) return;
    for (var task in tasks) {
      await FlutterDownloader.remove(
        taskId: task.taskId,
        shouldDeleteContent: removeFile,
      );
    }
    id = '';
  }

  Future<void> start(AppVersion version) async {
    await stop();
    final file = _fileName(version);
    final url =
        '${VersionNetworkSource.gitUrl}/releases/download/$version/$file';
    final dir = await getApplicationSupportDirectory();
    final appDir = Directory(path.join(dir.absolute.path, 'app-update'));
    appDir.createSync();
    final appFile = File(path.join(appDir.absolute.path, file));
    if (appFile.existsSync()) {
      appFile.deleteSync();
    }

    final newId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: appDir.absolute.path,
      showNotification: true,
      openFileFromNotification: false,
    );

    if (newId != null) {
      _version = version;
      id = newId;
    }
  }

  Future<void> stop() async {
    _clear(removeFile: true);
  }

  Future<void> expose() async {
    final file = _fileName(_version);
    final appDir = await _dir;
    final downloadDir = (await DownloadUtils.downloadDir).absolute.path;
    final extAppDir = Directory(path.join(downloadDir, 'app-update'));

    await DownloadUtils.createDownloadDir();
    appDir.createSync();
    extAppDir.createSync();

    final appFile = File(path.join(appDir.absolute.path, file));
    final extAppFile = File(path.join(extAppDir.absolute.path, file));

    if (appFile.existsSync() && !extAppFile.existsSync()) {
      await appFile.copy(extAppFile.absolute.path);
    }
  }

  Future<void> install() async {
    await FlutterDownloader.open(taskId: id);
    await _clear();
  }
}
