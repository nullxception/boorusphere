import 'dart:async';

import 'package:boorusphere/presentation/utils/entity/pixel_size.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';

extension ImageProviderExt<T> on ImageProvider {
  Future<PixelSize> resolvePixelSize() {
    final completer = Completer<PixelSize>();
    final resolver = resolve(const ImageConfiguration());
    final onComplete = ImageStreamListener((image, synchronousCall) {
      completer.complete(PixelSize(
        width: image.image.width,
        height: image.image.height,
      ));
    });
    resolver.addListener(onComplete);
    completer.future.whenComplete(() => resolver.removeListener(onComplete));
    return completer.future;
  }
}

extension ExtendedImageStateExt on ExtendedImageState {
  bool get isFailed {
    return extendedImageLoadState == LoadState.failed;
  }

  bool get isCompleted {
    return extendedImageLoadState == LoadState.completed;
  }

  Future<void> reload(
    Function() block, {
    Duration until = const Duration(milliseconds: 150),
  }) async {
    Future.delayed(until, (() {
      reLoadImage();
      block.call();
    }));
  }
}
