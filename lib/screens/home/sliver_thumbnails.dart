import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../../entity/post.dart';
import '../../settings/blur_explicit_post.dart';
import '../../settings/grid.dart';
import '../../source/page.dart';
import '../../utils/extensions/buildcontext.dart';
import '../post/post.dart';

class SliverThumbnails extends HookConsumerWidget {
  const SliverThumbnails({
    super.key,
    required this.autoScrollController,
    this.onTap,
  });

  final AutoScrollController autoScrollController;
  final Function(int index)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridExtra = ref.watch(gridProvider);
    final pageData = ref.watch(pageDataProvider);
    final screenWidth = context.mediaQuery.size.width;
    final flexibleGrid = (screenWidth / 200).round() + gridExtra;

    final autoScrollTo = useCallback<Function(int)>((dest) {
      if (autoScrollController.isAutoScrolling) return;
      if (autoScrollController.isIndexStateInLayoutRange(dest)) {
        autoScrollController.scrollToIndex(
          dest,
          duration: const Duration(milliseconds: 16),
          preferPosition: AutoScrollPosition.middle,
        );
      } else {
        autoScrollController
            .scrollToIndex(
              dest,
              duration: const Duration(milliseconds: 800),
              preferPosition: AutoScrollPosition.middle,
            )
            .whenComplete(() => autoScrollController.highlight(dest,
                highlightDuration: const Duration(milliseconds: 150)));
      }
    }, []);

    return SliverMasonryGrid.count(
      crossAxisCount: flexibleGrid,
      key: ObjectKey(flexibleGrid),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childCount: pageData.posts.length,
      itemBuilder: (context, index) {
        final post = pageData.posts[index];
        return AutoScrollTag(
          key: ValueKey(index),
          controller: autoScrollController,
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
                child: Thumbnail(post: post),
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
              onTap: () async {
                onTap?.call(index);
                final dest = await context.navigator.push(
                  ChillMaterialRoute(
                    builder: (context) {
                      return PostPage(beginPage: index);
                    },
                  ),
                );
                if (dest is int) {
                  autoScrollTo(dest);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class Thumbnail extends HookConsumerWidget {
  const Thumbnail({super.key, required this.post});
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

    return ExtendedImage.network(
      post.previewFile,
      headers: {'Referer': post.postUrl},
      filterQuality: _thumbnailQuality(gridExtra),
      fit: BoxFit.cover,
      loadStateChanged: (state) {
        Widget widget;
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            widget = const _ThumbnailShimmer();
            break;
          case LoadState.failed:
            widget = const Material(child: Icon(Icons.broken_image_outlined));
            break;
          default:
            widget = blurExplicitPost && post.rating == PostRating.explicit
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 8,
                      sigmaY: 8,
                      tileMode: TileMode.decal,
                    ),
                    child: state.completedWidget,
                  )
                : state.completedWidget;
            break;
        }
        return AspectRatio(
          aspectRatio: post.aspectRatio,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: widget,
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
          ),
        );
      },
    );
  }
}

class _ThumbnailShimmer extends StatelessWidget {
  const _ThumbnailShimmer();

  @override
  Widget build(BuildContext context) {
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

class ChillMaterialRoute extends MaterialPageRoute {
  ChillMaterialRoute({
    required super.builder,
    this.duration = const Duration(milliseconds: 400),
  });

  final Duration duration;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration => duration;
}
