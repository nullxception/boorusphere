import 'dart:ui';

import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/booru/post_headers_factory.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/provider/settings/ui_setting_state.dart';
import 'package:boorusphere/presentation/routes/rematerial.dart';
import 'package:boorusphere/presentation/screens/post/post_page.dart';
import 'package:boorusphere/presentation/utils/entity/content.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/images.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline_controller.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinycolor2/tinycolor2.dart';

class Timeline extends ConsumerWidget {
  const Timeline({super.key, required this.posts});

  final Iterable<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid = ref.watch(uiSettingStateProvider.select((ui) => ui.grid));
    final screenWidth = context.mediaQuery.size.width;
    final flexibleGrid = (screenWidth / 200).round() + grid;

    return SliverMasonryGrid.count(
      crossAxisCount: flexibleGrid,
      key: ObjectKey(flexibleGrid),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childCount: posts.length,
      itemBuilder: (context, index) {
        return _ThumbnailCard(index: index, posts: posts);
      },
    );
  }
}

class _ThumbnailCard extends HookConsumerWidget {
  const _ThumbnailCard({
    required this.index,
    required this.posts,
  });

  final int index;
  final Iterable<Post> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = useMemoized(() => posts.elementAt(index));
    final scrollController = ref
        .watch(timelineControllerProvider.select((it) => it.scrollController));
    final blurExplicit =
        ref.watch(contentSettingStateProvider.select((it) => it.blurExplicit));

    return AutoScrollTag(
      key: ValueKey(index),
      controller: scrollController,
      index: index,
      highlightColor: context.theme.colorScheme.surfaceTint,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        clipBehavior: Clip.hardEdge,
        child: GestureDetector(
          child: Hero(
            tag: post.heroTag,
            placeholderBuilder: (context, heroSize, child) => child,
            flightShuttleBuilder: (flightContext, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              final Hero toHero = toHeroContext.widget as Hero;
              final isLong = post.aspectRatio < 0.5;
              final isPop = flightDirection == HeroFlightDirection.pop;

              return Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: isPop && isLong ? 0.5 : post.aspectRatio,
                    // clip incoming child to avoid overflow that might be
                    // caused by blurExplicit enabled
                    child: isPop ? ClipRect(child: toHero.child) : toHero.child,
                  ),
                ],
              );
            },
            child: _ThumbnailImage(post: post, blurExplicit: blurExplicit),
          ),
          onTap: () {
            context.scaffoldMessenger.removeCurrentSnackBar();
            context.navigator.push(
              ReMaterialPageRoute(
                opaque: false,
                builder: (context) {
                  return PostPage(
                    beginPage: index,
                    posts: posts,
                    timelineController: ref.read(timelineControllerProvider),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ThumbnailImage extends ConsumerWidget {
  const _ThumbnailImage({
    required this.post,
    this.blurExplicit = false,
  });

  final Post post;
  final bool blurExplicit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headers = ref.watch(postHeadersFactoryProvider(post));
    // limit timeline thumbnail to 18:9
    final isLong = post.aspectRatio < 0.5;

    final image = AspectRatio(
      aspectRatio: isLong ? 0.5 : post.aspectRatio,
      child: ExtendedImage.network(
        // load sample photo when it's above 35:9
        post.aspectRatio < 0.26 && post.sampleFile.asContent().isPhoto
            ? post.sampleFile
            : post.previewFile,
        headers: headers,
        fit: BoxFit.cover,
        enableLoadState: false,
        beforePaintImage: (canvas, rect, image, paint) {
          if (blurExplicit && post.rating.isExplicit) {
            paint.imageFilter = ImageFilter.blur(
              sigmaX: 5,
              sigmaY: 5,
              tileMode: TileMode.decal,
            );
          }
          return false;
        },
        loadStateChanged: (state) {
          if (state.wasSynchronouslyLoaded && state.isCompleted) {
            return state.completedWidget;
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: state.isCompleted
                ? state.completedWidget
                : _Placeholder(isFailed: state.isFailed),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
          );
        },
      ),
    );

    return isLong
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: [
              image,
              const _LongThumbnailIndicator(),
            ],
          )
        : image;
  }
}

class _LongThumbnailIndicator extends StatelessWidget {
  const _LongThumbnailIndicator();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.background.withOpacity(0.8),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(22, 6, 22, 4),
        child: Icon(Icons.gradient, size: 16),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    this.isFailed = false,
  });

  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    if (isFailed) {
      return const Material(child: Icon(Icons.broken_image_outlined));
    }

    final baseColor = context.isLightThemed
        ? context.colorScheme.background.desaturate(50).darken(2)
        : context.colorScheme.surface;
    final highlightColor = context.isLightThemed
        ? context.colorScheme.background.desaturate(50).lighten(2)
        : context.colorScheme.surface.lighten(5);

    return Shimmer(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          baseColor,
          baseColor,
          highlightColor,
          baseColor,
          baseColor
        ],
        stops: const <double>[0.0, 0.35, 0.5, 0.65, 1.0],
      ),
      period: const Duration(milliseconds: 700),
      child: Container(
        color: Colors.black,
        child: const SizedBox.expand(),
      ),
    );
  }
}
