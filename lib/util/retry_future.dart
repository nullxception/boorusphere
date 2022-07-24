import 'package:retry/retry.dart';

final retryFuture = const RetryOptions(maxAttempts: 4).retry;
