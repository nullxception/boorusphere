import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Favicon extends StatelessWidget {
  const Favicon({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (_, __) => const Icon(Icons.public),
      errorWidget: (_, __, ___) => const Icon(Icons.public),
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      imageBuilder: (context, img) => Container(
        width: IconTheme.of(context).size,
        height: IconTheme.of(context).size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: img, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
