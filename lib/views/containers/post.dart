import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/booru_post.dart';
import '../../provider/booru_api.dart';
import '../components/post_error.dart';
import '../components/post_image.dart';
import '../components/post_toolbox.dart';
import '../components/post_video.dart';
import '../components/preferred_visibility.dart';
import '../components/subbed_title.dart';
import '../hooks/extended_page_controller.dart';

final lastOpenedPostProvider = StateProvider((_) => -1);
final postFullscreenProvider = StateProvider((_) => false);

class Post extends HookConsumerWidget {
  const Post({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beginPage = ModalRoute.of(context)?.settings.arguments as int;

    final pageController = useExtendedPageController(initialPage: beginPage);
    final api = ref.watch(booruApiProvider);
    final lastOpenedIndex = ref.watch(lastOpenedPostProvider.state);
    final page = useState(beginPage);
    final isFullscreen = ref.watch(postFullscreenProvider.state);

    final isNotVideo = api.posts[page.value].displayType != PostType.video;

    useEffect(() {
      SystemChrome.setSystemUIChangeCallback((fullscreen) async {
        isFullscreen.state = fullscreen;
      });

      // reset SystemChrome when pop back to timeline
      return () {
        isFullscreen.state = false;
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([]);
      };
    }, const []);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredVisibility(
        visible: !isFullscreen.state,
        child: AppBar(
          backgroundColor: Colors.black38,
          foregroundColor: Colors.white,
          title: SubbedTitle(
            title: '#${page.value + 1} of ${api.posts.length}',
            subtitle: api.posts[page.value].tags.join(' '),
          ),
        ),
      ),
      body: ExtendedImageGesturePageView.builder(
        controller: pageController,
        onPageChanged: (index) {
          page.value = index;
          lastOpenedIndex.state = index;
        },
        itemCount: api.posts.length,
        itemBuilder: (_, index) {
          final content = api.posts[index];
          switch (content.displayType) {
            case PostType.photo:
              return PostImageDisplay(booru: content);
            case PostType.video:
              return PostVideoDisplay(booru: content);
            default:
              return PostErrorDisplay(booru: content);
          }
        },
      ),
      bottomNavigationBar: Visibility(
        visible: !isFullscreen.state && isNotVideo,
        child: PostToolbox(api.posts[page.value]),
      ),
    );
  }
}
