import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../../../entity/post.dart';
import '../../../routes/routes.dart';
import '../../../source/page.dart';
import '../../../source/settings/blur_explicit_post.dart';
import '../../../source/settings/grid.dart';
import '../../../utils/extensions/buildcontext.dart';

class TimelineContent extends HookConsumerWidget {
  const TimelineContent({
    super.key,
    required this.scrollController,
    this.posts = const [],
    this.onLoadMore,
  });

  final AutoScrollController scrollController;
  final List<Post> posts;
  final void Function()? onLoadMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridExtra = ref.watch(gridProvider);
    final screenWidth = context.mediaQuery.size.width;
    final flexibleGrid = (screenWidth / 200).round() + gridExtra;

    performAutoScroll(int dest) {
      if (!scrollController.hasClients || scrollController.isAutoScrolling) {
        return;
      }

      if (scrollController.isIndexStateInLayoutRange(dest)) {
        scrollController.scrollToIndex(
          dest,
          duration: const Duration(milliseconds: 16),
          preferPosition: AutoScrollPosition.middle,
        );
      } else {
        scrollController
            .scrollToIndex(
              dest,
              duration: const Duration(milliseconds: 800),
              preferPosition: AutoScrollPosition.middle,
            )
            .whenComplete(() => scrollController.highlight(dest,
                highlightDuration: const Duration(milliseconds: 150)));
      }
    }

    return SliverMasonryGrid.count(
      crossAxisCount: flexibleGrid,
      key: ObjectKey(flexibleGrid),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return AutoScrollTag(
          key: ValueKey(index),
          controller: scrollController,
          index: index,
          highlightColor: context.theme.colorScheme.surfaceTint,
          child: Card(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            // saveLayer() is used here to avoid artifacts that frequently
            // happened while scrolling
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: GestureDetector(
              child: Hero(
                tag: post.id,
                child: _Thumbnail(post: post),
                flightShuttleBuilder: (flightContext, animation,
                    flightDirection, fromHeroContext, toHeroContext) {
                  final Hero toHero = toHeroContext.widget as Hero;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: post.aspectRatio,
                        // clip incoming child to avoid overflow that might be
                        // caused by blurExplicit enabled
                        child: flightDirection == HeroFlightDirection.pop
                            ? ClipRect(child: toHero.child)
                            : toHero.child,
                      ),
                    ],
                  );
                },
              ),
              onTap: () {
                context.scaffoldMessenger.removeCurrentSnackBar();
                context.router.push(
                  PostRoute(
                    beginPage: index,
                    posts: posts,
                    onReturned: performAutoScroll,
                    onLoadMore: onLoadMore,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _Thumbnail extends HookConsumerWidget {
  const _Thumbnail({required this.post});
  final Post post;

  FilterQuality _thumbnailQuality(int gridExtra) {
    switch (gridExtra) {
      case 0:
        return FilterQuality.medium;
      case 1:
        return FilterQuality.low;
      default:
        return FilterQuality.none;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridExtra = ref.watch(gridProvider);
    final blurExplicitPost = ref.watch(blurExplicitPostProvider);
    final pageCookies =
        ref.watch(pageDataProvider.select((value) => value.cookies));

    return AspectRatio(
      aspectRatio: post.aspectRatio,
      child: ExtendedImage.network(
        post.previewFile,
        headers: {
          'Referer': post.postUrl,
          'Cookie': pageCookies,
        },
        filterQuality: _thumbnailQuality(gridExtra),
        fit: BoxFit.cover,
        beforePaintImage: (canvas, rect, image, paint) {
          if (blurExplicitPost && post.rating == PostRating.explicit) {
            paint.imageFilter = ImageFilter.blur(
              sigmaX: 8,
              sigmaY: 8,
              tileMode: TileMode.decal,
            );
          }
          return false;
        },
        enableLoadState: false,
        loadStateChanged: (state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: state.extendedImageLoadState == LoadState.completed
                ? state.completedWidget
                : _Placeholder(
                    key: ValueKey(post.id),
                    isFailed: state.extendedImageLoadState == LoadState.failed,
                  ),
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
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    super.key,
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
          stops: const <double>[
            0.0,
            0.35,
            0.5,
            0.65,
            1.0
          ]),
      period: const Duration(milliseconds: 700),
      child: Container(
        color: Colors.black,
        child: const SizedBox.expand(),
      ),
    );
  }
}
