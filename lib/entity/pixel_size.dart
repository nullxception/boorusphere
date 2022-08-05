import 'package:freezed_annotation/freezed_annotation.dart';

part 'pixel_size.freezed.dart';

@freezed
class PixelSize with _$PixelSize {
  const factory PixelSize({
    @Default(-1) int width,
    @Default(-1) int height,
  }) = _PixelSize;
  const PixelSize._();

  bool get hasPixels => width + height > 0;

  double get aspectRatio => width / height;

  @override
  String toString() => hasPixels ? '${width}x$height' : 'unknown size';
}
