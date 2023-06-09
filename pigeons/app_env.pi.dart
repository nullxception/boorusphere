import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/pigeon/app_env.pi.dart',
    kotlinOut:
        'android/app/src/main/kotlin/io/chaldeaprjkt/boorusphere/pigeon/AppEnv.pi.kt',
    kotlinOptions: KotlinOptions(errorClassName: 'AppEnvException'),
  ),
)
@HostApi()
abstract class AppEnv {
  Env get();
}

class Env {
  Env({
    required this.versionName,
    required this.versionCode,
    required this.sdkVersion,
  });

  final String versionName;
  final int versionCode;
  final int sdkVersion;
}
