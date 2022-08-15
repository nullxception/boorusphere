import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../widgets/notice_card.dart';
import '../../source/blocked_tags.dart';
import '../../utils/extensions/string.dart';

class TagsBlockerPage extends HookConsumerWidget {
  const TagsBlockerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tags blocker')),
      body: SafeArea(
        child: _TagsBlockerContent(),
      ),
    );
  }
}

class _TagsBlockerContent extends HookConsumerWidget {
  void updateTags(BlockedTagsSource repo, ValueNotifier storage) {
    storage.value = repo.mapped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedTagsHandler = ref.watch(blockedTagsProvider);
    final blockedTags = useState({});
    final controller = useTextEditingController();

    useEffect(() {
      // Populate suggestion history on first build
      updateTags(blockedTagsHandler, blockedTags);
    }, []);

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
                  blockedTagsHandler.pushAll(values);
                  updateTags(blockedTagsHandler, blockedTags);
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
        if (blockedTags.value.isEmpty)
          const Center(
            child: NoticeCard(
              icon: Icon(Icons.tag),
              margin: EdgeInsets.all(32),
              children: Text('No blocked tags yet'),
            ),
          ),
        for (final tag in blockedTags.value.entries)
          ListTile(
            title: Text(tag.value),
            leading: const Icon(Icons.block),
            trailing: IconButton(
              onPressed: () {
                blockedTagsHandler.delete(tag.key);
                updateTags(blockedTagsHandler, blockedTags);
              },
              icon: const Icon(Icons.close),
            ),
          ),
      ],
    );
  }
}
