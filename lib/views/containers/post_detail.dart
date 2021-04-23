import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/booru_post.dart';
import '../../provider/common.dart';

class PostDetails extends HookWidget {
  const PostDetails({Key? keys, required this.data}) : super(key: keys);
  final BooruPost data;

  @override
  Widget build(BuildContext context) {
    final uiTheme = useProvider(uiThemeProvider);
    final activeServer = useProvider(activeServerProvider);
    final selectedtag = useState(<String>[]);
    final fabController = useAnimationController(
        duration: const Duration(milliseconds: 300), initialValue: 0);

    final postUrl = activeServer.composePostUrl(data.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Size'),
            subtitle: Text('${data.width}x${data.height}'),
          ),
          ListTile(
            title: const Text('Type'),
            subtitle: Text(data.mimeType),
          ),
          ListTile(
            title: const Text('Location'),
            subtitle: TextButton(
              style: ButtonStyle(
                alignment: Alignment.centerLeft,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.zero,
                ),
              ),
              onPressed: () => launch(postUrl.toString()),
              child: Text(postUrl.toString()),
            ),
          ),
          ListTile(
            title: const Text('Source'),
            subtitle: TextButton(
              style: ButtonStyle(
                alignment: Alignment.centerLeft,
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.zero,
                ),
              ),
              onPressed: () => launch(data.src),
              child: Text(data.src),
            ),
          ),
          const ListTile(
            title: Text('Tags'),
          ),
          ListTile(
            title: Tags(
              alignment: WrapAlignment.start,
              itemCount: data.tags.length,
              itemBuilder: (index) {
                final tag = data.tags[index];
                return ItemTags(
                  color: uiTheme == ThemeMode.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  textColor: uiTheme == ThemeMode.dark
                      ? Colors.grey.shade200
                      : Colors.grey.shade800,
                  activeColor: Theme.of(context).accentColor,
                  border: Border.all(style: BorderStyle.none),
                  active: selectedtag.value.contains(tag),
                  title: tag,
                  index: index,
                  elevation: 0,
                  onPressed: (it) {
                    if (it.active ?? false) {
                      // display FAB on first select
                      if (selectedtag.value.isEmpty) {
                        fabController.forward();
                      }
                      selectedtag.value.add(tag);
                    } else if (it.active == false) {
                      selectedtag.value.remove(tag);
                      // display FAB on last removal
                      if (selectedtag.value.isEmpty) {
                        fabController.reverse();
                      }
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: fabController,
        child: FloatingActionButton(
          child: const Icon(Icons.copy),
          onPressed: () {
            final tags = selectedtag.value.join(' ');
            if (tags.isNotEmpty) {
              Clipboard.setData(
                ClipboardData(text: tags),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard:\n$tags'),
                  duration: const Duration(milliseconds: 600),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
