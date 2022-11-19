import 'dart:isolate';
import 'dart:ui';

import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/data/repository/download/entity/download_status.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flutter_downloader_handle.g.dart';

@riverpod
class FlutterDownloaderHandle extends _$FlutterDownloaderHandle {
  final receiver = ReceivePort();

  @override
  void build() {
    ref.onDispose(() {
      if (IsolateNameServer.lookupPortByName(_name) != null) {
        IsolateNameServer.removePortNameMapping(_name);
      }
    });
    if (IsolateNameServer.lookupPortByName(_name) != null) {
      IsolateNameServer.removePortNameMapping(_name);
    }
    IsolateNameServer.registerPortWithName(
      receiver.sendPort,
      _name,
    );
    FlutterDownloader.registerCallback(_onProgressUpdated);
  }

  static const _name = 'flutterDownloaderHandle';

  void listen(void Function(DownloadProgress progress) onUpdate) {
    receiver.listen((data) {
      final DownloadTaskStatus status = data[1];
      final progress = DownloadProgress(
        id: data[0],
        status: DownloadStatus.fromIndex(status.value),
        progress: data[2],
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      onUpdate(progress);
    });
  }

  @pragma('vm:entry-point')
  static void _onProgressUpdated(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    IsolateNameServer.lookupPortByName(_name)?.send([id, status, progress]);
  }
}
