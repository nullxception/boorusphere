import 'dart:io';

import 'package:boorusphere/constant/app.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_entry.dart';
import 'package:boorusphere/data/repository/downloads/entity/download_progress.dart';
import 'package:boorusphere/data/repository/version/app_version_repo.dart';
import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/presentation/provider/download/download_state.dart';
import 'package:boorusphere/presentation/provider/shared_storage_handle.dart';
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
  return ref.watch(downloadProgressStateProvider).getById(id);
}

class AppUpdater {
  AppUpdater(this.ref);

  final Ref ref;

  String id = '';
  AppVersion _version = AppVersion.zero;

  String _fileNameOf(AppVersion version) {
    return 'boorusphere-$version-$kAppArch.apk';
  }

  final updateDir = 'app-update';

  Future<Directory> get _tmpDir async {
    final tmp = await getTemporaryDirectory();
    return Directory(path.join(tmp.absolute.path, updateDir));
  }

  Future<void> clear() async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
        query: 'SELECT * FROM task WHERE file_name LIKE \'%.apk\'');
    if (tasks == null) return;
    for (var task in tasks) {
      await ref.read(downloadEntryStateProvider.notifier).remove(task.taskId);
      await FlutterDownloader.remove(
        taskId: task.taskId,
        shouldDeleteContent: true,
      );
    }
    id = '';
  }

  Future<void> start(AppVersion version) async {
    await clear();
    final fileName = _fileNameOf(version);
    final url = '${AppVersionRepo.gitUrl}/releases/download/$version/$fileName';

    final tmp = await _tmpDir;
    if (!tmp.existsSync()) {
      try {
        tmp.createSync();
        // ignore: empty_catches
      } catch (e) {}
    }

    final apk = File(path.join(tmp.absolute.path, fileName));
    if (apk.existsSync()) {
      try {
        apk.deleteSync();
        // ignore: empty_catches
      } catch (e) {}
    }

    final newId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: tmp.absolute.path,
      showNotification: true,
      openFileFromNotification: true,
    );

    if (newId != null) {
      _version = version;
      id = newId;
      final entry = DownloadEntry(
        id: newId,
        post: Post.appReserved,
        dest: path.join(updateDir, fileName),
      );
      await ref.read(downloadEntryStateProvider.notifier).add(entry);
    }
  }

  Future<void> expose() async {
    final sharedStorageHandle = ref.read(sharedStorageHandleProvider);
    final file = _fileNameOf(_version);
    final srcDir = await _tmpDir;

    await sharedStorageHandle.init();
    final destDir = sharedStorageHandle.createSubDir(updateDir);

    final srcApk = File(path.join(srcDir.absolute.path, file));
    final destApk = File(path.join(destDir.absolute.path, file));

    if (srcApk.existsSync() && !destApk.existsSync()) {
      try {
        await srcApk.copy(destApk.absolute.path);
        // ignore: empty_catches
      } catch (e) {}
    }
  }

  Future<void> install() async {
    await FlutterDownloader.open(taskId: id);
  }
}
