import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final slidingDrawerController = ChangeNotifierProvider((ref) {
  return SlidingDrawerController(ref);
});

class SlidingDrawerController extends ChangeNotifier {
  SlidingDrawerController(this.ref);

  final Ref ref;

  AnimationController? _animator;
  bool get isOpen => _animator?.isCompleted ?? false;

  void setAnimator(AnimationController controller) {
    _animator = controller;
  }

  void open() {
    _animator?.forward();
  }

  void close() {
    _animator?.reverse();
  }

  void toggle() {
    final ani = _animator;
    if (ani != null && !ani.isAnimating) {
      ani.isCompleted ? close() : open();
    }
  }
}
