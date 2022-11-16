import 'package:auto_route/auto_route.dart';
import 'package:boorusphere/data/repository/booru/entity/pixel_size.dart';
import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/i18n/strings.g.dart';
import 'package:boorusphere/presentation/provider/blocked_tags.dart';
import 'package:boorusphere/presentation/provider/booru/extension/post.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/screens/post/tag.dart';
import 'package:boorusphere/presentation/widgets/styled_overlay_region.dart';
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
        ref.watch(pageProvider.select((it) => it.data.option.query));

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
      ref.read(pageProvider.notifier).update((state) {
        return state.copyWith(query: newQuery, clear: true);
      });
      context.router.popUntilRoot();
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.details)),
      body: StyledOverlayRegion(
        child: SafeArea(
          child: ListView(
            children: [
              ListTile(
                title: Text(t.rating.title),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(post.rating.translate()),
                ),
              ),
              if (post.postUrl.isNotEmpty)
                ListTile(
                  title: Text(t.location),
                  subtitle: _LinkSubtitle(post.postUrl),
                  trailing: _CopyButton(post.postUrl),
                ),
              if (post.source.isNotEmpty)
                ListTile(
                  title: Text(t.source),
                  subtitle: _LinkSubtitle(post.source),
                  trailing: _CopyButton(post.source),
                ),
              if (post.sampleFile.isNotEmpty)
                ListTile(
                  title: Text(t.fileSample),
                  subtitle: FutureBuilder<PixelSize>(
                    future: post.content.isPhoto && !post.sampleSize.hasPixels
                        ? ExtendedNetworkImageProvider(
                            post.sampleFile,
                            cache: true,
                            headers: post.getHeaders(ref),
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
                title: Text(t.fileOG),
                subtitle: _LinkSubtitle(
                  post.originalFile,
                  label:
                      '${post.originalSize.toString()}, ${post.originalFile.fileExtension}',
                ),
                trailing: _CopyButton(post.originalFile),
              ),
              ListTile(
                title: Text(t.tags),
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
                            label: t.meta,
                            tags: post.tagsMeta,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsArtist.isNotEmpty)
                          _TagsView(
                            label: t.artist,
                            tags: post.tagsArtist,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsCharacter.isNotEmpty)
                          _TagsView(
                            label: t.character,
                            tags: post.tagsCharacter,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsCopyright.isNotEmpty)
                          _TagsView(
                            label: t.copyright,
                            tags: post.tagsCopyright,
                            isSelected: selectedtag.value.contains,
                            onSelected: onTagPressed,
                          ),
                        if (post.tagsGeneral.isNotEmpty)
                          _TagsView(
                            label: t.general,
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
              label: t.actionTag.copy,
              onTap: () {
                final tags = selectedtag.value.join(' ');
                if (tags.isNotEmpty) {
                  clip(context, tags);
                }
              }),
          SpeedDialChild(
            child: const Icon(Icons.block),
            label: t.actionTag.block,
            onTap: () {
              final selectedTags = selectedtag.value;
              if (selectedTags.isNotEmpty) {
                ref.watch(blockedTagsProvider.notifier).pushAll(selectedTags);
                context.scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(t.actionTag.blocked),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: t.actionTag.append,
            onTap: () {
              if (selectedtag.value.isEmpty) return;
              updateSearch([...pageQuery.toWordList(), ...selectedtag.value]);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.search),
            label: t.actionTag.search,
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
        content: Text(t.copySuccess),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

extension PostRatingText on PostRating {
  String translate() {
    switch (this) {
      case PostRating.safe:
        return t.rating.safe;
      case PostRating.explicit:
        return t.rating.explicit;
      default:
        return t.rating.questionable;
    }
  }
}
