import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../provider/blocked_tags.dart';
import '../../provider/common.dart';

class TagsBlocker extends HookWidget {
  void updateTags(BlockedTagsRepository repo, ValueNotifier storage) {
    repo.mapped.then((it) {
      storage.value = it;
    });
  }

  @override
  Widget build(BuildContext context) {
    final blockedTagsHandler = useProvider(blockedTagsProvider);
    final blockedTags = useState({});

    useEffect(() {
      // Populate suggestion history on first build
      updateTags(blockedTagsHandler, blockedTags);
    }, [blockedTags]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Tags'),
      ),
      body: Container(
        child: Column(
          children: [
            blockedTags.value.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: blockedTags.value.length,
                    itemBuilder: (context, index) {
                      final key = blockedTags.value.keys.elementAt(index);
                      final tag = blockedTags.value.values.elementAt(index);
                      return ListTile(
                        title: Text(tag),
                        leading: const Icon(Icons.tag),
                        trailing: IconButton(
                            onPressed: () {
                              blockedTagsHandler.delete(key).then((value) {
                                updateTags(blockedTagsHandler, blockedTags);
                              });
                            },
                            icon: const Icon(Icons.close)),
                      );
                    },
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No blocked tags yet'),
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            builder: (context) {
              return SingleChildScrollView(
                child: Container(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ListTile(
                        contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        title: Text(
                          'Blocking a tags',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                              'You can block multiple tags by separating it with space'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                        child: TextFormField(
                          autofocus: true,
                          onFieldSubmitted: (value) {
                            final values = value.trim().split(' ');
                            blockedTagsHandler.pushAll(values).then((value) {
                              updateTags(blockedTagsHandler, blockedTags);
                            });
                          },
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Example: open_mouth explosion',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
