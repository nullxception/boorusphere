import 'package:flutter/material.dart';

class ReMaterialPageRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  ReMaterialPageRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    this.maintainState = true,
    this.opaque = true,
  });

  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  final bool maintainState;

  @override
  final bool opaque;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
