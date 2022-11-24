import 'package:boorusphere/utils/extensions/string.dart';

enum PostType {
  video,
  photo,
  unsupported,
}

class Content {
  const Content({
    required this.type,
    required this.url,
  });

  final PostType type;
  final String url;

  bool get isPhoto => type == PostType.photo;
  bool get isVideo => type == PostType.video;
  bool get isUnsupported => type == PostType.unsupported;
}

extension ContentExt on String {
  Content asContent() {
    PostType type;
    if (mimeType.startsWith('video')) {
      type = PostType.video;
    } else if (mimeType.startsWith('image')) {
      type = PostType.photo;
    } else {
      type = PostType.unsupported;
    }
    return Content(type: type, url: this);
  }
}
