import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ExceptionInfo extends HookWidget {
  const ExceptionInfo({
    super.key,
    required this.exception,
    this.stackTrace,
    this.alignment = Alignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  final Object exception;
  final StackTrace? stackTrace;
  final Alignment alignment;
  final CrossAxisAlignment crossAxisAlignment;

  String get description {
    final e = exception;
    if (e is HandshakeException) {
      return 'Cannot establish a secure connection';
    } else if (e is SocketException) {
      return e.address != null
          ? 'Failed to connect to ${e.address?.host}'
          : 'Connection failed';
    } else if (e is TimeoutException) {
      return 'Connection timeout';
    }
    try {
      // let's try to obtain exception message
      return (e as dynamic).message;
    } catch (_) {
      return e
          .toString()
          .split(':')
          .skipWhile((it) => it.contains(RegExp(r'eption$')))
          .join(':')
          .trim();
    }
  }

  bool get allowToggled => stackTrace == null || exception is TimeoutException;

  @override
  Widget build(BuildContext context) {
    final showTrace = useState(false);
    toggleStacktrace() {
      showTrace.value = !showTrace.value;
    }

    return InkWell(
      onTap: allowToggled ? null : toggleStacktrace,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(description),
          ),
          if (showTrace.value && stackTrace != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Text('Stacktrace:'),
                ),
                Text(stackTrace.toString()),
              ],
            )
        ],
      ),
    );
  }
}
