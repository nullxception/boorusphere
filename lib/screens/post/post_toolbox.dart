import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../entity/post.dart';
import '../../routes/routes.dart';
import '../../services/download.dart';
import '../../source/favorites.dart';
import '../../utils/extensions/buildcontext.dart';
import '../../utils/extensions/number.dart';
import '../../widgets/download_dialog.dart';

class PostToolbox extends HookConsumerWidget {
  const PostToolbox(this.post, {super.key});

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewPadding = context.mediaQuery.viewPadding;
    final safePaddingBottom = useState(viewPadding.bottom);
    if (viewPadding.bottom > safePaddingBottom.value) {
      safePaddingBottom.value = viewPadding.bottom;
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      height: safePaddingBottom.value + 86,
      alignment: Alignment.bottomRight,
      padding: EdgeInsets.only(bottom: safePaddingBottom.value + 8, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PostFavoriteButton(post: post),
          PostDownloadButton(post: post),
          PostOpenLinkButton(post: post),
          PostDetailsButton(post: post),
        ],
      ),
    );
  }
}

class PostDetailsButton extends StatelessWidget {
  const PostDetailsButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      icon: const Icon(Icons.info),
      onPressed: () => context.router.push(PostDetailsRoute(post: post)),
    );
  }
}

class PostOpenLinkButton extends StatelessWidget {
  const PostOpenLinkButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      icon: const Icon(Icons.link_outlined),
      onPressed: () => launchUrlString(post.originalFile,
          mode: LaunchMode.externalApplication),
    );
  }
}

class PostFavoriteButton extends ConsumerWidget {
  const PostFavoriteButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesProvider);
    final isFavorite = ref.watch(favoritesProvider.notifier).checkExists(post);

    addToFavorites(Post post) {
      ref.watch(favoritesProvider.notifier).save(post);
      context.scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Text('Added to Favorites'),
            ],
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    removeFromFavorites(Post post) {
      ref.watch(favoritesProvider.notifier).delete(post);
      context.scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Text('Removed from Favorites'),
            ],
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    return IconButton(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      icon: AnimatedSwitcher(
        duration: kThemeChangeDuration,
        child: isFavorite
            ? const Icon(Icons.favorite)
            : const Icon(Icons.favorite_border),
      ),
      onPressed: () =>
          isFavorite ? removeFromFavorites(post) : addToFavorites(post),
    );
  }
}

class PostDownloadButton extends HookConsumerWidget {
  const PostDownloadButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloader = ref.watch(downloadProvider);
    final downloadProgress = downloader.getProgressByPost(post);

    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: downloadProgress.status.isDownloading
              ? downloadProgress.progress.ratio
              : 0,
        ),
        IconButton(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          icon: Icon(downloadProgress.status.isDownloaded
              ? Icons.download_done
              : Icons.download),
          onPressed: () {
            DownloaderDialog.show(context: context, post: post);
          },
          disabledColor: context.colorScheme.primary,
        ),
      ],
    );
  }
}
