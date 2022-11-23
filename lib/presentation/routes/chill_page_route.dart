import 'package:flutter/material.dart';

class ChillPageRoute<T> extends MaterialPageRoute<T> {
  ChillPageRoute({
    required super.builder,
    super.settings,
    this.duration = const Duration(milliseconds: 400),
  });

  final Duration duration;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  static MaterialPageRoute<T> build<T>(
    BuildContext context,
    Widget child,
    RouteSettings? settings,
  ) {
    return ChillPageRoute(
      settings: settings,
      builder: (context) => child,
    );
  }
}
