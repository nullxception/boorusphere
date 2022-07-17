import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../../model/booru_post.dart';

class PostErrorDisplay extends StatelessWidget {
  const PostErrorDisplay({super.key, required this.booru});

  final BooruPost booru;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ExtendedImage.network(
              booru.thumbnail,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              enableLoadState: false,
            ),
            Card(
              margin: const EdgeInsets.fromLTRB(16, 32, 16, 32),
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Text(
                  '${booru.mimeType} is unsupported at the moment',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
