import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Renders either a hosted/local Flutter asset or an HTTPS image URL.
class PortfolioImage extends StatelessWidget {
  const PortfolioImage({
    required this.source,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
    super.key,
  });

  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  bool get _isNetwork =>
      source.startsWith('https://') || source.startsWith('http://');

  @override
  Widget build(BuildContext context) {
    if (source.trim().isEmpty) {
      return _fallback(context);
    }

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        width: width,
        height: height,
        errorWidget: (context, url, error) =>
            errorBuilder?.call(context, error) ?? _fallback(context),
      );
    }

    final assetPath = source.startsWith('/') ? source.substring(1) : source;

    return Image.asset(
      assetPath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) =>
          errorBuilder?.call(context, error) ?? _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Turns a relative hosted asset path into a URL usable by url_launcher.
Uri? resolvePortfolioUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final direct = Uri.tryParse(trimmed);
  if (direct == null) {
    return null;
  }

  if (direct.hasScheme) {
    return direct;
  }

  return Uri.base.resolve(
    trimmed.startsWith('/') ? trimmed.substring(1) : trimmed,
  );
}
