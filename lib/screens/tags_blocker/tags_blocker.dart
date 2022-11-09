import 'package:boorusphere/source/blocked_tags.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:boorusphere/widgets/notice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TagsBlockerPage extends HookConsumerWidget {
  const TagsBlockerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tags blocker')),
      body: const SafeArea(
        child: _TagsBlockerContent(),
      ),
    );
  }
}

class _TagsBlockerContent extends HookConsumerWidget {
  const _TagsBlockerContent();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedTags = ref.watch(blockedTagsProvider);
    final controller = useTextEditingController();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 16),
          child: Column(
            children: [
              const Text(
                  'You can block multiple tags by separating it with space'),
              TextField(
                controller: controller,
                onSubmitted: (value) {
                  final values = value.toWordList();
                  ref.read(blockedTagsProvider.notifier).pushAll(values);
                  controller.clear();
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Example: red_shirt blue_shoes',
                ),
              ),
            ],
          ),
        ),
        if (blockedTags.isEmpty)
          const Center(
            child: NoticeCard(
              icon: Icon(Icons.tag),
              margin: EdgeInsets.all(32),
              children: Text('No blocked tags yet'),
            ),
          ),
        for (final tag in blockedTags.entries)
          ListTile(
            title: Text(tag.value),
            leading: const Icon(Icons.block),
            trailing: IconButton(
              onPressed: () {
                ref.read(blockedTagsProvider.notifier).delete(tag.key);
              },
              icon: const Icon(Icons.close),
            ),
          ),
      ],
    );
  }
}
