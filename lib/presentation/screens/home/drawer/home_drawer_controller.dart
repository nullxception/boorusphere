import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final homeDrawerController = ChangeNotifierProvider((ref) {
  return HomeDrawerController(ref);
});

class HomeDrawerController extends ChangeNotifier {
  HomeDrawerController(this.ref);

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
