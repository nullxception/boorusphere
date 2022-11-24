class PixelSize {
  const PixelSize({
    this.width = -1,
    this.height = -1,
  });

  final int width;
  final int height;

  bool get hasPixels => width + height > 0;

  double get aspectRatio => width / height;

  @override
  String toString() => hasPixels ? '${width}x$height' : 'unknown size';
}
