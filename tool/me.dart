import 'dart:convert';

import 'package:grinder/grinder.dart';

//
// My pun collections
//

Future<String> fun(List<String> args) =>
    runAsync('flutter', arguments: args, runOptions: utf8Opt);

Future<String> pun(
  String package, {
  List<String> args = const [],
  String? bin,
}) =>
    Pub.runAsync(package, arguments: args, script: bin, runOptions: utf8Opt);

Future<String> ex(
  String executable, {
  List<String> args = const [],
}) =>
    runAsync(executable, arguments: args, runOptions: utf8Opt);

Future<String> fmt(List<String> args) => ex('dart', args: ['format', ...args]);

final utf8Opt = RunOptions(stdoutEncoding: utf8, stderrEncoding: utf8);
