import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/booru_post.dart';
import '../../provider/common.dart';

class PostDetails extends StatefulHookWidget {
  const PostDetails({Key? keys, required this.data}) : super(key: keys);

  final BooruPost data;

  @override
  State<StatefulWidget> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final _tagStateKey = GlobalKey<TagsState>();

  String getSelectedTags(TagsState? state) {
    return state?.getAllItem
            .where((it) => it.active ?? false)
            .map((it) => it.title)
            .join(' ') ??
        '';
  }

  bool hasSelectedTags(TagsState? state) {
    final count = state?.getAllItem.where((it) => it.active ?? false).length;
    return count != null && count > 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeServer = useProvider(activeServerProvider);
    final postUrl = activeServer.composePostUrl(widget.data.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Size'),
            subtitle: Text('${widget.data.width}x${widget.data.height}'),
          ),
          ListTile(
            title: const Text('Type'),
            subtitle: Text(widget.data.mimeType),
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
              onPressed: () => launch(widget.data.src),
              child: Text(widget.data.src),
            ),
          ),
          const ListTile(
            title: Text('Tags'),
          ),
          ListTile(
            title: Tags(
              key: _tagStateKey,
              alignment: WrapAlignment.start,
              itemCount: widget.data.tags.length,
              itemBuilder: (index) => ItemTags(
                active: false,
                title: widget.data.tags[index],
                index: index,
                onPressed: (a) {
                  setState(() {});
                },
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Visibility(
        visible: hasSelectedTags(_tagStateKey.currentState),
        child: FloatingActionButton(
          child: const Icon(Icons.copy),
          onPressed: () {
            final tags = getSelectedTags(_tagStateKey.currentState);
            if (tags.isNotEmpty) {
              Clipboard.setData(
                ClipboardData(text: tags),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard:\n$tags'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
