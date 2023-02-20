import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final homeDrawerControllerProvider =
    ChangeNotifierProvider.autoDispose<HomeDrawerController>(
        (ref) => throw UnimplementedError());

class HomeDrawerController extends ChangeNotifier {
  AnimationController? _animator;

  bool get isOpen => _animator?.isCompleted ?? false;

  void setAnimator(AnimationController controller) {
    if (_animator != null) return;
    _animator = controller;
    _animator?.addListener(notifyListeners);
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

  @override
  void dispose() {
    _animator?.removeListener(notifyListeners);
    _animator = null;
    super.dispose();
  }
}
