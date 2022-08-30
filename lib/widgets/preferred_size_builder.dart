import 'package:flutter/widgets.dart';

class PreferredSizeBuilder extends StatelessWidget
    implements PreferredSizeWidget {
  const PreferredSizeBuilder({
    super.key,
    required this.child,
    required this.builder,
  });

  final PreferredSizeWidget child;
  final Widget Function(BuildContext context, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }

  @override
  Size get preferredSize => child.preferredSize;
}
