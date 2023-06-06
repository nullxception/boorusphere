import 'dart:io';

import 'package:flutter/services.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class FileUtils {
  FileUtils._({required String platformDownloadPath})
      : _platformDownloadPath = platformDownloadPath;

  final String _platformDownloadPath;

  String get downloadPath {
    return path.join(_platformDownloadPath, 'Boorusphere');
  }

  File get noMediaFile {
    return File(path.join(downloadPath, '.nomedia'));
  }

  Future<void> createDownloadDir() async {
    final status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      return;
    }

    await Directory(downloadPath).create();
  }

  Future<void> rescan(String dirPath) async {
    if (Platform.isAndroid) {
      await MediaScanner.loadMedia(path: dirPath);
    }
  }

  Future<void> rescanDownloadDir() async {
    await rescan(downloadPath);
  }

  Future<void> createNoMediaFile() async {
    await createDownloadDir();
    if (!noMediaFile.existsSync()) {
      await noMediaFile.create();
    }
    await rescan(noMediaFile.parent.path);
  }

  Future<void> removeNoMediaFile() async {
    if (noMediaFile.existsSync()) {
      await noMediaFile.delete();
    }
    await rescan(noMediaFile.parent.path);
  }

  static FileUtils? _instance;

  static FileUtils get instance {
    final instance = _instance;
    if (instance == null) {
      throw Exception('FileUtils must be initialized');
    }

    return instance;
  }

  static Future<void> initialize() async {
    const channel = MethodChannel('io.chaldeaprjkt.boorusphere/path');
    final downloadPath = await channel.invokeMethod('getDownload');
    _instance = FileUtils._(platformDownloadPath: downloadPath);
  }
}
