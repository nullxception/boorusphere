import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/images.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

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

  String get faviconUrl {
    final uri = url.toUri();
    if (!uri.hasAuthority) return '';
    return 'https://icons.duckduckgo.com/ip3/${uri.host}.ico';
  }

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
        child: faviconUrl.isNotEmpty
            ? ExtendedImage.network(
                faviconUrl,
                width: iconSize ?? context.iconTheme.size,
                height: iconSize ?? context.iconTheme.size,
                shape: shape,
                fit: BoxFit.contain,
                printError: false,
                loadStateChanged: (state) =>
                    state.isCompleted ? state.completedWidget : fallbackWidget,
              )
            : fallbackWidget,
      ),
    );
  }
}
