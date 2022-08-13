import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueExt<T> on AsyncValue<T> {
  T? get maybeValue {
    return mapOrNull(data: (d) => d.value);
  }

  bool get isLoading {
    return maybeWhen(loading: () => true, orElse: () => false);
  }

  bool get isError {
    return maybeWhen(error: (e, s) => true, orElse: () => false);
  }
}
