import 'dart:io';

import 'package:flutter/services.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadUtils {
  static const dirName = 'Boorusphere';
  static const pathChannel = MethodChannel('io.chaldeaprjkt.boorusphere/path');

  static Future<String> get platformDownloadPath async {
    return await pathChannel.invokeMethod('getDownload');
  }

  static Future<Directory> get downloadDir async {
    final fromPlatform = await platformDownloadPath;
    return Directory('$fromPlatform/$dirName');
  }

  static Future<bool> canWriteTo(String dirPath) async {
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

  static Future<void> createDownloadDir() async {
    final downloadPath = await platformDownloadPath;

    if (!await canWriteTo(downloadPath)) {
      await Permission.storage.request();
    }

    final dir = await downloadDir;
    final dirExists = await dir.exists();
    if (await canWriteTo(downloadPath) && !dirExists) {
      await dir.create();
    }
  }

  static void rescanMedia() async {
    final dir = await downloadDir;
    if (Platform.isAndroid) {
      MediaScanner.loadMedia(path: dir.absolute.path);
    }
  }
}
