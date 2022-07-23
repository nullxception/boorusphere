import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/booru_post.dart';
import '../model/download_entry.dart';
import '../model/download_progress.dart';
import '../model/download_status.dart';
import 'hive_boxes.dart';

final downloadProvider = ChangeNotifierProvider((ref) => Downloader(ref.read));

class Downloader extends ChangeNotifier {
  Downloader(this.read);

  final Reader read;
  final _port = ReceivePort();
  final entries = <DownloadEntry>[];
  final progresses = <DownloadProgress>{};

  static const _portName = 'downloaderPort';
  static const platformPath = MethodChannel('io.chaldeaprjkt.boorusphere/path');
  static const _booruDirname = 'Boorusphere';

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
    notifyListeners();
    if (prog.status.isDownloaded) {
      final entry = entries.firstWhere((it) => it.id == prog.id,
          orElse: () => DownloadEntry.empty);
      _rescanMediaAndroid(entry);
    }
  }

  void _rescanMediaAndroid(DownloadEntry entry) {
    if (Platform.isAndroid && entry.destination.isNotEmpty) {
      MediaScanner.loadMedia(path: entry.destination);
    }
  }

  Future<void> unregister() async {
    IsolateNameServer.removePortNameMapping(_portName);
  }

  Future<String> get platformDownloadPath async {
    return await platformPath.invokeMethod('getDownload');
  }

  Future<void> _populateDownloadEntries() async {
    final tasks = await FlutterDownloader.loadTasks();
    final box = await read(downloadBox);
    if (tasks != null) {
      progresses.addAll(tasks
          .map((e) => DownloadProgress(
                id: e.taskId,
                status: DownloadStatus.fromIndex(e.status.value),
                progress: e.progress,
              ))
          .toList());
      if (box.values.isNotEmpty) {
        entries.addAll(box.values.cast<DownloadEntry>());
      }
      notifyListeners();
    }
  }

  Future<void> _addEntry({required DownloadEntry entry}) async {
    final box = await read(downloadBox);
    box.put(entry.id, entry);
    entries.add(entry);
  }

  Future<void> _updateEntry(
      {required String id, required DownloadEntry newEntry}) async {
    final box = await read(downloadBox);
    _removeEntry(id: id);
    box.put(newEntry.id, newEntry);
    entries.add(newEntry);
  }

  Future<void> _removeEntry({required String id}) async {
    final box = await read(downloadBox);

    box.delete(id);
    progresses.removeWhere((it) => it.id == id);
    entries.removeWhere((it) => it.id == id);
  }

  Future<void> clearEntries() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks != null) {
      await Future.wait(tasks.map((e) async => await FlutterDownloader.remove(
          taskId: e.taskId, shouldDeleteContent: false)));
    }

    final box = await read(downloadBox);
    if (box.values.isNotEmpty) {
      box.deleteAll(box.keys);
    }

    progresses.clear();
    entries.clear();
    notifyListeners();
  }

  Future<bool> _isDirWritable(String dirPath) async {
    final f = File('$dirPath/.boorusphere.tmp');
    try {
      await f.writeAsString('', mode: FileMode.append, flush: true);
      if (!await f.exists()) {
        return false;
      }

      await f.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  String getFileNameFromUrl(String src) {
    return Uri.parse(src)
        .path
        .split('/')
        .lastWhere((it) => it.contains(RegExp(r'.+\..+')));
  }

  Future<void> download(BooruPost post, {String? url}) async {
    final fileUrl = url ?? post.originalFile;
    final downloadPath = await platformDownloadPath;

    if (!await _isDirWritable(downloadPath)) {
      await Permission.storage.request();
    }

    final booruDir = Directory('$downloadPath/$_booruDirname');
    final booruDirExists = await booruDir.exists();
    if (await _isDirWritable(downloadPath) && !booruDirExists) {
      await booruDir.create();
    }

    final taskId = await FlutterDownloader.enqueue(
        url: fileUrl,
        savedDir: booruDir.absolute.path,
        showNotification: true,
        openFileFromNotification: true);

    if (taskId != null) {
      final destination =
          '${booruDir.absolute.path}/${getFileNameFromUrl(fileUrl)}';
      final entry =
          DownloadEntry(id: taskId, booru: post, destination: destination);
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
    final entry = entries.firstWhere((it) => it.id == id,
        orElse: () => DownloadEntry.empty);
    _rescanMediaAndroid(entry);
  }

  DownloadProgress getProgressByURL(String url) {
    final entry = entries.firstWhere((it) => it.booru.originalFile == url,
        orElse: () => DownloadEntry.empty);
    return getProgress(entry.id);
  }

  DownloadProgress getProgress(String id) {
    return progresses.firstWhere((it) => it.id == id,
        orElse: () => DownloadProgress.none);
  }
}
