import 'dart:ffi';

String get kAppArch {
  switch (Abi.current()) {
    case Abi.androidX64:
      return 'x86_64';
    case Abi.androidArm64:
      return 'arm64-v8a';
    // we have no x86 apk, so most likely we're running in arm emulation mode
    case Abi.androidIA32:
    case Abi.androidArm:
      return 'armeabi-v7a';
    default:
      return Abi.current().toString();
  }
}
