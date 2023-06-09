// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:grinder/grinder.dart';

import 'rename_release_apk.dart';

main(args) => grind(args);

final utf8Opt = RunOptions(stdoutEncoding: utf8, stderrEncoding: utf8);

fun(List<String> args) {
  runAsync('flutter', arguments: args, runOptions: utf8Opt);
}

@DefaultTask()
listTasks() {
  final buf = StringBuffer();
  for (var task in context.grinder.tasks) {
    if (context.grinder.defaultTask == task) {
      continue;
    }

    final deps = context.grinder.getImmediateDependencies(task);
    final label = task.name;
    final diff = label.length - task.name.length;
    buf.write('  ${label.padRight(20 + diff)} ');
    final depTasks = deps.map((d) => d.name).join(', ');
    final depText = '@Depends($depTasks)';

    if (task.description?.isNotEmpty ?? false) {
      buf.writeln(task.description);
      if (deps.isNotEmpty) {
        buf.writeln('  ${''.padRight(20)} $depText');
      }
      continue;
    }

    if (deps.isNotEmpty) {
      buf.writeln(depText);
    }
  }

  print(buf);
}

@Task('Clean')
Future<void> clean() async {
  await fun(['clean']);
}

@Task('Sync dependencies')
Future<void> sync() async {
  await fun(['pub', 'get']);
}

@Task('Generate code')
Future<void> gencode() async {
  await Pub.runAsync(
    'build_runner',
    arguments: [
      'build',
      '--delete-conflicting-outputs',
    ],
    runOptions: utf8Opt,
  );
}

@Task('Generate localization')
Future<void> genlang() async {
  await Pub.runAsync('slang', runOptions: utf8Opt);
}

@Task('Generate pigeon bindings')
Future<void> pigeons() async {
  final files = Directory('pigeons')
      .listSync(recursive: true)
      .where((x) => x is File && x.path.endsWith('.pi.dart'))
      .map((x) => x.path);

  await Pub.runAsync('pigeon',
      arguments: [
        '--input',
        ...files,
      ],
      runOptions: utf8Opt);
}

@Task('Build APKs')
@Depends(clean, sync, gencode, genlang)
Future<void> buildapk() async {
  await fun(['build', 'apk', '--split-per-abi']);
}

@Task('Rename APKs')
Future<void> renameapk() {
  return renameReleaseApk();
}

@Task('Release')
@Depends(buildapk, renameapk)
void release() {}

@Task('Check formatting')
Future<void> checkfmt() async {
  final files = Directory('lib')
      .listSync(recursive: true)
      .where((x) =>
          x is File &&
          x.path.endsWith('.dart') &&
          !x.path.contains(RegExp(r'\.(freezed|g|gr|pi)\.dart$')))
      .map((x) => x.path);

  await runAsync(
    'dart',
    arguments: [
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...files,
    ],
    runOptions: utf8Opt,
  );
}

@Task('Analyze code')
@Depends(checkfmt)
Future<void> analyze() async {
  await fun(['analyze']);
}

@Task('Unit test')
Future<void> unittest() async {
  await Pub.runAsync('full_coverage', runOptions: utf8Opt);
  await fun(['test', '--coverage']);
}

@Task('Test all things')
@Depends(analyze, unittest)
void test() {}
