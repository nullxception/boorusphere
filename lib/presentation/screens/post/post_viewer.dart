import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/fullscreen_state.dart';
import 'package:boorusphere/presentation/provider/settings/content_setting_state.dart';
import 'package:boorusphere/presentation/routes/rematerial.dart';
import 'package:boorusphere/presentation/screens/post/hooks/precache_posts.dart';
import 'package:boorusphere/presentation/screens/post/post_image.dart';
import 'package:boorusphere/presentation/screens/post/post_toolbox.dart';
import 'package:boorusphere/presentation/screens/post/post_unknown.dart';
import 'package:boorusphere/presentation/screens/post/post_video.dart';
import 'package:boorusphere/presentation/utils/entity/content.dart';
import 'package:boorusphere/presentation/utils/extensions/buildcontext.dart';
import 'package:boorusphere/presentation/utils/extensions/post.dart';
import 'package:boorusphere/presentation/utils/hooks/extended_page_controller.dart';
import 'package:boorusphere/presentation/widgets/slidefade_visibility.dart';
import 'package:boorusphere/presentation/widgets/styled_overlay_region.dart';
import 'package:boorusphere/presentation/widgets/timeline/timeline_controller.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wakelock/wakelock.dart';

class PostViewer extends HookConsumerWidget {
  const PostViewer({
    super.key,
    required this.initial,
    required this.posts,
  });

  final int initial;
  final Iterable<Post> posts;

  static void open(
    BuildContext context, {
    required int index,
    required Iterable<Post> posts,
  }) {
    final parentContainer = ProviderScope.containerOf(context);
    context.navigator.push(
      ReMaterialPageRoute(
        opaque: false,
        builder: (_) {
          return ProviderScope(
            parent: parentContainer,
            child: PostViewer(initial: index, posts: posts),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineController = ref.watch(timelineControllerProvider);
    const loadMoreThreshold = 90;
    final currentPage = useState(initial);
    final pageController =
        useExtendedPageController(initialPage: currentPage.value);
    final fullscreen = ref.watch(fullscreenStateProvider);

    final post =
        posts.isEmpty ? Post.empty : posts.elementAt(currentPage.value);
    final showAppbar = useState(true);
    final isLoadingMore = useState(false);
    final loadMore = timelineController.onLoadMore;
    final loadOriginal =
        ref.watch(contentSettingStateProvider.select((it) => it.loadOriginal));
    final precachePosts = usePrecachePosts(ref, posts);

    useEffect(() {
      showAppbar.value = !fullscreen;
    }, [fullscreen]);

    useEffect(() {
      Future(() => timelineController.scrollTo(currentPage.value));
      Wakelock.enable();
      return Wakelock.disable;
    }, []);

    return WillPopScope(
      onWillPop: () async {
        ref.watch(fullscreenStateProvider.notifier).reset();
        context.scaffoldMessenger.removeCurrentSnackBar();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: StyledOverlayRegion(
          nightMode: true,
          child: Stack(
            children: [
              ExtendedImageGesturePageView.builder(
                controller: pageController,
                onPageChanged: (index) async {
                  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                    if (context.mounted) {
                      currentPage.value = index;
                    }
                  });
                  timelineController.scrollTo(index);
                  context.scaffoldMessenger.hideCurrentSnackBar();
                  if (loadMore == null) return;

                  final offset = index + 1;
                  final threshold =
                      posts.length / 100 * (100 - loadMoreThreshold);
                  if (offset + threshold > posts.length - 1) {
                    isLoadingMore.value = true;
                    await loadMore();
                    await Future.delayed(kThemeAnimationDuration, () {
                      if (context.mounted) {
                        isLoadingMore.value = false;
                      }
                    });
                  }
                },
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  precachePosts(index, loadOriginal);

                  final post = posts.elementAt(index);
                  final Widget widget;
                  switch (post.content.type) {
                    case PostType.photo:
                      widget = PostImage(post: post);
                      break;
                    case PostType.video:
                      widget = PostVideo(
                        post: post,
                        onToolboxVisibilityChange: (visible) {
                          showAppbar.value = visible;
                        },
                      );
                      break;
                    default:
                      widget = PostUnknown(post: post);
                      break;
                  }
                  return HeroMode(
                    enabled: index == currentPage.value,
                    child: ClipRect(child: widget),
                  );
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SlideFadeVisibility(
                  direction: HidingDirection.toTop,
                  visible: showAppbar.value,
                  child: _PostAppBar(
                    subtitle: post.describeTags,
                    title: isLoadingMore.value
                        ? '#${currentPage.value + 1} of (loading...)'
                        : '#${currentPage.value + 1} of ${posts.length}',
                  ),
                ),
              ),
              if (!post.content.isVideo)
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
