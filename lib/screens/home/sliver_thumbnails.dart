import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../../data/post.dart';
import '../../../providers/settings/blur_explicit_post.dart';
import '../../../providers/settings/grid.dart';
import '../../providers/page.dart';
import '../../utils/extensions/buildcontext.dart';
import '../routes.dart';

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
    final pageManager = ref.watch(pageManagerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final flexibleGrid = (screenWidth / 200).round() + gridExtra;

    return SliverMasonryGrid.count(
      crossAxisCount: flexibleGrid,
      key: ObjectKey(flexibleGrid),
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      childCount: pageManager.posts.length,
      itemBuilder: (context, index) => AutoScrollTag(
        key: ValueKey(index),
        controller: autoScrollController,
        index: index,
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: GestureDetector(
            child: Thumbnail(post: pageManager.posts[index]),
            onTap: () async {
              onTap?.call(index);

              final result = await Navigator.pushNamed(context, Routes.post,
                  arguments: index) as int;
              if (result != index) {
                autoScrollController.scrollToIndex(
                  result,
                  duration: const Duration(milliseconds: 600),
                  preferPosition: AutoScrollPosition.middle,
                );
              }
            },
          ),
        ),
      ),
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
