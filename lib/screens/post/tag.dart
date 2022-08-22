import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../utils/extensions/buildcontext.dart';

class Tag extends HookWidget {
  const Tag({
    super.key,
    required this.tag,
    this.onPressed,
    this.active = false,
  });

  final String tag;
  final bool active;
  final Function(bool isActive)? onPressed;

  @override
  Widget build(BuildContext context) {
    final isClicked = useState(active);
    final colorScheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
      child: TextButton(
        onPressed: onPressed != null
            ? () {
                isClicked.value = !isClicked.value;
                onPressed?.call(isClicked.value);
              }
            : null,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          minimumSize: const Size(1, 1),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: isClicked.value
              ? colorScheme.surfaceVariant
              : colorScheme.surface,
          side: BorderSide(width: 1, color: colorScheme.surfaceVariant),
          elevation: 0,
        ),
        child: Text(
          tag,
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
    );
  }
}
