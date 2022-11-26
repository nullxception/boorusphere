import 'package:mime/mime.dart';
import 'package:path/path.dart';

extension StringExt on String {
  String get mimeType {
    return lookupMimeType(fileName) ?? 'application/octet-stream';
  }

  String get fileName {
    return basename(toUri().path);
  }

  String get fileExt {
    return extension(toUri().path).replaceFirst('.', '');
  }

  Uri toUri() {
    return Uri.parse(this);
  }

  List<String> toWordList() {
    return replaceAll(RegExp('\\s+'), ' ')
        .trim()
        .split(' ')
        .where((it) => it.isNotEmpty)
        .toList();
  }
}
