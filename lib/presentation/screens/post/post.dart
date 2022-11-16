import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/hooks/extended_page_controller.dart';
import 'package:boorusphere/presentation/provider/booru/entity/fetch_state.dart';
import 'package:boorusphere/presentation/provider/booru/extension/post.dart';
import 'package:boorusphere/presentation/provider/booru/page_state.dart';
import 'package:boorusphere/presentation/provider/fullscreen.dart';
import 'package:boorusphere/presentation/provider/settings/content/content_settings.dart';
import 'package:boorusphere/presentation/screens/home/timeline/controller.dart';
import 'package:boorusphere/presentation/screens/post/post_error.dart';
import 'package:boorusphere/presentation/screens/post/post_image.dart';
import 'package:boorusphere/presentation/screens/post/post_toolbox.dart';
import 'package:boorusphere/presentation/screens/post/post_video.dart';
import 'package:boorusphere/presentation/widgets/slidefade_visibility.dart';
import 'package:boorusphere/presentation/widgets/styled_overlay_region.dart';
import 'package:boorusphere/utils/extensions/buildcontext.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostPage extends HookConsumerWidget {
  const PostPage({
    super.key,
    required this.beginPage,
    required this.controller,
  });

  final int beginPage;
  final TimelineController controller;

  void _precachePostImages(
    WidgetRef ref,
    BuildContext context,
    List<Post> posts,
    int index,
    bool displayOriginal,
  ) {
    final next = index + 1;
    final prev = index - 1;

    if (prev >= 0) {
      _precachePostImage(ref, context, posts[prev], displayOriginal);
    }

    if (next < posts.length) {
      _precachePostImage(ref, context, posts[next], displayOriginal);
    }
  }

  void _precachePostImage(
    WidgetRef ref,
    BuildContext context,
    Post post,
    bool displayOriginal,
  ) {
    if (!post.content.isPhoto) return;

    precacheImage(
      ExtendedNetworkImageProvider(
        displayOriginal ? post.originalFile : post.content.url,
        headers: post.getHeaders(ref),
        // params below follows the default value on
        // the ExtendedImage.network() factory
        cache: true,
        retries: 3,
      ),
      context,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const loadMoreThreshold = 90;
    final page = useState(beginPage);
    final pageController = useExtendedPageController(initialPage: page.value);
    final displayOriginal = ref.watch(ContentSettingsProvider.loadOriginal);
    final pageState = ref.watch(pageProvider);
    final fullscreen = ref.watch(fullscreenProvider);
    final posts = ref.watch(pageProvider.select((it) => it.data.posts));

    final post = posts.isEmpty ? Post.empty : posts[page.value];
    final isVideo = post.content.isVideo;
    final totalPost = posts.length;

    return WillPopScope(
      onWillPop: () async {
        context.scaffoldMessenger.removeCurrentSnackBar();
        controller.revealAt(page.value);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: StyledOverlayRegion(
          nightMode: true,
          child: Stack(
            children: [
              Padding(
                // android back gesture is not ignored by PageView
                // add tiny padding to avoid it
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: ExtendedImageGesturePageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    context.scaffoldMessenger.hideCurrentSnackBar();
                    page.value = index;
                    final offset = index + 1;
                    final threshold =
                        totalPost / 100 * (100 - loadMoreThreshold);
                    if (offset + threshold > totalPost) {
                      controller.loadMoreData();
                    }
                  },
                  itemCount: totalPost,
                  itemBuilder: (_, index) {
                    _precachePostImages(
                        ref, context, posts, index, displayOriginal);

                    final post = posts[index];
                    final Widget widget;
                    final heroKey =
                        controller.heroKeyBuilder?.call(post) ?? post.id;
                    switch (post.content.type) {
                      case PostType.photo:
                        widget = PostImageDisplay(
                          post: post,
                          isFromHome: index == beginPage,
                          heroKey: heroKey,
                        );
                        break;
                      case PostType.video:
                        widget = PostVideoDisplay(
                          post: post,
                          heroKey: heroKey,
                        );
                        break;
                      default:
                        widget = PostErrorDisplay(
                          post: post,
                          heroKey: heroKey,
                        );
                        break;
                    }
                    return HeroMode(
                      enabled: index == page.value,
                      child: widget,
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SlideFadeVisibility(
                  direction: HidingDirection.toTop,
                  visible: !fullscreen,
                  child: _PostAppBar(
                    subtitle: post.tags.join(' '),
                    title: pageState is LoadingFetchState
                        ? '#${page.value + 1} of (loading...)'
                        : '#${page.value + 1} of ${posts.length}',
                  ),
                ),
              ),
              if (!isVideo)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlideFadeVisibility(
                    direction: HidingDirection.toBottom,
                    visible: !fullscreen,
                    child: PostToolbox(post),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PostAppBar({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomLeft,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w300),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 64);
}
