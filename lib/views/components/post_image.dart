import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostImageDisplay extends StatelessWidget {
  const PostImageDisplay({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return PhotoView(
      minScale: PhotoViewComputedScale.contained,
      imageProvider: CachedNetworkImageProvider(url),
      loadingBuilder: (_, ev) => Center(
        child: SizedBox(
          width: 92,
          height: 92,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white.withAlpha(200),
            ),
            value: ev != null && ev.expectedTotalBytes != null
                ? ev.cumulativeBytesLoaded / (ev.expectedTotalBytes ?? 1)
                : null,
          ),
        ),
      ),
    );
  }
}
