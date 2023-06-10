import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:collection/collection.dart';

String _defCardinalResolver(
  num n, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) {
  if (n == 0) {
    return zero ?? other ?? '$n';
  }
  if (n == 1) {
    return one ?? other ?? '$n';
  }
  return other ?? '$n';
}

String _defOrdinalResolver(
  num n, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) {
  if (n % 10 == 1 && n % 100 != 11) {
    return one ?? other ?? '$n';
  }
  if (n % 10 == 2 && n % 100 != 12) {
    return two ?? other ?? '$n';
  }
  if (n % 10 == 3 && n % 100 != 13) {
    return few ?? other ?? '$n';
  }
  return other ?? '$n';
}

class LocaleHelper {
  static void setupPluralResolver({
    Iterable<AppLocale> ignores = const <AppLocale>[AppLocale.en],
  }) {
    final locales = AppLocale.values.whereNot((x) => ignores.contains(x));
    for (final locale in locales) {
      LocaleSettings.setPluralResolver(
        locale: locale,
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
