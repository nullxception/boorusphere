//
// Script for renaming apks for release purposes
//

import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

final variants = {
  'arm64-v8a',
  'armeabi-v7a',
  'x86_64',
};

String get _outputDir {
  return path.normalize(
      path.join(Directory.current.path, 'build/app/outputs/flutter-apk'));
}

YamlMap get _pubspec {
  final yamlPath =
      path.normalize(path.join(Directory.current.path, 'pubspec.yaml'));
  final content = File(yamlPath).readAsStringSync();
  return loadYaml(content);
}

String get _appVersion {
  return _pubspec['version'];
}

String get _appVersionName {
  return _appVersion.split('+').first;
}

Future<void> _renameOutputApks(
  String outDir, {
  required String from,
  required String to,
}) async {
  final fromPath = path.normalize(path.join(outDir, from));
  final toPath = path.normalize(path.join(outDir, to));
  final apk = File(fromPath);
  if (apk.existsSync()) {
    log(':: Renaming $from to $to');
    await apk.rename(toPath);
  }
}

void main() async {
  if (!Directory(_outputDir).existsSync()) {
    throw FileSystemException('Directory is not exists', _outputDir);
  }

  await Future.wait([
    ...variants.map((arch) => _renameOutputApks(_outputDir,
        from: 'app-$arch-release.apk',
        to: 'boorusphere-$_appVersionName-$arch.apk'))
  ]);
}
