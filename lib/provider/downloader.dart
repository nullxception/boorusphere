import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

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

class DownloadEntry {
  final String id;
  final String url;

  DownloadEntry({
    required this.id,
    required this.url,
  });

  static DownloadEntry none = DownloadEntry(id: '', url: '');
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

  Future<void> download(url) async {
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
        url: url,
        savedDir: booruDir.absolute.path,
        showNotification: true,
        openFileFromNotification: true);

    if (taskId != null) {
      entries.add(DownloadEntry(id: taskId, url: url));
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
              .firstWhere((it) => it.url == url,
                  orElse: () => DownloadEntry.none)
              .id,
      orElse: () => DownloadInfo.none);

  Future<void> populateDownloadTasks() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks != null) {
      statuses.addAll(tasks
          .map((e) => DownloadInfo(
                id: e.taskId,
                status: e.status,
                progress: e.progress,
              ))
          .toList());

      entries.addAll(tasks
          .map((e) => DownloadEntry(
                id: e.taskId,
                url: e.url,
              ))
          .toList());

      notifyListeners();
    }
  }
}

final downloadProvider = ChangeNotifierProvider((ref) => Downloader(ref.read));
