import 'dart:async';

import 'package:boorusphere/presentation/i18n/strings.g.dart';
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
      icon: const Icon(Icons.security),
      content: Text(reason),
      actions: [
        TextButton(
          onPressed: () {
            context.navigator.pop();
          },
          child: Text(context.t.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            context.navigator.pop();
            unawaited(openAppSettings());
          },
          child: Text(context.t.openSettings),
        )
      ],
    ),
  );
}
