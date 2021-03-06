import 'package:flutter/material.dart';

import '../../utils/extensions/buildcontext.dart';

class QuickBar extends StatelessWidget {
  const QuickBar._({
    super.key,
    this.title,
    this.actionTitle,
    this.onPressed,
    this.useProgressBar = false,
    this.progress,
  });

  factory QuickBar({
    Key? key,
    Widget? title,
  }) =>
      QuickBar._(
        key: key,
        title: title,
      );

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        color: context.theme.cardColor,
      ),
      padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
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
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                color: context.theme.colorScheme.background,
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(2),
              child: SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: const AlwaysStoppedAnimation(
                    Colors.white54,
                  ),
                  value: progress,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
