import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

final mainLog = Logger('boorusphere');

extension LoggerExt on Logger {
  void e(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(_Level.e, message, error, stackTrace);

  void w(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(_Level.w, message, error, stackTrace);

  void i(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(_Level.i, message, error, stackTrace);

  void d(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(_Level.d, message, error, stackTrace);

  void v(Object? message, [Object? error, StackTrace? stackTrace]) =>
      log(_Level.v, message, error, stackTrace);
}

class _Level {
  static final e = Level('E', Level.SEVERE.value + 1);
  static final w = Level('W', Level.WARNING.value + 1);
  static final i = Level('I', Level.INFO.value + 1);
  static final d = Level('D', Level.FINE.value + 1);
  static final v = Level('V', Level.FINEST.value + 1);
}

const _clear = '\u001b[0m';

String _color(int n) => '\u001b[38;5;${n}m';

void setupLogger({bool test = false}) {
  final log = test ? debugPrint : debugPrintSynchronously;

  Logger.root.level = kDebugMode ? _Level.v : _Level.i;
  Logger.root.onRecord.listen((x) {
    final lv = x.level.value;
    final lc = switch (lv) {
      _ when lv >= Level.SEVERE.value => _color(1),
      _ when lv >= Level.WARNING.value => _color(3),
      _ when lv >= Level.INFO.value => _color(6),
      _ when lv >= Level.FINE.value => _color(4),
      _ => _color(8),
    };

    log('$lc${x.level.name} ${_color(2)}${x.loggerName}$_clear: ${x.message}');
  });
}
