import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:package_info/package_info.dart';

class VersionLocalSource {
  Future<AppVersion> get() async {
    final pkgInfo = await PackageInfo.fromPlatform();
    return AppVersion.fromString(pkgInfo.version);
  }
}
