import 'package:boorusphere/presentation/screens/home/search/search_suggestion.dart';
import 'package:boorusphere/presentation/screens/home/search/searchbar.dart';
import 'package:boorusphere/presentation/screens/home/search/searchbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(searchBarController.select((it) => it.isOpen));
    final animator =
        useAnimationController(duration: const Duration(milliseconds: 300));
    final animation =
        CurvedAnimation(parent: animator, curve: Curves.easeInOutCubic);

    useEffect(() {
      isOpen ? animator.forward() : animator.reverse();
    }, [isOpen]);

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FadeTransition(
          opacity: Tween<double>(
            begin: 0.5,
            end: 1,
          ).animate(animation),
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ).animate(animation),
            child: const SearchSuggestion(),
          ),
        ),
        SearchBar(scrollController: scrollController),
      ],
    );
  }
}
