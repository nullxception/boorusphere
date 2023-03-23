import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/presentation/provider/settings/server_setting_state.dart';
import 'package:boorusphere/presentation/routes/app_router.gr.dart';
import 'package:boorusphere/presentation/screens/home/search_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@RoutePage()
class InitialDirectorPage extends HookConsumerWidget {
  const InitialDirectorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      final serverSetting = ref.read(serverSettingStateProvider);
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        context.router.replace(HomeRoute(
            session: SearchSession(serverId: serverSetting.lastActiveId)));
      });
    }, []);

    return const Material();
  }
}
