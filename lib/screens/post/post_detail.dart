import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../entity/post.dart';
import '../../entity/page_option.dart';
import '../../source/blocked_tags.dart';
import '../../source/page.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/string.dart';
import '../../widgets/styled_overlay_region.dart';
import 'tag.dart';

class PostDetailsPage extends HookConsumerWidget with ClipboardMixins {
  const PostDetailsPage({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedtag = useState(<String>[]);
    final pageQuery =
        ref.watch(pageOptionProvider.select((value) => value.query));

    final onTagPressed = useCallback<void Function(String)>((tag) {
      if (!selectedtag.value.contains(tag)) {
        // update the state instead of the list to allow us listening to the
        // length of list for FAB visibility
        selectedtag.value = [...selectedtag.value, tag];
      } else {
        selectedtag.value = selectedtag.value.where((it) => it != tag).toList();
      }
    }, []);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: StyledOverlayRegion(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 72),
            children: [
              ListTile(
                title: const Text('Rating'),
                subtitle: Text(post.rating.name.capitalized),
              ),
              if (post.postUrl.isNotEmpty)
                ListTile(
                  title: const Text('Location'),
                  subtitle: _LinkText(post.postUrl),
                  trailing: _CopyButton(post.postUrl),
                ),
              if (post.source.isNotEmpty)
                ListTile(
                  title: const Text('Source'),
                  subtitle: _LinkText(post.source),
                  trailing: _CopyButton(post.source),
                ),
              if (post.sampleFile.isNotEmpty)
                ListTile(
                  title: const Text('Sample file (displayed)'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Text(
                            '${post.sampleSize.toString()}, ${post.sampleFile.fileExtension}'),
                      ),
                      _LinkText(post.sampleFile),
                    ],
                  ),
                  trailing: _CopyButton(post.sampleFile),
                ),
              ListTile(
                title: const Text('Original file'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                          '${post.originalSize.toString()}, ${post.originalFile.fileExtension}'),
                    ),
                    _LinkText(post.originalFile),
                  ],
                ),
                trailing: _CopyButton(post.originalFile),
              ),
              const ListTile(title: Text('Tags')),
              if (post.hasCategorizedTags && post.tagsMeta.isNotEmpty)
                ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Meta'),
                      ),
                      _TagsView(
                        tags: post.tagsMeta,
                        isSelected: selectedtag.value.contains,
                        onSelected: onTagPressed,
                      ),
                    ],
                  ),
                ),
              if (post.hasCategorizedTags && post.tagsArtist.isNotEmpty)
                ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Artist'),
                      ),
                      _TagsView(
                        tags: post.tagsArtist,
                        isSelected: selectedtag.value.contains,
                        onSelected: onTagPressed,
                      ),
                    ],
                  ),
                ),
              if (post.hasCategorizedTags && post.tagsCharacter.isNotEmpty)
                ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Character'),
                      ),
                      _TagsView(
                        tags: post.tagsCharacter,
                        isSelected: selectedtag.value.contains,
                        onSelected: onTagPressed,
                      ),
                    ],
                  ),
                ),
              if (post.hasCategorizedTags && post.tagsCopyright.isNotEmpty)
                ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Copyright'),
                      ),
                      _TagsView(
                        tags: post.tagsCopyright,
                        isSelected: selectedtag.value.contains,
                        onSelected: onTagPressed,
                      ),
                    ],
                  ),
                ),
              if (post.hasCategorizedTags && post.tagsGeneral.isNotEmpty)
                ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('General'),
                      ),
                      _TagsView(
                        tags: post.tagsGeneral,
                        isSelected: selectedtag.value.contains,
                        onSelected: onTagPressed,
                      ),
                    ],
                  ),
                ),
              if (!post.hasCategorizedTags)
                ListTile(
                  subtitle: _TagsView(
                    tags: post.tags,
                    isSelected: selectedtag.value.contains,
                    onSelected: onTagPressed,
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.tag,
        backgroundColor: context.colorScheme.tertiary,
        foregroundColor: context.colorScheme.onTertiary,
        visible: selectedtag.value.isNotEmpty,
        children: [
          SpeedDialChild(
              child: const Icon(Icons.copy),
              label: 'Copy tag',
              onTap: () {
                final tags = selectedtag.value.join(' ');
                if (tags.isNotEmpty) {
                  clip(context, tags);
                }
              }),
          SpeedDialChild(
            child: const Icon(Icons.block),
            label: 'Block selected tag',
            onTap: () {
              final selectedTags = selectedtag.value;
              if (selectedTags.isNotEmpty) {
                ref.watch(blockedTagsProvider.notifier).pushAll(selectedTags);
                context.scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Added to tags blocker list'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: 'Add tag to current search',
            onTap: () {
              final selectedTags = selectedtag.value;
              if (selectedTags.isNotEmpty) {
                final tags = Set<String>.from(pageQuery.toWordList());
                tags.addAll(selectedTags);
                ref.read(pageOptionProvider.notifier).update(
                    (state) => PageOption(query: tags.join(' '), clear: true));
                context.router.popUntilRoot();
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: 'Search tag',
            onTap: () {
              final tags = selectedtag.value.join(' ');
              if (tags.isNotEmpty) {
                ref
                    .read(pageOptionProvider.notifier)
                    .update((state) => PageOption(query: tags, clear: true));
                context.router.popUntilRoot();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TagsView extends StatelessWidget {
  const _TagsView({
    required this.tags,
    this.isSelected,
    this.onSelected,
  });
  final List<String> tags;
  final bool Function(String tag)? isSelected;
  final void Function(String tag)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: tags
          .map((tag) => Tag(
                tag: tag,
                onPressed: () => onSelected?.call(tag),
                active: () => isSelected?.call(tag) ?? false,
              ))
          .toList(),
    );
  }
}

class _LinkText extends StatelessWidget {
  const _LinkText(this.url);

  final String url;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.zero,
      ),
      onPressed: () =>
          launchUrlString(url, mode: LaunchMode.externalApplication),
      child: Text(url),
    );
  }
}

class _CopyButton extends StatelessWidget with ClipboardMixins {
  const _CopyButton(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 18,
      onPressed: () {
        clip(context, text);
      },
      icon: const Icon(Icons.copy),
    );
  }
}

mixin ClipboardMixins {
  void clip(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    context.scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
