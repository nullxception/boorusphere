import 'package:boorusphere/data/services/download.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UpdatePrepareDialog extends HookConsumerWidget {
  const UpdatePrepareDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.read(downloadProvider);
    final allowPop = useState(false);
    useEffect(() {
      downloader.updater(action: UpdaterAction.exposeAppFile).then((value) {
        allowPop.value = true;
        context.navigator.pop();
      });

      return () {
        downloader.updater(action: UpdaterAction.install);
      };
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
            SizedBox(
              width: 32,
              height: 32,
              child: SpinKitCubeGrid(
                size: 24,
                color: context.colorScheme.primary,
                duration: const Duration(milliseconds: 700),
              ),
            ),
            const SizedBox(width: 32),
            const Text('Preparing for update')
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
