import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommonNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const CommonNetworkImage({
    super.key,
    required this.imageUrl,
    this.size = 20, // default image size
  });

  bool get _isSvg => imageUrl.toLowerCase().endsWith('.svg');

  bool get _isValidUrl {
    final trimmed = imageUrl.trim();
    // basic sanity checks to avoid executing a network call for a clearly invalid URL
    return trimmed.isNotEmpty &&
        trimmed.startsWith('http') &&
        !trimmed.endsWith('null') &&
        !trimmed.endsWith('undefined');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl) {
      return Icon(
        Icons.image_not_supported_outlined,
        size: size,
        color: Colors.grey,
      );
    }

    final trimmedUrl = imageUrl.trim();

    return Center(
      child: _isSvg
          ? SvgPicture.network(
              trimmedUrl,
              width: size,
              height: size,
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => const SizedBox(),
            )
          : CachedNetworkImage(
              imageUrl: trimmedUrl,
              width: size,
              height: size,
              fit: BoxFit.contain,
              placeholder: (context, url) => const SizedBox(),
              errorWidget: (context, url, error) => Icon(
                Icons.image_not_supported_outlined,
                size: size,
                color: Colors.grey,
              ),
            ),
    );
  }
}
