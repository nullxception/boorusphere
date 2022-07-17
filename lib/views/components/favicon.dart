import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class Favicon extends StatelessWidget {
  const Favicon({
    super.key,
    required this.url,
  });

  final String url;
  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      width: IconTheme.of(context).size,
      height: IconTheme.of(context).size,
      shape: BoxShape.circle,
      fit: BoxFit.contain,
      loadStateChanged: (state) =>
          state.extendedImageLoadState == LoadState.completed
              ? state.completedWidget
              : const Icon(Icons.public),
    );
  }
}
