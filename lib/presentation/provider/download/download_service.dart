import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:boorusphere/constant/app.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/data/repository/download/entity/download_status.dart';
import 'package:boorusphere/data/repository/version/datasource/version_network_source.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/presentation/provider/download/entity/downloads.dart';
import 'package:boorusphere/utils/download.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'download_service.g.dart';

@riverpod
DownloadService downloadService(DownloadServiceRef ref) {
  return DownloadService(ref);
}

@pragma('vm:entry-point')
void downloadTaskStatusSender(
  String id,
  DownloadTaskStatus status,
  int progress,
) {
  IsolateNameServer.lookupPortByName(DownloadService.portName)
      ?.send([id, status, progress]);
}

enum UpdaterAction {
  stop,
  start,
  exposeAppFile,
  install;
}

final downloadServicePort = ReceivePort();

class DownloadService {
  DownloadService(this.ref) {
    ref.onDispose(() {
      if (initialized) {
        IsolateNameServer.removePortNameMapping(portName);
      }
    });
    _registerIsolateCallback();
  }

  final Ref ref;
  var initialized = false;

  Downloads get state => ref.read(downloadStateProvider);
  DownloadState get stateNotifier => ref.read(downloadStateProvider.notifier);

  void _registerIsolateCallback() {
    IsolateNameServer.removePortNameMapping(portName);
    IsolateNameServer.registerPortWithName(
        downloadServicePort.sendPort, portName);
    FlutterDownloader.registerCallback(downloadTaskStatusSender);
    downloadServicePort.listen(_updateProgress);
    initialized = true;
  }

  void _updateProgress(data) {
    final DownloadTaskStatus status = data[1];
    final progress = DownloadProgress(
      id: data[0],
      status: DownloadStatus.fromIndex(status.value),
      progress: data[2],
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    stateNotifier.updateProgress(progress);
    if (progress.status.isDownloaded) {
      DownloadUtils.rescanMedia();
    }
  }

  Future<void> download(Post post, {String? url}) async {
    final fileUrl = url ?? post.originalFile;
    final dir = await DownloadUtils.downloadDir;

    await DownloadUtils.createDownloadDir();

    final taskId = await FlutterDownloader.enqueue(
        url: fileUrl,
        savedDir: dir.absolute.path,
        showNotification: true,
        openFileFromNotification: true);

    if (taskId != null) {
      final destination = '${dir.absolute.path}/${fileUrl.fileName}';
      final entry =
          DownloadEntry(id: taskId, post: post, destination: destination);
      await stateNotifier.add(entry);
    }
  }

  Future<void> retry({required String id}) async {
    final newId = await FlutterDownloader.retry(taskId: id);
    if (newId != null) {
      final newEntry = state.entries
          .firstWhere((it) => it.id == id, orElse: () => DownloadEntry.empty)
          .copyWith(id: newId);

      await stateNotifier.update(id, newEntry);
    }
  }

  Future<void> cancel({required String id}) async {
    await FlutterDownloader.cancel(taskId: id);
  }

  Future<void> clear({required String id}) async {
    await FlutterDownloader.remove(taskId: id, shouldDeleteContent: false);
    await stateNotifier.remove(id);
  }

  void openFile({required String id}) {
    FlutterDownloader.open(taskId: id);
  }

  String appUpdateTaskId = '';
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

    final id = await FlutterDownloader.enqueue(
      url: url,
      savedDir: appDir.absolute.path,
      showNotification: true,
      openFileFromNotification: false,
    );

    if (id != null) {
      appUpdateVersion = version;
      appUpdateTaskId = id;
    }
  }

  Future<void> _stopAppUpdate() async {
    if (appUpdateTaskId.isEmpty) return;
    await FlutterDownloader.remove(
      taskId: appUpdateTaskId,
      shouldDeleteContent: true,
    );
    appUpdateTaskId = '';
  }

  _clearAppUpdate() async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE file_name LIKE \'%.apk\'');
    if (tasks == null) return;
    for (var task in tasks) {
      await FlutterDownloader.remove(taskId: task.taskId);
    }
    appUpdateTaskId = '';
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
        await FlutterDownloader.open(taskId: appUpdateTaskId);
        await _clearAppUpdate();
        break;
      case UpdaterAction.exposeAppFile:
        await _exposeAppUpdateFile();
        break;
    }
  }

  static const portName = 'downloaderPort';
}
