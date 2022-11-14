/// Generated file. Do not edit.
///
/// Locales: 1
/// Strings: 117

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, _StringsEn> {
  en(languageCode: 'en', build: _StringsEn.build);

  const AppLocale(
      {required this.languageCode,
      this.scriptCode,
      this.countryCode,
      required this.build}); // ignore: unused_element

  @override
  final String languageCode;
  @override
  final String? scriptCode;
  @override
  final String? countryCode;
  @override
  final TranslationBuilder<AppLocale, _StringsEn> build;

  /// Gets current instance managed by [LocaleSettings].
  _StringsEn get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
_StringsEn get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
class Translations {
  Translations._(); // no constructor

  static _StringsEn of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, _StringsEn>(context).translations;
}

/// The provider for method B
class TranslationProvider
    extends BaseTranslationProvider<AppLocale, _StringsEn> {
  TranslationProvider({required super.child})
      : super(
          initLocale: LocaleSettings.instance.currentLocale,
          initTranslations: LocaleSettings.instance.currentTranslations,
        );

  static InheritedLocaleData<AppLocale, _StringsEn> of(BuildContext context) =>
      InheritedLocaleData.of<AppLocale, _StringsEn>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
  _StringsEn get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, _StringsEn> {
  LocaleSettings._()
      : super(
            locales: AppLocale.values,
            baseLocale: _baseLocale,
            utils: AppLocaleUtils.instance);

  static final instance = LocaleSettings._();

  // static aliases (checkout base methods for documentation)
  static AppLocale get currentLocale => instance.currentLocale;
  static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
  static AppLocale setLocale(AppLocale locale) => instance.setLocale(locale);
  static AppLocale setLocaleRaw(String rawLocale) =>
      instance.setLocaleRaw(rawLocale);
  static AppLocale useDeviceLocale() => instance.useDeviceLocale();
  static List<Locale> get supportedLocales => instance.supportedLocales;
  static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
  static void setPluralResolver(
          {String? language,
          AppLocale? locale,
          PluralResolver? cardinalResolver,
          PluralResolver? ordinalResolver}) =>
      instance.setPluralResolver(
        language: language,
        locale: locale,
        cardinalResolver: cardinalResolver,
        ordinalResolver: ordinalResolver,
      );
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, _StringsEn> {
  AppLocaleUtils._()
      : super(baseLocale: _baseLocale, locales: AppLocale.values);

  static final instance = AppLocaleUtils._();

  // static aliases (checkout base methods for documentation)
  static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
  static AppLocale parseLocaleParts(
          {required String languageCode,
          String? scriptCode,
          String? countryCode}) =>
      instance.parseLocaleParts(
          languageCode: languageCode,
          scriptCode: scriptCode,
          countryCode: countryCode);
  static AppLocale findDeviceLocale() => instance.findDeviceLocale();
}

// translations

// Path: <root>
class _StringsEn implements BaseTranslations<AppLocale, _StringsEn> {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppLocale.build] is preferred.
  _StringsEn.build(
      {Map<String, Node>? overrides,
      PluralResolver? cardinalResolver,
      PluralResolver? ordinalResolver})
      : assert(overrides == null,
            'Set "translation_overrides: true" in order to enable this feature.'),
        $meta = TranslationMetadata(
          locale: AppLocale.en,
          overrides: overrides ?? {},
          cardinalResolver: cardinalResolver,
          ordinalResolver: ordinalResolver,
        );

  /// Metadata for the translations of <en>.
  @override
  final TranslationMetadata<AppLocale, _StringsEn> $meta;

  late final _StringsEn _root = this; // ignore: unused_field

  // Translations
  String get save => 'Save';
  String get cancel => 'Cancel';
  String get clear => 'Clear';
  String get retry => 'Retry';
  String get remove => 'Remove';
  String get edit => 'Edit';
  String get add => 'Add';
  String get reset => 'Reset';
  String get reset2 => 'Reset to default';
  String get scan => 'Scan';
  String get loadMore => 'Load more';
  String get clearing => 'Clearing...';
  String get disableSafeMode => 'Disable safe mode';
  String get details => 'Details';
  String get rating => 'Rating';
  String get location => 'Location';
  String get source => 'Source';
  String get fileSample => 'Sample file';
  String get fileOG => 'Original file';
  String get tags => 'Tags';
  String get meta => 'Meta';
  String get artist => 'Artist';
  String get character => 'Character';
  String get copyright => 'Copyright';
  String get general => 'General';
  String get ossLicense => 'Open source license';
  String get github => 'GitHub';
  String get openSettings => 'Open Settings';
  String get copySuccess => 'Copied to clipboard';
  String get loadImageFailed => 'Failed to load image';
  String get onMediaBlurred =>
      'This media may contain material that is not safe for public viewing';
  String get unblur => 'Show me';
  String unsupportedMedia({required Object fileExt}) =>
      '${fileExt} is not supported';
  String get openExternally => 'Open externally';
  String get retryPopBack => 'Press back again to exit';
  String get goHome => 'Back to home';
  String get recently => 'Recently';
  late final _StringsSuggestionEn suggestion = _StringsSuggestionEn._(_root);
  late final _StringsActionTagEn actionTag = _StringsActionTagEn._(_root);
  late final _StringsUpdaterEn updater = _StringsUpdaterEn._(_root);
  late final _StringsChangelogEn changelog = _StringsChangelogEn._(_root);
  late final _StringsLicenseEn license = _StringsLicenseEn._(_root);
  late final _StringsDownloaderEn downloader = _StringsDownloaderEn._(_root);
  late final _StringsFavoritesEn favorites = _StringsFavoritesEn._(_root);
  late final _StringsTagsBlockerEn tagsBlocker = _StringsTagsBlockerEn._(_root);
  late final _StringsServersEn servers = _StringsServersEn._(_root);
  late final _StringsSettingsEn settings = _StringsSettingsEn._(_root);
}

// Path: suggestion
class _StringsSuggestionEn {
  _StringsSuggestionEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String notSupported({required Object serverName}) =>
      '${serverName} did not support search suggestion';
  String suggested({required Object serverName}) =>
      'Suggested at ${serverName}';
  String desc({required Object serverName}) => 'at ${serverName}';
}

// Path: actionTag
class _StringsActionTagEn {
  _StringsActionTagEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get copy => 'Copy tag';
  String get block => 'Block selected tag';
  String get blocked => 'Added to tags blocker';
  String get append => 'Add tag to current search';
  String get search => 'Search tag';
}

// Path: updater
class _StringsUpdaterEn {
  _StringsUpdaterEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get check => 'Check for update';
  String get checking => 'Checking for update...';
  String download({required Object version}) => 'Download ${version}';
  String available({required Object version}) => 'Update available: ${version}';
  String get preparing => 'Preparing for update...';
  String get onLatest => 'You\'re on latest version';
  String get onNewVersion => 'New version is available';
  String get install => 'Install update';
  String progress({required Object progress}) => 'Downloading: ${progress}%';
}

// Path: changelog
class _StringsChangelogEn {
  _StringsChangelogEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Changelog';
  String get view => 'View changes';
  String get none => 'No changelog available';
}

// Path: license
class _StringsLicenseEn {
  _StringsLicenseEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String package({required Object name}) => 'package: ${name}';
  String title({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: 'License',
        other: 'Licenses',
      );
  String counted({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: '${n} license',
        other: '${n} licenses',
      );
}

// Path: downloader
class _StringsDownloaderEn {
  _StringsDownloaderEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Downloads';
  String get noFile => 'File moved or missing';
  String get redownload => 'Redownload';
  String get detail => 'Show detail';
  String get placeholder => 'Your downloaded files will appear here';
  String get ungroup => 'Ungroup';
  String get groupByServer => 'Group by server';
  String get noPermission =>
      'Cannot download a file; missing notification permission';
}

// Path: favorites
class _StringsFavoritesEn {
  _StringsFavoritesEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get placeholder => 'Your saved content will appear here';
  String get title => 'Favorites';
}

// Path: tagsBlocker
class _StringsTagsBlockerEn {
  _StringsTagsBlockerEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Tags Blocker';
  String get desc => 'You can block multiple tags by separating it with space';
  String get empty => 'No blocked tags yet';
  String get hint => 'Example: red_shirt blue_shoes';
}

// Path: servers
class _StringsServersEn {
  _StringsServersEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Server';
  String get resetWarning =>
      'Are you sure you want to reset server list to default ?\n\nThis will erase all of your added server';
  String get removeLastError => 'The last server cannot be removed';
  String get preset => 'From Preset';
  String get select => 'Select Server';
  String get add => 'Add new server';
  String edit({required Object name}) => 'Edit ${name}';
  String get alias => 'Alias';
  String get homepage => 'Homepage';
  String get homepageHint => 'Homepage, example: https://verycoolbooru.com';
  String get useCustomApi => 'Use custom API address';
  String get useCustomApiDesc =>
      'Useful if server has different API address than the homepage';
  String get addrError => 'not a valid address';
  String get apiAddr => 'API Address';
  String get apiAddrHint =>
      'API address, example: https://api-v69.verycoolbooru.com';
  String alreadyExists({required Object name}) =>
      'Server data for ${name} already exists';
  late final _StringsServersPayloadsEn payloads =
      _StringsServersPayloadsEn._(_root);
}

// Path: settings
class _StringsSettingsEn {
  _StringsSettingsEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Settings';
  String get interface => 'Interface';
  String get safeMode => 'Safe mode';
  String get misc => 'Miscellaneous';
  late final _StringsSettingsMidnightThemeEn midnightTheme =
      _StringsSettingsMidnightThemeEn._(_root);
  late final _StringsSettingsUiBlurEn uiBlur =
      _StringsSettingsUiBlurEn._(_root);
  late final _StringsSettingsHideMediaEn hideMedia =
      _StringsSettingsHideMediaEn._(_root);
  late final _StringsSettingsBlurContentEn blurContent =
      _StringsSettingsBlurContentEn._(_root);
  late final _StringsSettingsStrictSafeModeEn strictSafeMode =
      _StringsSettingsStrictSafeModeEn._(_root);
  late final _StringsSettingsLoadOGEn loadOG =
      _StringsSettingsLoadOGEn._(_root);
  late final _StringsSettingsPostLimitEn postLimit =
      _StringsSettingsPostLimitEn._(_root);
  late final _StringsSettingsClearCacheEn clearCache =
      _StringsSettingsClearCacheEn._(_root);
}

// Path: servers.payloads
class _StringsServersPayloadsEn {
  _StringsServersPayloadsEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Payload';
  String get search => 'Search Payload';
  String get suggestion => 'Tag Suggestion Payload';
  String get post => 'Web Post Payload';
}

// Path: settings.midnightTheme
class _StringsSettingsMidnightThemeEn {
  _StringsSettingsMidnightThemeEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Midnight Theme';
  String get desc => 'Use darker color for the dark-mode';
}

// Path: settings.uiBlur
class _StringsSettingsUiBlurEn {
  _StringsSettingsUiBlurEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Enable blur';
  String get desc => 'Enable blur background on various UI elements';
}

// Path: settings.hideMedia
class _StringsSettingsHideMediaEn {
  _StringsSettingsHideMediaEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Hide downloaded media';
  String get desc =>
      'Prevent external gallery app from showing downloaded files';
}

// Path: settings.blurContent
class _StringsSettingsBlurContentEn {
  _StringsSettingsBlurContentEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Blur explicit content';
  String get desc => 'Content rated as explicit will be blurred';
}

// Path: settings.strictSafeMode
class _StringsSettingsStrictSafeModeEn {
  _StringsSettingsStrictSafeModeEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Rated safe only';
  String get desc =>
      'Only fetch content that rated as safe. Note that rated as safe doesn\'t guarantee safe for work';
}

// Path: settings.loadOG
class _StringsSettingsLoadOGEn {
  _StringsSettingsLoadOGEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Display original content';
  String get desc =>
      'Load original file instead of the sample when opening the post';
}

// Path: settings.postLimit
class _StringsSettingsPostLimitEn {
  _StringsSettingsPostLimitEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Max content per-load';
  String get desc =>
      'Result might less than expected (caused by blocked tags or invalid data)';
}

// Path: settings.clearCache
class _StringsSettingsClearCacheEn {
  _StringsSettingsClearCacheEn._(this._root);

  final _StringsEn _root; // ignore: unused_field

  // Translations
  String get title => 'Clear cache';
  String get desc => 'Clear loaded content from cache';
  String get done => 'Cache cleared';
}
