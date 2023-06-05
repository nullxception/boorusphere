import 'dart:io';

import 'package:flutter/services.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class FileUtils {
  static const downloadDirName = 'Boorusphere';
  static const pathChannel = MethodChannel('io.chaldeaprjkt.boorusphere/path');

  static Future<String> get downloadPath async {
    return await pathChannel.invokeMethod('getDownload');
  }

  static Future<Directory> get downloadDir async {
    final path = await downloadPath;
    return Directory('$path/$downloadDirName');
  }

  static Future<File> get noMediaFile async {
    final dir = await downloadDir;
    return File('${dir.absolute.path}/.nomedia');
  }

  static Future<bool> get hasNoMediaFile async {
    final file = await noMediaFile;
    return file.existsSync();
  }

  static Future<void> createDownloadDir() async {
    final status = await Permission.storage.request();
    if (status != PermissionStatus.granted) {
      return;
    }

    final dir = await downloadDir;
    await dir.create();
  }

  static Future<void> rescanDir(Directory dir) async {
    if (Platform.isAndroid) {
      await MediaScanner.loadMedia(path: dir.path);
    }
  }

  static Future<void> rescanDownloadDir() async {
    final dir = await downloadDir;
    if (Platform.isAndroid) {
      await MediaScanner.loadMedia(path: dir.path);
    }
  }

  static Future<void> createNoMediaFile() async {
    await FileUtils.createDownloadDir();
    final file = await noMediaFile;
    final dir = file.parent;
    if (!file.existsSync()) {
      await file.create();
    }
    await rescanDir(dir);
  }

  static Future<void> removeNoMediaFile() async {
    final file = await noMediaFile;
    final dir = file.parent;
    if (file.existsSync()) {
      await file.delete();
    }
    await rescanDir(dir);
  }
}
