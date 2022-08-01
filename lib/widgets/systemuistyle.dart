import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../source/device_info.dart';
import '../utils/extensions/buildcontext.dart';

class SystemUIStyle extends ConsumerWidget {
  const SystemUIStyle({super.key, required this.child, this.nightMode});
  final Widget child;
  final bool? nightMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceInfo = ref.watch(deviceInfoProvider);
    final isNightMode = nightMode ?? context.brightness == Brightness.dark;
    final foregroundBrightness =
        isNightMode ? Brightness.light : Brightness.dark;

    final defStyle =
        (isNightMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(statusBarColor: Colors.transparent);

    final style = defStyle.copyWith(
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: foregroundBrightness,
      systemNavigationBarIconBrightness: foregroundBrightness,
      systemNavigationBarContrastEnforced: false,
    );

    return AnnotatedRegion(
      // opt-out SDK 28 and below from transparent navigationBar
      // due to lack of SystemUiMode.edgeToEdge
      value: deviceInfo.sdkInt > 28 ? style : defStyle,
      child: child,
    );
  }
}
