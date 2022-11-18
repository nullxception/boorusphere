import 'package:boorusphere/data/repository/download/entity/download_entry.dart';
import 'package:boorusphere/data/repository/download/entity/download_progress.dart';
import 'package:boorusphere/data/repository/download/entity/download_status.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive/hive.dart';

class DownloaderSource {
  DownloaderSource(this.box);

  final Box<DownloadEntry> box;

  Iterable<DownloadEntry> get entries => box.values;

  Future<Iterable<DownloadProgress>> get progress async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks == null) return [];

    return tasks.map(
      (it) => DownloadProgress(
        id: it.taskId,
        status: DownloadStatus.fromIndex(it.status.value),
        progress: it.progress,
        timestamp: it.timeCreated,
      ),
    );
  }

  Future<void> add(DownloadEntry entry) async {
    await box.put(entry.id, entry);
  }

  Future<void> remove(String id) async {
    await box.delete(id);
  }

  Future<void> clear() async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks != null) {
      await Future.wait(tasks.map(
        (e) async => await FlutterDownloader.remove(
            taskId: e.taskId, shouldDeleteContent: false),
      ));
    }

    await box.deleteAll(box.keys);
  }

  static const String key = 'downloads';

  static Future<void> prepare() async {
    await Hive.openBox<DownloadEntry>(key);
    await FlutterDownloader.initialize();
  }
}
