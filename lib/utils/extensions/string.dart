import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart';

extension StringExt on String {
  String get mimeType {
    return lookupMimeType(fileName) ?? 'application/octet-stream';
  }

  String get capitalized {
    return isEmpty ? this : this[0].toUpperCase() + substring(1);
  }

  Uri get asUri {
    return Uri.parse(this);
  }

  String get asDecoded {
    return Uri.decodeFull(this);
  }

  String get fileName {
    return basename(File(this).path);
  }

  String get fileExtension {
    return extension(File(this).path).replaceFirst('.', '');
  }

  List<String> toWordList() {
    return replaceAll(RegExp('\\s+'), ' ').trim().split(' ');
  }
}
