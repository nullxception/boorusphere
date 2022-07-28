import 'package:mime/mime.dart';

extension StringExt on String {
  String get mimeType {
    const unkown = 'application/octet-stream';
    if (contains('/')) {
      final part = split('/');
      final name = part.isEmpty ? '' : part.last;
      return lookupMimeType(name) ?? unkown;
    }
    return lookupMimeType(this) ?? unkown;
  }

  String get ext {
    try {
      return split('/').last.split('.').last;
    } catch (e) {
      return '';
    }
  }
}
