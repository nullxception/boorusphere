import 'package:flutter/widgets.dart';

class SlidePageRoute<T> extends PageRoute<T> {
  SlidePageRoute({
    required this.builder,
    super.settings,
    this.duration = const Duration(milliseconds: 300),
    this.barrierColor,
    this.barrierLabel,
    this.maintainState = true,
  });

  final Duration duration;
  final Widget Function(BuildContext context) builder;

  @override
  final Color? barrierColor;

  @override
  final String? barrierLabel;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;

  static PageRoute<T> build<T>(
    BuildContext context,
    Widget child,
    RouteSettings? settings,
  ) {
    return SlidePageRoute(
      settings: settings,
      builder: (context) => child,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final nextAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );
    final prevAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOutCubic,
    );
    return SlideTransition(
      position: Tween(
        begin: const Offset(0.1, 0),
        end: Offset.zero,
      ).animate(nextAnimation),
      child: SlideTransition(
        position: Tween(
          begin: Offset.zero,
          end: const Offset(-0.1, 0),
        ).animate(prevAnimation),
        child: FadeTransition(
          opacity: Tween(
            begin: 0.0,
            end: 1.0,
          ).animate(nextAnimation),
          child: FadeTransition(
            opacity: Tween(
              begin: 1.0,
              end: 0.0,
            ).animate(prevAnimation),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }
}
