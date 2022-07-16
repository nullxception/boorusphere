import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Tag extends HookWidget {
  final String tag;
  final bool Function()? active;
  final Function() onPressed;

  const Tag({
    Key? key,
    required this.tag,
    required this.onPressed,
    this.active,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isClicked = useState(active?.call() ?? false);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
      child: SizedBox(
        height: 28,
        child: TextButton(
          onPressed: () {
            isClicked.value = !isClicked.value;
            onPressed();
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
            minimumSize: const Size(1, 1),
            backgroundColor: isClicked.value
                ? colorScheme.surfaceVariant
                : colorScheme.surface,
            side: BorderSide(width: 1, color: colorScheme.surfaceVariant),
          ),
          child: Text(
            tag,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}
