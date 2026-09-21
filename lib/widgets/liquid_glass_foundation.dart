import 'package:flutter/material.dart';
import 'package:liquid_glass_kit/liquid_glass_kit.dart' as liquid_glass_kit;

/// Shared Liquid Glass foundation for the public site and admin UI.
///
/// All glass surfaces should use this abstraction so the site's visual
/// language can evolve centrally without rewriting every screen.
class LiquidGlassFoundation extends StatelessWidget {
  const LiquidGlassFoundation({
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.blur,
    this.opacity,
    this.color,
    this.borderColor,
    this.borderWidth,
    this.gradient,
    this.boxShadow,
    super.key,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double? blur;
  final double? opacity;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return liquid_glass_kit.LiquidGlassContainer(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      blur: blur,
      opacity: opacity,
      color: color,
      borderColor: borderColor,
      borderWidth: borderWidth,
      gradient: gradient,
      boxShadow: boxShadow,
      child: child,
    );
  }
}

class LiquidGlassPill extends StatelessWidget {
  const LiquidGlassPill({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return LiquidGlassFoundation(
      padding: padding,
      borderRadius: 999,
      blur: 18,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [Colors.white.withValues(alpha: .16), Colors.white.withValues(alpha: .035)]
            : [Colors.white.withValues(alpha: .72), Colors.white.withValues(alpha: .24)],
      ),
      child: child,
    );
  }
}

class LiquidGlassActionButton extends StatelessWidget {
  const LiquidGlassActionButton({
    required this.onPressed,
    required this.child,
    this.borderRadius = 16,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return liquid_glass_kit.LiquidGlassButton(
      onPressed: onPressed,
      borderRadius: borderRadius,
      child: child,
    );
  }
}

class LiquidGlassIconAction extends StatelessWidget {
  const LiquidGlassIconAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 42,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassFoundation(
      width: size,
      height: size,
      borderRadius: size / 2,
      padding: EdgeInsets.zero,
      blur: 18,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
