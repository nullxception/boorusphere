import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../entity/sphere_exception.dart';

class ExceptionInfo extends HookWidget {
  const ExceptionInfo({
    super.key,
    this.err,
    this.stackTrace,
    this.textAlign = TextAlign.center,
    this.style,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  final Object? err;
  final StackTrace? stackTrace;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final TextStyle? style;
  final EdgeInsets padding;

  String get description {
    final e = err is DioError ? (err as DioError).error : err;
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

  bool get traceable =>
      stackTrace != null && err is! TimeoutException && err is! SphereException;

  @override
  Widget build(BuildContext context) {
    final showTrace = useState(false);
    toggleStacktrace() {
      showTrace.value = !showTrace.value;
    }

    return Padding(
      padding: padding,
      child: InkWell(
        onTap: traceable ? toggleStacktrace : null,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            DefaultTextStyle(
              style: style ?? DefaultTextStyle.of(context).style,
              child: Text(description, textAlign: textAlign),
            ),
            if (showTrace.value && stackTrace != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Text('Stacktrace:'),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 128),
                    child: SingleChildScrollView(
                      child: Text(stackTrace.toString()),
                    ),
                  )
                ],
              )
          ],
        ),
      ),
    );
  }
}
