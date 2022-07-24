import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/blocked_tags.dart';
import '../components/notice_card.dart';

class TagsBlockerPage extends HookConsumerWidget {
  const TagsBlockerPage({super.key});

  void updateTags(BlockedTagsManager repo, ValueNotifier storage) {
    storage.value = repo.mapped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final blockedTagsHandler = ref.watch(blockedTagsProvider);
    final blockedTags = useState({});
    final blockedTagsController = useTextEditingController();

    useEffect(() {
      // Populate suggestion history on first build
      updateTags(blockedTagsHandler, blockedTags);
    }, [blockedTags]);

    return Scaffold(
      appBar: AppBar(title: const Text('Tags Blocker')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: const Text(
                  'You can block multiple tags by separating it with space'),
            ),
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextFormField(
                  controller: blockedTagsController,
                  onFieldSubmitted: (value) {
                    final values = value.trim().split(' ');
                    blockedTagsHandler.pushAll(values);
                    updateTags(blockedTagsHandler, blockedTags);
                    blockedTagsController.clear();
                  },
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Example: open_mouth explosion',
                  ),
                ),
              ),
            ),
            const ListTile(
              title: Text('Blocked tags'),
            ),
            blockedTags.value.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: blockedTags.value.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final key = blockedTags.value.keys.elementAt(index);
                      final tag = blockedTags.value.values.elementAt(index);
                      return ListTile(
                        title: Text(tag),
                        leading: const Icon(Icons.tag),
                        trailing: IconButton(
                            onPressed: () {
                              blockedTagsHandler.delete(key);
                              updateTags(blockedTagsHandler, blockedTags);
                            },
                            icon: const Icon(Icons.close)),
                      );
                    },
                  )
                : const Center(
                    child: NoticeCard(
                      icon: Icon(Icons.tag),
                      margin: EdgeInsets.only(top: 64),
                      children: Text('No blocked tags yet'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
