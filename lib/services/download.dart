import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../entity/download_entry.dart';
import '../entity/download_progress.dart';
import '../entity/download_status.dart';
import '../entity/post.dart';
import '../utils/download.dart';
import '../utils/extensions/string.dart';

final downloadProvider = ChangeNotifierProvider((ref) => DownloadService(ref));

class DownloadService extends ChangeNotifier {
  DownloadService(this.ref);

  final Ref ref;
  final _port = ReceivePort();
  final entries = <DownloadEntry>[];
  final progresses = <DownloadProgress>{};

  Box get _box => Hive.box('downloads');

  Future<void> register() async {
    await FlutterDownloader.initialize();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(_port.sendPort, _portName);
    _port.listen((message) {
      final DownloadTaskStatus status = message[1];
      final newProg = DownloadProgress(
        id: message[0],
        status: DownloadStatus.fromIndex(status.value),
        progress: message[2],
      );
      _updateDownloadProgress(newProg);
    });
    FlutterDownloader.registerCallback(flutterDownloaderCallback);
    _populateDownloadEntries();
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

  void unregister() {
    IsolateNameServer.removePortNameMapping(_portName);
  }

  Future<void> _populateDownloadEntries() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks != null) {
      progresses.addAll(tasks
          .map((e) => DownloadProgress(
                id: e.taskId,
                status: DownloadStatus.fromIndex(e.status.value),
                progress: e.progress,
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
    _removeEntry(id: id);
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
      _box.deleteAll(_box.keys);
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
      _addEntry(entry: entry);
      notifyListeners();
    }
  }

  Future<void> retryEntry({required String id}) async {
    final newId = await FlutterDownloader.retry(taskId: id);
    if (newId != null) {
      final newEntry =
          entries.firstWhere((it) => it.id == id).copyWith(id: newId);
      _updateEntry(id: id, newEntry: newEntry);
      notifyListeners();
    }
  }

  Future<void> cancelEntry({required String id}) async {
    await FlutterDownloader.cancel(taskId: id);
  }

  Future<void> clearEntry({required String id}) async {
    await FlutterDownloader.remove(taskId: id, shouldDeleteContent: false);
    _removeEntry(id: id);
    notifyListeners();
  }

  void openEntryFile({required String id}) {
    FlutterDownloader.open(taskId: id);
  }

  DownloadProgress getProgressByURL(String url) {
    final entry = entries.firstWhere((it) => it.post.originalFile == url,
        orElse: () => DownloadEntry.empty);
    return getProgress(entry.id);
  }

  DownloadProgress getProgress(String id) {
    return progresses.firstWhere((it) => it.id == id,
        orElse: () => DownloadProgress.none);
  }

  static const _portName = 'downloaderPort';
}
