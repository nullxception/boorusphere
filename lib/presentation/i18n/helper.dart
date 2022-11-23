import 'package:boorusphere/presentation/i18n/strings.g.dart';

String _defCardinalResolver(n, {zero, one, two, few, many, other}) {
  if (n == 0) {
    return zero ?? other!;
  }
  if (n == 1) {
    return one ?? other!;
  }
  return other!;
}

String _defOrdinalResolver(n, {zero, one, two, few, many, other}) {
  if (n % 10 == 1 && n % 100 != 11) {
    return one ?? other!;
  }
  if (n % 10 == 2 && n % 100 != 12) {
    return two ?? other!;
  }
  if (n % 10 == 3 && n % 100 != 13) {
    return few ?? other!;
  }
  return other!;
}

class LocaleHelper {
  static void useFallbackPluralResolver(Iterable<String> languages) {
    for (var language in languages) {
      LocaleSettings.setPluralResolver(
        language: language,
        cardinalResolver: _defCardinalResolver,
        ordinalResolver: _defOrdinalResolver,
      );
    }
  }

  static Future update(AppLocale? locale) {
    return Future(() {
      if (locale != null) {
        LocaleSettings.setLocale(locale);
      } else {
        LocaleSettings.useDeviceLocale();
      }
    });
  }
}
