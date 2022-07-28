import 'package:flutter/cupertino.dart';

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
  double get progressRatio {
    return cumulativeBytesLoaded / (expectedTotalBytes ?? 1);
  }

  int get progressPercentage {
    return progressRatio.percentage;
  }
}
