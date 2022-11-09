import 'package:boorusphere/data/source/device_info.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StyledOverlayRegion extends ConsumerWidget {
  const StyledOverlayRegion({
    super.key,
    required this.child,
    this.nightMode,
    this.theme,
  });
  final Widget child;
  final bool? nightMode;
  final ThemeData? theme;

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
      child: theme != null ? Theme(data: theme!, child: child) : child,
    );
  }
}
