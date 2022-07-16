import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/booru_post.dart';
import '../model/download_entry.dart';
import 'hive_boxes.dart';

class DownloadInfo {
  final String id;
  final DownloadTaskStatus status;
  final int progress;

  DownloadInfo({
    required this.id,
    required this.status,
    required this.progress,
  });

  static DownloadInfo none =
      DownloadInfo(id: '', status: DownloadTaskStatus.undefined, progress: 0);
}

class Downloader extends ChangeNotifier {
  Downloader(this.read);

  final Reader read;
  final _port = ReceivePort();
  final entries = <DownloadEntry>[];
  final statuses = <DownloadInfo>[];

  static const _portName = 'downloaderPort';
  static const platformPath = MethodChannel('io.chaldeaprjkt.boorusphere/path');
  static const _booruDirname = 'Boorusphere';

  Future<void> register() async {
    await FlutterDownloader.initialize();
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(_port.sendPort, _portName);
    _port.listen((message) {
      updateInfo(DownloadInfo(
        id: message[0],
        status: message[1],
        progress: message[2],
      ));
    });
    FlutterDownloader.registerCallback(flutterDownloaderCallback);
    populateDownloadTasks();
  }

  Future<void> unregister() async {
    IsolateNameServer.removePortNameMapping(_portName);
  }

  Future<String> get platformDownloadPath async =>
      await platformPath.invokeMethod('getDownload');

  Future<bool> isDirWritable(String dirPath) async {
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

  Future<void> download(BooruPost post) async {
    final downloadPath = await platformDownloadPath;

    if (!await isDirWritable(downloadPath)) {
      await Permission.storage.request();
    }

    final booruDir = Directory('$downloadPath/$_booruDirname');
    final booruDirExists = await booruDir.exists();
    if (await isDirWritable(downloadPath) && !booruDirExists) {
      await booruDir.create();
    }

    final taskId = await FlutterDownloader.enqueue(
        url: post.src,
        savedDir: booruDir.absolute.path,
        showNotification: true,
        openFileFromNotification: true);

    if (taskId != null) {
      final destination =
          '${booruDir.absolute.path}/${getFileNameFromUrl(post.src)}';
      final entry =
          DownloadEntry(id: taskId, booru: post, destination: destination);
      final box = await read(downloadBox);
      box.put(taskId, entry);
      entries.add(entry);
      notifyListeners();
    }
  }

  @pragma('vm:entry-point')
  static void flutterDownloaderCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    IsolateNameServer.lookupPortByName(_portName)?.send([id, status, progress]);
  }

  void updateInfo(DownloadInfo info) {
    statuses.removeWhere((el) => el.id == info.id);
    statuses.add(info);
    notifyListeners();
  }

  DownloadInfo getStatus(String url) => statuses.firstWhere(
      (it) =>
          it.id ==
          entries
              .firstWhere((it) => it.booru.src == url,
                  orElse: () => DownloadEntry.empty)
              .id,
      orElse: () => DownloadInfo.none);

  Future<void> clearAllTask() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks != null) {
      await Future.wait(tasks.map((e) async => await FlutterDownloader.remove(
          taskId: e.taskId, shouldDeleteContent: false)));
    }

    final box = await read(downloadBox);
    if (box.values.isNotEmpty) {
      box.deleteAll(box.keys);
    }

    statuses.clear();
    entries.clear();
    notifyListeners();
  }

  Future<void> populateDownloadTasks() async {
    final tasks = await FlutterDownloader.loadTasks();
    final box = await read(downloadBox);
    if (tasks != null) {
      statuses.addAll(tasks
          .map((e) => DownloadInfo(
                id: e.taskId,
                status: e.status,
                progress: e.progress,
              ))
          .toList());
      if (box.values.isNotEmpty) {
        entries.addAll(box.values.cast<DownloadEntry>());
      }
      notifyListeners();
    }
  }

  Future<void> clearTask({required String id}) async {
    await FlutterDownloader.remove(taskId: id, shouldDeleteContent: false);
    read(downloadBox).then((it) => it.delete(id));
    statuses.removeWhere((it) => it.id == id);
    entries.removeWhere((it) => it.id == id);
    notifyListeners();
  }
}

final downloadProvider = ChangeNotifierProvider((ref) => Downloader(ref.read));
