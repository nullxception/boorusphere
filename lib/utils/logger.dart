import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

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

void setupLogger() {
  Logger.root.level = kDebugMode ? _Level.v : _Level.i;
  Logger.root.onRecord.listen(
    (x) => debugPrint('${x.level.name} ${x.loggerName}: ${x.message}'),
  );
}
