import 'dart:async';

import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void>? showSystemAppSettingsDialog({
  required BuildContext context,
  required String title,
  required String reason,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: context.colorScheme.background,
      title: Text(title),
      content: Text(reason),
      actions: [
        TextButton(
          onPressed: () {
            context.navigator.pop();
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            context.navigator.pop();
            unawaited(openAppSettings());
          },
          child: const Text('Open Settings'),
        )
      ],
    ),
  );
}
