import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final homeDrawerControllerProvider = Provider.autoDispose<HomeDrawerController>(
    (ref) => throw UnimplementedError());

class HomeDrawerController {
  AnimationController? _animator;

  void setAnimator(AnimationController controller) {
    _animator = controller;
  }

  void open() {
    _animator?.forward();
  }

  Future<void> close() async {
    await _animator?.reverse();
  }

  void toggle() {
    final ani = _animator;
    if (ani != null && !ani.isAnimating) {
      ani.isCompleted ? close() : open();
    }
  }
}
