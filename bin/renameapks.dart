//
// Script for renaming apks for release purposes
// usage:
// $ flutter pub run renameapks
//
// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

final variants = {
  'arm64-v8a',
  'armeabi-v7a',
  'x86_64',
};

String get outputDir {
  return path.normalize(
      path.join(Directory.current.path, 'build/app/outputs/flutter-apk'));
}

YamlMap get pubspec {
  final yamlPath =
      path.normalize(path.join(Directory.current.path, 'pubspec.yaml'));
  final content = File(yamlPath).readAsStringSync();
  return loadYaml(content);
}

String get appVersion {
  return pubspec['version'];
}

String get appVersionCode {
  return appVersion.split('+').last;
}

String get appVersionName {
  return appVersion.split('+').first;
}

Future<void> renameOutputApks(
  String outDir, {
  required String from,
  required String to,
}) async {
  final fromPath = path.normalize(path.join(outDir, from));
  final toPath = path.normalize(path.join(outDir, to));
  final apk = File(fromPath);
  if (await apk.exists()) {
    print(':: Renaming $from to $to');
    await apk.rename(toPath);
  }
}

void main(List<String> args) async {
  if (!await Directory(outputDir).exists()) {
    throw FileSystemException('Directory is not exists', outputDir);
  }

  await Future.wait([
    ...variants.map((arch) => renameOutputApks(outputDir,
        from: 'app-$arch-release.apk',
        to: 'boorusphere-$appVersionName-$arch.apk'))
  ]);
}
