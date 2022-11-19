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

enum UpdaterAction {
  stop,
  start,
  exposeAppFile,
  install;
}

class AppUpdater {
  AppUpdater(this.ref);

  final Ref ref;

  String id = '';
  AppVersion appUpdateVersion = AppVersion.zero;

  String _getAppUpdateFile(AppVersion version) {
    return 'boorusphere-$version-$kAppArch.apk';
  }

  Future<Directory> get _appUpdateDir async {
    final dir = await getApplicationSupportDirectory();
    return Directory(path.join(dir.absolute.path, 'app-update'));
  }

  Future<void> _startAppUpdate(AppVersion version) async {
    await _stopAppUpdate();
    final file = _getAppUpdateFile(version);
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
      appUpdateVersion = version;
      id = newId;
    }
  }

  Future<void> _stopAppUpdate() async {
    if (id.isEmpty) return;
    await FlutterDownloader.remove(
      taskId: id,
      shouldDeleteContent: true,
    );
    id = '';
  }

  _clearAppUpdate() async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE file_name LIKE \'%.apk\'');
    if (tasks == null) return;
    for (var task in tasks) {
      await FlutterDownloader.remove(taskId: task.taskId);
    }
    id = '';
  }

  Future<void> _exposeAppUpdateFile() async {
    final file = _getAppUpdateFile(appUpdateVersion);
    final appDir = await _appUpdateDir;
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

  Future<void> updater(
      {required UpdaterAction action, AppVersion? version}) async {
    if (version != null) appUpdateVersion = version;
    switch (action) {
      case UpdaterAction.start:
        await _startAppUpdate(appUpdateVersion);
        break;
      case UpdaterAction.stop:
        await _stopAppUpdate();
        break;
      case UpdaterAction.install:
        await FlutterDownloader.open(taskId: id);
        await _clearAppUpdate();
        break;
      case UpdaterAction.exposeAppFile:
        await _exposeAppUpdateFile();
        break;
    }
  }
}
