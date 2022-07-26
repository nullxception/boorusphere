import 'package:flutter/material.dart';

class AppbarVisibility extends StatelessWidget implements PreferredSize {
  const AppbarVisibility({
    super.key,
    required this.visible,
    required this.child,
    required this.controller,
  });

  final AnimationController controller;
  final bool visible;

  @override
  final PreferredSizeWidget child;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    visible ? controller.reverse() : controller.forward();
    return SlideTransition(
      position:
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1)).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInQuint),
      ),
      child: child,
    );
  }
}

class BottomBarVisibility extends StatelessWidget {
  const BottomBarVisibility({
    super.key,
    required this.visible,
    required this.child,
    required this.controller,
  });

  final AnimationController controller;
  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    visible ? controller.reverse() : controller.forward();
    return SlideTransition(
      position:
          Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1)).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInQuint),
      ),
      child: child,
    );
  }
}
