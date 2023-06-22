import 'dart:io';

import 'package:boorusphere/utils/logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

class DeviceWorkarounds {
  const DeviceWorkarounds._();

  static Future<Map<String, String>> get buildProps async {
    try {
      final getProp = await Process.run('getprop', []);
      return Map.fromEntries(
        getProp.stdout
            .toString()
            .split('\n')
            .where((x) => x.startsWith('[') && x.endsWith(']'))
            .map((e) => e.replaceAll(RegExp(r'(^\[|\]$)'), '').split(']: ['))
            .map((x) => MapEntry(x.first, x.last))
            .where((x) => x.value.isNotEmpty),
      );
    } catch (e, s) {
      mainLog.e('Failed to get device prop', e, s);
      return {};
    }
  }

  static isOppo(Map<String, String> props) {
    final brand = [
      'ro.product.brand',
      'ro.product.system.brand',
      'ro.product.system_ext.brand',
      'ro.product.vendor.brand',
    ].map((x) => props[x]?.toLowerCase()).whereNotNull();
    final oppo = ['oppo', 'oplus', 'oneplus', 'realme']; // same shit

    return oppo.any(brand.contains);
  }

  // ignore: avoid_void_async
  static void apply() async {
    final props = await buildProps;
    if (isOppo(props)) {
      mainLog.i('Forcing highest refresh rate on OPPO Devices');
      await FlutterDisplayMode.setHighRefreshRate();
    }
  }
}
