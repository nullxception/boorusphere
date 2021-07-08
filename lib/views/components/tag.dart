import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Tag extends HookWidget {
  final String tag;
  final Function() active;
  final Function() onPressed;

  Tag({
    Key? key,
    required this.tag,
    required this.active,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isClicked = useState(false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
      child: SizedBox(
        height: 28,
        child: TextButton(
          onPressed: () {
            isClicked.value = !isClicked.value;
            onPressed();
          },
          child: Text(
            tag,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade200
                  : Colors.grey.shade800,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            minimumSize: const Size(1, 1),
            backgroundColor: isClicked.value
                ? Theme.of(context).colorScheme.secondary
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200),
          ),
        ),
      ),
    );
  }
}
