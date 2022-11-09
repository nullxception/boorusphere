import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/entity/page_option.dart';
import 'package:boorusphere/entity/pixel_size.dart';
import 'package:boorusphere/entity/post.dart';
import 'package:boorusphere/presentation/screens/post/tag.dart';
import 'package:boorusphere/presentation/widgets/styled_overlay_region.dart';
import 'package:boorusphere/source/blocked_tags.dart';
import 'package:boorusphere/source/page.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:boorusphere/utils/extensions/imageprovider.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PostDetailsPage extends HookConsumerWidget with ClipboardMixins {
  const PostDetailsPage({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedtag = useState(<String>[]);
    final pageQuery =
        ref.watch(pageOptionProvider.select((value) => value.query));
    final pageCookies =
        ref.watch(pageDataProvider.select((value) => value.cookies));

    onTagPressed(tag) {
      if (!selectedtag.value.contains(tag)) {
        // update the state instead of the list to allow us listening to the
        // length of list for FAB visibility
        selectedtag.value = [...selectedtag.value, tag];
      } else {
        selectedtag.value = selectedtag.value.where((it) => it != tag).toList();
      }
    }

    updateSearch(Iterable<String> tags) {
      final newQuery = Set.from(tags).join(' ');
      if (newQuery.isEmpty) return;
      ref.read(pageOptionProvider.notifier).update((state) {
        return PageOption(query: newQuery, clear: true);
      });
      context.router.popUntilRoot();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: StyledOverlayRegion(
        child: SafeArea(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Rating'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(post.rating.name.capitalized),
                ),
              ),
              if (post.postUrl.isNotEmpty)
                ListTile(
                  title: const Text('Location'),
                  subtitle: _LinkSubtitle(post.postUrl),
                  trailing: _CopyButton(post.postUrl),
                ),
              if (post.source.isNotEmpty)
                ListTile(
                  title: const Text('Source'),
                  subtitle: _LinkSubtitle(post.source),
                  trailing: _CopyButton(post.source),
                ),
              if (post.sampleFile.isNotEmpty)
                ListTile(
                  title: const Text('Sample file'),
                  subtitle: FutureBuilder<PixelSize>(
                    future: post.content.isPhoto && !post.sampleSize.hasPixels
                        ? ExtendedNetworkImageProvider(
                            post.sampleFile,
                            cache: true,
                            headers: {
                              'Referer': post.postUrl,
                              'Cookie': pageCookies,
                            },
                          ).resolvePixelSize()
                        : Future.value(post.sampleSize),
                    builder: (context, snapshot) {
                      final size = snapshot.data ?? post.sampleSize;
                      return _LinkSubtitle(
                        post.sampleFile,
                        label: '$size, ${post.sampleFile.fileExtension}',
                      );
                    },
                  ),
                  trailing: _CopyButton(post.sampleFile),
                ),
              ListTile(
                title: const Text('Original file'),
                subtitle: _LinkSubtitle(
                  post.originalFile,
                  label:
                      '${post.originalSize.toString()}, ${post.originalFile.fileExtension}',
                ),
                trailing: _CopyButton(post.originalFile),
              ),
              ListTile(
                title: const Text('Tags'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 72),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!post.hasCategorizedTags)
                        _TagsView(
                          tags: post.tags,
                          isSelected: selectedtag.value.contains,
                          onSelected: onTagPressed,
                        )
                      else ...[
                        if (post.tagsMeta.isNotEmpty)
                          _TagsView(
                            label: 'Meta',
                            tags: post.tagsMeta,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsArtist.isNotEmpty)
                          _TagsView(
                            label: 'Artist',
                            tags: post.tagsArtist,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsCharacter.isNotEmpty)
                          _TagsView(
                            label: 'Character',
                            tags: post.tagsCharacter,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsCopyright.isNotEmpty)
                          _TagsView(
                            label: 'Copyright',
                            tags: post.tagsCopyright,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsGeneral.isNotEmpty)
                          _TagsView(
                            label: 'General',
                            tags: post.tagsGeneral,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                      ],
                    ],
                  ),
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
              if (selectedtag.value.isEmpty) return;
              updateSearch([...pageQuery.toWordList(), ...selectedtag.value]);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: 'Search tag',
            onTap: () {
              updateSearch(selectedtag.value);
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
    this.label,
  });

  final List<String> tags;
  final bool Function(String tag)? isSelected;
  final void Function(String tag)? onSelected;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final labelText = label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (labelText != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(labelText),
          ),
        Wrap(
          children: [
            for (final tag in tags)
              Tag(
                tag: tag,
                onPressed: (isActive) => onSelected?.call(tag),
                active: isSelected?.call(tag) ?? false,
              )
          ],
        ),
      ],
    );
  }
}

class _LinkSubtitle extends StatelessWidget {
  const _LinkSubtitle(this.url, {this.label});

  final String url;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final labelText = label;
    return InkWell(
      onTap: () => launchUrlString(url, mode: LaunchMode.externalApplication),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (labelText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(labelText),
            ),
          DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(
                  color: context.colorScheme.primary,
                ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                url,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
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
