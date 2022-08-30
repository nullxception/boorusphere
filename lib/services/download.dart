import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../entity/app_version.dart';
import '../entity/download_entry.dart';
import '../entity/download_progress.dart';
import '../entity/download_status.dart';
import '../entity/post.dart';
import '../source/version.dart';
import '../utils/download.dart';
import '../utils/extensions/string.dart';

final downloadProvider = ChangeNotifierProvider(DownloadService.new);

enum UpdaterAction {
  stop,
  start,
  exposeAppFile,
  install;
}

class DownloadService extends ChangeNotifier {
  DownloadService(this.ref) {
    _initLazily();
  }

  final Ref ref;
  final entries = <DownloadEntry>[];
  final progresses = <DownloadProgress>{};
  late final _port = ReceivePort();

  Box get _box => Hive.box('downloads');

  Future<void> _initLazily() async {
    if (!FlutterDownloader.initialized) {
      await FlutterDownloader.initialize();
      FlutterDownloader.registerCallback(flutterDownloaderCallback);
    }
    await _populateDownloadEntries();
    IsolateNameServer.registerPortWithName(_port.sendPort, _portName);
    _port.listen((message) {
      final DownloadTaskStatus status = message[1];
      final newProg = DownloadProgress(
        id: message[0],
        status: DownloadStatus.fromIndex(status.value),
        progress: message[2],
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      _updateDownloadProgress(newProg);
    });
  }

  @pragma('vm:entry-point')
  static void flutterDownloaderCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    IsolateNameServer.lookupPortByName(_portName)?.send([id, status, progress]);
  }

  void _updateDownloadProgress(DownloadProgress prog) {
    progresses.removeWhere((el) => el.id == prog.id);
    progresses.add(prog);
    if (prog.status.isDownloaded) {
      DownloadUtils.rescanMedia();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping(_portName);
    super.dispose();
  }

  Future<void> _populateDownloadEntries() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks != null) {
      progresses.addAll(tasks
          .map((e) => DownloadProgress(
                id: e.taskId,
                status: DownloadStatus.fromIndex(e.status.value),
                progress: e.progress,
                timestamp: e.timeCreated,
              ))
          .toList());
      if (_box.values.isNotEmpty) {
        entries.addAll(_box.values.cast<DownloadEntry>());
      }
      notifyListeners();
    }
  }

  Future<void> _addEntry({required DownloadEntry entry}) async {
    entries.add(entry);
    await _box.put(entry.id, entry);
  }

  Future<void> _updateEntry(
      {required String id, required DownloadEntry newEntry}) async {
    await _removeEntry(id: id);
    entries.add(newEntry);
    await _box.put(newEntry.id, newEntry);
  }

  Future<void> _removeEntry({required String id}) async {
    progresses.removeWhere((it) => it.id == id);
    entries.removeWhere((it) => it.id == id);
    await _box.delete(id);
  }

  Future<void> clearEntries() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks != null) {
      await Future.wait(tasks.map((e) async => await FlutterDownloader.remove(
          taskId: e.taskId, shouldDeleteContent: false)));
    }

    if (_box.values.isNotEmpty) {
      await _box.deleteAll(_box.keys);
    }

    progresses.clear();
    entries.clear();
    notifyListeners();
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
      await _addEntry(entry: entry);
      notifyListeners();
    }
  }

  Future<void> retryEntry({required String id}) async {
    final newId = await FlutterDownloader.retry(taskId: id);
    if (newId != null) {
      final newEntry =
          entries.firstWhere((it) => it.id == id).copyWith(id: newId);
      await _updateEntry(id: id, newEntry: newEntry);
      notifyListeners();
    }
  }

  Future<void> cancelEntry({required String id}) async {
    await FlutterDownloader.cancel(taskId: id);
  }

  Future<void> clearEntry({required String id}) async {
    await FlutterDownloader.remove(taskId: id, shouldDeleteContent: false);
    await _removeEntry(id: id);
    notifyListeners();
  }

  void openEntryFile({required String id}) {
    FlutterDownloader.open(taskId: id);
  }

  DownloadProgress getProgressByPost(Post post) {
    final entry = entries.lastWhere((it) => it.post == post,
        orElse: () => DownloadEntry.empty);
    return getProgress(entry.id);
  }

  DownloadProgress getProgress(String id) {
    return progresses.lastWhere((it) => it.id == id,
        orElse: () => DownloadProgress.none);
  }

  String _appUpdateTaskId = '';
  AppVersion _appUpdateVersion = AppVersion.zero;

  DownloadProgress get appUpdateProgress => getProgress(_appUpdateTaskId);

  String _getAppUpdateFile(AppVersion version) {
    return 'boorusphere-$version-${VersionDataSource.arch}.apk';
  }

  Future<Directory> get _appUpdateDir async {
    final dir = await getApplicationSupportDirectory();
    return Directory(path.join(dir.absolute.path, 'app-update'));
  }

  Future<void> _startAppUpdate(AppVersion version) async {
    await _stopAppUpdate();
    final file = _getAppUpdateFile(version);
    final url = '${VersionDataSource.gitUrl}/releases/download/$version/$file';
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
      _appUpdateVersion = version;
      _appUpdateTaskId = id;
    }
  }

  Future<void> _stopAppUpdate() async {
    if (_appUpdateTaskId.isEmpty) return;
    await FlutterDownloader.remove(
      taskId: _appUpdateTaskId,
      shouldDeleteContent: true,
    );
    _appUpdateTaskId = '';
  }

  _clearAppUpdate() async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE file_name LIKE \'%.apk\'');
    if (tasks == null) return;
    for (var task in tasks) {
      await FlutterDownloader.remove(taskId: task.taskId);
    }
    _appUpdateTaskId = '';
  }

  Future<void> _exposeAppUpdateFile() async {
    final file = _getAppUpdateFile(_appUpdateVersion);
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
    if (version != null) _appUpdateVersion = version;
    switch (action) {
      case UpdaterAction.start:
        await _startAppUpdate(_appUpdateVersion);
        break;
      case UpdaterAction.stop:
        await _stopAppUpdate();
        break;
      case UpdaterAction.install:
        await FlutterDownloader.open(taskId: _appUpdateTaskId);
        await _clearAppUpdate();
        break;
      case UpdaterAction.exposeAppFile:
        await _exposeAppUpdateFile();
        break;
    }
    notifyListeners();
  }

  static const _portName = 'downloaderPort';
}
