import 'package:boorusphere/data/repository/version/entity/app_version.dart';
import 'package:boorusphere/domain/repository/app_state_repo.dart';
import 'package:hive/hive.dart';

class CurrentAppStateRepo implements AppStateRepo {
  CurrentAppStateRepo(this.box);
  final Box box;

  @override
  AppVersion get version {
    final vstr = box.get(_versionKey);
    if (vstr == null) {
      return AppVersion.zero;
    }

    return AppVersion.fromString(vstr);
  }

  @override
  Future<void> storeVersion(AppVersion version) async {
    await box.put(_versionKey, version.toString());
  }

  static const _boxName = 'app_state';
  static const _versionKey = 'installed_version';

  static Box hiveBox() {
    return Hive.box(_boxName);
  }

  static Future<void> prepare() async {
    await Hive.openBox(_boxName);
  }
}
