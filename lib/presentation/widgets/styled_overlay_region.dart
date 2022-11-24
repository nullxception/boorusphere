import 'package:boorusphere/presentation/provider/device_prop.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final deviceProp = ref.watch(devicePropProvider);
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
      value: deviceProp.sdkVersion > 28 ? style : defStyle,
      child: theme != null ? Theme(data: theme!, child: child) : child,
    );
  }
}
