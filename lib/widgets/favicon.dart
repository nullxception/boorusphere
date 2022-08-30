import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import '../utils/extensions/buildcontext.dart';
import '../utils/extensions/string.dart';

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
    final fallbackWidget = Icon(
      Icons.public,
      size: iconSize ?? context.iconTheme.size,
    );
    return SizedBox(
      width: size ?? context.iconTheme.size,
      height: size ?? context.iconTheme.size,
      child: Center(
        child: url.asUri.hasAuthority
            ? ExtendedImage.network(
                url,
                width: iconSize ?? context.iconTheme.size,
                height: iconSize ?? context.iconTheme.size,
                shape: shape,
                fit: BoxFit.contain,
                printError: false,
                loadStateChanged: (state) =>
                    state.extendedImageLoadState == LoadState.completed
                        ? state.completedWidget
                        : fallbackWidget,
              )
            : fallbackWidget,
      ),
    );
  }
}
