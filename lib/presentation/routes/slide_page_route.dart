import 'package:flutter/material.dart';

enum SlidePageType { open, close, both }

class SlidePageRoute<T> extends PageRoute<T> {
  SlidePageRoute({
    required this.builder,
    super.settings,
    this.duration = const Duration(milliseconds: 300),
    this.barrierColor = Colors.transparent,
    this.barrierLabel,
    this.maintainState = true,
    this.type = SlidePageType.both,
    this.opaque = true,
  });

  final Duration duration;

  final SlidePageType type;

  final Widget Function(BuildContext context) builder;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState;

  @override
  final bool opaque;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final nextAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );
    final prevAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOutCubic,
    );

    final fade = FadeTransition(
      opacity: Tween(
        begin: 0.0,
        end: 1.0,
      ).animate(nextAnimation),
      child: child,
    );

    Widget open(Widget child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(nextAnimation),
        child: child,
      );
    }

    Widget close(Widget child) {
      return SlideTransition(
        position: Tween(
          begin: Offset.zero,
          end: const Offset(-0.1, 0),
        ).animate(prevAnimation),
        child: child,
      );
    }

    switch (type) {
      case SlidePageType.open:
        return open(fade);
      case SlidePageType.close:
        return close(fade);
      default:
        return open(close(fade));
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }
}
