import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';

class QuickBar extends StatelessWidget {
  factory QuickBar({
    Key? key,
    Widget? title,
  }) =>
      QuickBar._(
        key: key,
        title: title,
      );
  const QuickBar._({
    super.key,
    this.title,
    this.actionTitle,
    this.onPressed,
    this.useProgressBar = false,
    this.progress,
  });

  factory QuickBar.action({
    Key? key,
    Widget? title,
    Widget? actionTitle,
    required VoidCallback onPressed,
  }) =>
      QuickBar._(
        key: key,
        title: title,
        actionTitle: actionTitle,
        onPressed: onPressed,
      );

  factory QuickBar.progress({
    Key? key,
    Widget? title,
    double? progress,
  }) =>
      QuickBar._(
        key: key,
        title: title,
        progress: progress,
        useProgressBar: true,
      );

  final Widget? title;
  final VoidCallback? onPressed;
  final Widget? actionTitle;
  final double? progress;
  final bool useProgressBar;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 50,
        minHeight: 50,
        maxHeight: 50,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: context.colorScheme.surface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Material(
                  textStyle: context.theme.textTheme.bodySmall,
                  type: MaterialType.transparency,
                  child: title!,
                ),
              ),
            if (actionTitle != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  textStyle: context.theme.textTheme.bodySmall,
                ),
                onPressed: onPressed,
                child: actionTitle!,
              ),
            if (useProgressBar)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: context.theme.colorScheme.background,
                ),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(2),
                child: SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(
                      context.colorScheme.primary.withOpacity(0.75),
                    ),
                    value: progress,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
