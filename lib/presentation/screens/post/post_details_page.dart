import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/blocked_tags_state.dart';
import 'package:boorusphere/presentation/routes/app_router.dart';
import 'package:boorusphere/presentation/screens/home/page_args.dart';
import 'package:boorusphere/presentation/screens/post/hooks/post_headers.dart';
import 'package:boorusphere/presentation/screens/post/tag.dart';
import 'package:boorusphere/presentation/utils/entity/pixel_size.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/images.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/presentation/widgets/styled_overlay_region.dart';
import 'package:boorusphere/utils/extensions/string.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PostDetailsPage extends HookConsumerWidget with ClipboardMixins {
  const PostDetailsPage({super.key, required this.post, required this.args});
  final Post post;
  final PageArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headers = usePostHeaders(ref, post);
    final selectedtag = useState(<String>[]);

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
      context.router.push(HomeRoute(args: args.copyWith(query: newQuery)));
    }

    final rating = post.rating.describe(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.details)),
      body: StyledOverlayRegion(
        child: SafeArea(
          child: ListView(
            children: [
              if (rating.isNotEmpty)
                ListTile(
                  title: Text(context.t.rating.title),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(rating),
                  ),
                ),
              if (post.postUrl.isNotEmpty)
                ListTile(
                  title: Text(context.t.location),
                  subtitle: _LinkSubtitle(post.postUrl),
                  trailing: _CopyButton(post.postUrl),
                ),
              if (post.source.isNotEmpty)
                ListTile(
                  title: Text(context.t.source),
                  subtitle: _LinkSubtitle(post.source),
                  trailing: _CopyButton(post.source),
                ),
              if (post.sampleFile.isNotEmpty)
                ListTile(
                  title: Text(context.t.fileSample),
                  subtitle: FutureBuilder<PixelSize>(
                    future: post.content.isPhoto && !post.sampleSize.hasPixels
                        ? ExtendedNetworkImageProvider(
                            post.sampleFile,
                            cache: true,
                            headers: headers.data,
                          ).resolvePixelSize()
                        : Future.value(post.sampleSize),
                    builder: (context, snapshot) {
                      final size = snapshot.data ?? post.sampleSize;
                      return _LinkSubtitle(
                        post.sampleFile,
                        label: '$size, ${post.sampleFile.fileExt}',
                      );
                    },
                  ),
                  trailing: _CopyButton(post.sampleFile),
                ),
              ListTile(
                title: Text(context.t.fileOg),
                subtitle: _LinkSubtitle(
                  post.originalFile,
                  label:
                      '${post.originalSize.toString()}, ${post.originalFile.fileExt}',
                ),
                trailing: _CopyButton(post.originalFile),
              ),
              ListTile(
                title: Text(context.t.tags),
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
                            label: context.t.meta,
                            tags: post.tagsMeta,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsArtist.isNotEmpty)
                          _TagsView(
                            label: context.t.artist,
                            tags: post.tagsArtist,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsCharacter.isNotEmpty)
                          _TagsView(
                            label: context.t.character,
                            tags: post.tagsCharacter,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsCopyright.isNotEmpty)
                          _TagsView(
                            label: context.t.copyright,
                            tags: post.tagsCopyright,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsGeneral.isNotEmpty)
                          _TagsView(
                            label: context.t.general,
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
              label: context.t.actionTag.copy,
              onTap: () {
                final tags = selectedtag.value.join(' ');
                if (tags.isNotEmpty) {
                  clip(context, tags);
                }
              }),
          SpeedDialChild(
            child: const Icon(Icons.block),
            label: context.t.actionTag.block,
            onTap: () {
              final selectedTags = selectedtag.value;
              if (selectedTags.isNotEmpty) {
                ref
                    .read(blockedTagsStateProvider.notifier)
                    .pushAll(tags: selectedTags);
                context.scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(context.t.actionTag.blocked),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: context.t.actionTag.append,
            onTap: () {
              if (selectedtag.value.isEmpty) return;
              updateSearch([...args.query.toWordList(), ...selectedtag.value]);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: context.t.actionTag.search,
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
      SnackBar(
        content: Text(context.t.copySuccess),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
