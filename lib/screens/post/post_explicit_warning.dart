import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';

class PostExplicitWarningCard extends StatelessWidget {
  const PostExplicitWarningCard({super.key, required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: context.theme.cardColor,
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(left: 32, right: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
            child: Text(
              'This media may contain material that is not safe for public viewing.',
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(elevation: 0),
            onPressed: onConfirm,
            child: const Text('Show me'),
          )
        ],
      ),
    );
  }
}
