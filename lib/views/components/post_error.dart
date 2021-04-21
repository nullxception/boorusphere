import 'package:flutter/material.dart';

class PostErrorDisplay extends StatelessWidget {
  const PostErrorDisplay({Key? key, required this.mime}) : super(key: key);

  final String mime;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(16, 32, 16, 32),
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Text(
              '$mime is unsupported at the moment',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
