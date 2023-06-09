import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/pigeon/storage_util.pi.dart',
    kotlinOut:
        'android/app/src/main/kotlin/io/chaldeaprjkt/boorusphere/pigeon/StorageUtil.pi.kt',
    kotlinOptions: KotlinOptions(errorClassName: 'StorageUtilException'),
  ),
)
@HostApi()
abstract class StorageUtil {
  String getStoragePath();
  String getDownloadPath();
}
