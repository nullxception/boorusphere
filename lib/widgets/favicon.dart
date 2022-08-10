import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../utils/extensions/buildcontext.dart';

class Favicon extends StatelessWidget {
  const Favicon({
    super.key,
    required this.url,
    this.size,
    this.iconSize,
    this.shape,
  });

  final String url;
  final double? size;
  final double? iconSize;
  final BoxShape? shape;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? context.iconTheme.size,
      height: size ?? context.iconTheme.size,
      child: Center(
        child: ExtendedImage.network(
          url,
          width: iconSize ?? context.iconTheme.size,
          height: iconSize ?? context.iconTheme.size,
          shape: shape,
          fit: BoxFit.contain,
          loadStateChanged: (state) =>
              state.extendedImageLoadState == LoadState.completed
                  ? state.completedWidget
                  : const Icon(Icons.public),
        ),
      ),
    );
  }
}
