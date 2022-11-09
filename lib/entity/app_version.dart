import 'package:boorusphere/source/version.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_version.freezed.dart';

@freezed
class AppVersion with _$AppVersion {
  const factory AppVersion({
    @Default(0) int major,
    @Default(0) int minor,
    @Default(0) int patch,
  }) = _AppVersion;
  const AppVersion._();

  factory AppVersion.fromString(String string) {
    final n =
        string.split('+').first.split('.').map((e) => int.tryParse(e) ?? 0);
    return AppVersion(
      major: n.first,
      minor: n.elementAt(1),
      patch: n.last,
    );
  }

  @override
  String toString() => '$major.$minor.$patch';

  bool isNewerThan(AppVersion version) {
    if (major > version.major) return true;
    if (major >= version.major && minor > version.minor) return true;

    return major >= version.major &&
        minor >= version.minor &&
        patch > version.patch;
  }

  String get apkUrl {
    return '${VersionDataSource.gitUrl}/releases/download/$this/boorusphere-$this-${VersionDataSource.arch}.apk';
  }

  static const zero = AppVersion();
}
