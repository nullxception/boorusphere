import 'package:flutter/widgets.dart';

enum HidingDirection {
  toStart,
  toTop,
  toEnd,
  toBottom;
}

class SlideFadeVisibility extends StatelessWidget {
  const SlideFadeVisibility({
    super.key,
    required this.visible,
    required this.child,
    required this.direction,
    this.duration = const Duration(milliseconds: 300),
  });

  final bool visible;
  final Widget child;
  final HidingDirection direction;
  final Duration duration;

  Offset get endOffset {
    switch (direction) {
      case HidingDirection.toBottom:
        return const Offset(0, 1);
      case HidingDirection.toTop:
        return const Offset(0, -1);
      case HidingDirection.toStart:
        return const Offset(-1, 0);
      case HidingDirection.toEnd:
        return const Offset(1, 0);
      default:
        return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      curve: Curves.easeInCubic,
      duration: duration,
      offset: visible ? Offset.zero : endOffset,
      child: AnimatedOpacity(
        duration: duration,
        opacity: visible ? 1 : 0,
        child: child,
      ),
    );
  }
}
