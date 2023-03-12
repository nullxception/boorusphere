import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/app_updater.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdatePrepareDialog extends HookConsumerWidget {
  const UpdatePrepareDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.read(appUpdaterProvider);
    final allowPop = useState(false);
    useEffect(() {
      downloader.expose().then((value) {
        allowPop.value = true;
        context.navigator.pop();
      });

      return downloader.install;
    }, []);

    return WillPopScope(
      onWillPop: () async {
        if (allowPop.value) return true;
        return false;
      },
      child: AlertDialog(
        backgroundColor: context.colorScheme.background,
        content: Row(
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: RefreshProgressIndicator(),
            ),
            const SizedBox(width: 32),
            Text(context.t.updater.preparing)
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const UpdatePrepareDialog(),
    );
  }
}
