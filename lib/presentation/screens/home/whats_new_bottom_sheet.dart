import 'package:boorusphere/domain/provider.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/changelog_state.dart';
import 'package:boorusphere/presentation/screens/about/changelog_page.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/widgets/notice_card.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WhatsNewBottomSheet extends HookConsumerWidget {
  const WhatsNewBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envRepo = ref.read(envRepoProvider);

    final changelog = ref.watch(
        changelogStateProvider(ChangelogType.assets, envRepo.appVersion));

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      context.t.changelog.whatsNew(version: envRepo.appVersion),
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.3,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              changelog.when(
                data: (data) => ChangelogDataView(
                  changelog: data.first,
                  showVersion: false,
                ),
                error: (e, s) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: NoticeCard(
                        icon: const Icon(Icons.cancel_rounded),
                        children: Text(context.t.changelog.none),
                      ),
                    ),
                  ],
                ),
                loading: () => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(child: RefreshProgressIndicator()),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  context.navigator.pop();
                },
                icon: const Icon(Icons.done),
                label: Text(context.t.actionContinue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const WhatsNewBottomSheet(),
    );
  }
}
