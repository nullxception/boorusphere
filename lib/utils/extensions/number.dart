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
    if (expectedTotalBytes != null) {
      return cumulativeBytesLoaded / expectedTotalBytes!;
    }
  }

  int? get progressPercentage {
    return progressRatio?.percentage;
  }
}
