import 'package:flutter/material.dart';

/// Renders a bundled PNG icon with an optional Material fallback.
class QashIcon extends StatelessWidget {
  final String? assetPath;
  final IconData? fallback;
  final double size;
  final BoxFit fit;
  final Color? color;

  const QashIcon({
    super.key,
    this.assetPath,
    this.fallback,
    this.size = 24,
    this.fit = BoxFit.contain,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
      );
    }
    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    if (fallback == null) {
      return SizedBox(width: size, height: size);
    }
    return Icon(fallback, size: size, color: color);
  }
}
