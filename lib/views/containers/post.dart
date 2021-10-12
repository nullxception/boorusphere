import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../model/booru_post.dart';
import '../../provider/booru_api.dart';
import '../components/post_display.dart';
import '../components/post_toolbox.dart';
import '../components/preferred_visibility.dart';
import '../components/subbed_title.dart';

final lastOpenedPostProvider = StateProvider((_) => -1);

class Post extends HookConsumerWidget {
  const Post({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beginPage = ModalRoute.of(context)?.settings.arguments as int;

    final pageController = usePageController(initialPage: beginPage);
    final api = ref.watch(booruApiProvider);
    final lastOpenedIndex = ref.watch(lastOpenedPostProvider);
    final page = useState(beginPage);
    final isFullscreen = useState(false);

    final isNotVideo = api.posts[page.value].displayType != PostType.video;

    useEffect(() {
      SystemChrome.setSystemUIChangeCallback((fullscreen) async {
        isFullscreen.value = fullscreen;
      });

      // reset SystemChrome when pop back to timeline
      return () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        SystemChrome.setPreferredOrientations([]);
      };
    }, const []);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredVisibility(
        visible: !isFullscreen.value,
        child: AppBar(
          backgroundColor: Colors.black.withOpacity(0.4),
          elevation: 0,
          title: SubbedTitle(
            title: '#${page.value + 1} of ${api.posts.length}',
            subtitle: api.posts[page.value].tags.join(' '),
          ),
        ),
      ),
      body: PageView.builder(
        controller: pageController,
        onPageChanged: (index) {
          page.value = index;
          lastOpenedIndex.state = index;
        },
        itemCount: api.posts.length,
        itemBuilder: (_, index) => PostDisplay(content: api.posts[index]),
      ),
      bottomNavigationBar: Visibility(
        visible: !isFullscreen.value && isNotVideo,
        child: PostToolbox(api.posts[page.value]),
      ),
    );
  }
}
