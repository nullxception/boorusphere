import 'dart:io';

import 'package:grinder/grinder.dart';

import 'grind_util.dart' as grutil;
import 'me.dart' as me;

main(args) => grind(args);

@DefaultTask()
listTasks() => grutil.tasks();

@Task('Generate code')
Future<void> gencode() async {
  await me.pun('build_runner', args: ['build', '--delete-conflicting-outputs']);
}

@Task('Generate localization')
Future<void> genlang() async {
  await me.pun('slang');
}

@Task('Generate pigeon bindings')
Future<void> pigeons() async {
  final files = Directory('pigeons')
      .listSync(recursive: true)
      .where((x) => x is File && x.path.endsWith('.pi.dart'))
      .fold(<String>[], (prev, x) => [...prev, '--input', x.path]);

  await me.pun('pigeon', args: files);
}

@Task('Create release note')
Future<void> mkreleasenote() async {
  await me.pun('boorusphere', bin: 'mkreleasenote');
}

@Task('Check formatting')
Future<void> chkfmt() async {
  final files = Directory('lib')
      .listSync(recursive: true)
      .where((x) =>
          x is File &&
          x.path.endsWith('.dart') &&
          !x.path.contains(RegExp(r'\.(freezed|g|gr|pi)\.dart$')))
      .map((x) => x.path);

  await me.fmt(['--output=none', '--set-exit-if-changed', ...files]);
}

@Task('Analyze code')
Future<void> analyze() async {
  await me.fun(['analyze']);
}

@Task('Unit test')
Future<void> unittest() async {
  await me.pun('full_coverage');
  await me.fun(['test', '--coverage']);
}

@Task('Build release apks')
Future<void> apkrelease() async {
  await me.fun(['build', 'apk', '--split-per-abi']);
  await me.pun('boorusphere', bin: 'renameapks');
}

@Task('Test all things')
@Depends(chkfmt, analyze, unittest)
void testall() {}

@Task('Perform release pipeline')
@Depends(gencode, genlang, testall, apkrelease, mkreleasenote)
void release() {}
