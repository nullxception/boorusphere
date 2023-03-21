import 'package:flutter/painting.dart';

extension IntExt on int {
  double get ratio {
    return (1 * this) / 100;
  }
}

extension DoubleExt on double {
  int get percentage {
    return (100 * this).round();
  }
}

extension ImageChunkEventExt on ImageChunkEvent {
  double? get progressRatio {
    final total = expectedTotalBytes;
    if (total != null) {
      return cumulativeBytesLoaded / total;
    }
  }

  int? get progressPercentage {
    return progressRatio?.percentage;
  }
}
