import 'package:boorusphere/data/repository/version/entity/app_version.dart';

abstract interface class AppStateRepo {
  AppVersion get version;
  Future<void> storeVersion(AppVersion version);
}
