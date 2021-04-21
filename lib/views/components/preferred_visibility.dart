import 'package:flutter/material.dart';

class PreferredVisibility extends StatelessWidget implements PreferredSize {
  const PreferredVisibility(
      {Key? key, required this.visible, required this.child})
      : super(key: key);

  final bool visible;
  final PreferredSizeWidget child;

  @override
  Size get preferredSize => visible ? child.preferredSize : Size.zero;

  @override
  Widget build(BuildContext context) {
    return visible
        ? child
        : const PreferredSize(
            child: SizedBox.shrink(),
            preferredSize: Size.zero,
          );
  }
}
