import 'dart:isolate';
import 'dart:ui';

import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/data/repository/download/entity/download_status.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutter_downloader_handle.g.dart';

@Riverpod(keepAlive: true)
FlutterDownloaderHandle downloaderHandle(DownloaderHandleRef ref) {
  final handle = FlutterDownloaderHandle();
  ref.onDispose(handle.dispose);
  return handle;
}

class FlutterDownloaderHandle {
  FlutterDownloaderHandle() {
    dispose();
    IsolateNameServer.registerPortWithName(receiver.sendPort, _name);
    FlutterDownloader.registerCallback(_onProgressUpdated);
  }

  final receiver = ReceivePort();

  void listen(void Function(DownloadProgress progress) onUpdate) {
    receiver.listen((data) {
      final progress = DownloadProgress(
        id: data[0],
        status: DownloadStatus.fromIndex(data[1]),
        progress: data[2],
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      onUpdate(progress);
    });
  }

  void dispose() {
    if (IsolateNameServer.lookupPortByName(_name) != null) {
      IsolateNameServer.removePortNameMapping(_name);
    }
  }

  static const _name = 'DownloaderHandle';

  @pragma('vm:entry-point')
  static void _onProgressUpdated(
    String id,
    int status,
    int progress,
  ) {
    IsolateNameServer.lookupPortByName(_name)?.send([id, status, progress]);
  }
}
