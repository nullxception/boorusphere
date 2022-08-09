import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../utils/extensions/buildcontext.dart';

class Favicon extends StatelessWidget {
  const Favicon({
    super.key,
    required this.url,
    this.size,
  });

  final String url;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      width: size ?? context.iconTheme.size,
      height: size ?? context.iconTheme.size,
      shape: BoxShape.circle,
      fit: BoxFit.contain,
      loadStateChanged: (state) =>
          state.extendedImageLoadState == LoadState.completed
              ? state.completedWidget
              : const Icon(Icons.public),
    );
  }
}
