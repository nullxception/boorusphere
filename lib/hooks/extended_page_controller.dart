import 'package:extended_image/extended_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

ExtendedPageController useExtendedPageController({
  int initialPage = 0,
  bool keepPage = true,
  double viewportFraction = 1.0,
  List<Object?>? keys,
}) {
  return use(
    _ExtendedPageControllerHook(
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
      keys: keys,
    ),
  );
}

class _ExtendedPageControllerHook extends Hook<ExtendedPageController> {
  const _ExtendedPageControllerHook({
    required this.initialPage,
    required this.keepPage,
    required this.viewportFraction,
    super.keys,
  });

  final int initialPage;
  final bool keepPage;
  final double viewportFraction;

  @override
  HookState<ExtendedPageController, Hook<ExtendedPageController>>
      createState() => _ExtendedPageControllerHookState();
}

class _ExtendedPageControllerHookState
    extends HookState<ExtendedPageController, _ExtendedPageControllerHook> {
  late final controller = ExtendedPageController(
    initialPage: hook.initialPage,
    keepPage: hook.keepPage,
    viewportFraction: hook.viewportFraction,
  );

  @override
  ExtendedPageController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useExtendedPageController';
}
