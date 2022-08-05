import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

FloatingSearchBarController useFloatingSearchBarController({
  String? debugLabel,
  List<Object?>? keys,
}) {
  return use(
    _FloatingSearchBarControllerHook(
      debugLabel: debugLabel,
      keys: keys,
    ),
  );
}

class _FloatingSearchBarControllerHook
    extends Hook<FloatingSearchBarController> {
  const _FloatingSearchBarControllerHook({
    this.debugLabel,
    super.keys,
  });

  final String? debugLabel;

  @override
  HookState<FloatingSearchBarController, Hook<FloatingSearchBarController>>
      createState() => _FloatingSearchBarControllerHookState();
}

class _FloatingSearchBarControllerHookState extends HookState<
    FloatingSearchBarController, _FloatingSearchBarControllerHook> {
  late final controller = FloatingSearchBarController();

  @override
  FloatingSearchBarController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'useFloatingSearchBarController';
}
