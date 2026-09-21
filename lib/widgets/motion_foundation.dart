import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';
import 'liquid_glass_foundation.dart';

/// Glass + subtle neumorphic interactive surface.
class NeoGlassSurface extends StatefulWidget {
  const NeoGlassSurface({
    required this.child,
    this.padding,
    this.borderRadius = 22,
    this.depth = 10,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double depth;
  final VoidCallback? onTap;

  @override
  State<NeoGlassSurface> createState() => _NeoGlassSurfaceState();
}

class _NeoGlassSurfaceState extends State<NeoGlassSurface> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(widget.borderRadius);

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(
        0,
        _pressed ? 1.5 : 0,
        0,
      ),
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: .45)
                : Colors.black.withValues(alpha: .10),
            blurRadius: widget.depth,
            offset: Offset(widget.depth * .55, widget.depth * .55),
          ),
          BoxShadow(
            color: dark
                ? Colors.white.withValues(alpha: .025)
                : Colors.white.withValues(alpha: .82),
            blurRadius: widget.depth,
            offset: Offset(-widget.depth * .55, -widget.depth * .55),
          ),
        ],
      ),
      child: AnimatedScale(
        scale: _pressed ? .992 : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: LiquidGlassFoundation(
          borderRadius: widget.borderRadius,
          blur: 16,
          padding: EdgeInsets.zero,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: dark
                ? [
                    Colors.white.withValues(alpha: .10),
                    Colors.white.withValues(alpha: .025),
                  ]
                : [
                    Colors.white.withValues(alpha: .62),
                    AppColors.primary.withValues(alpha: .035),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap == null) {
      return content;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: content,
    );
  }
}

/// Fade + slide entrance animation.
class MotionReveal extends StatefulWidget {
  const MotionReveal({
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 650),
    this.offset = const Offset(0, .07),
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  State<MotionReveal> createState() => _MotionRevealState();
}

class _MotionRevealState extends State<MotionReveal>
    with SingleTickerProviderStateMixin {
  bool _started = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: widget.offset,
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) {
      return;
    }

    _started = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }

    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Reveals a widget once it enters the visible viewport.
class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    required this.controller,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 620),
    this.offset = const Offset(0, .045),
    this.threshold = .86,
    super.key,
  });

  final ScrollController controller;
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final double threshold;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  bool _revealed = false;
  bool _scheduled = false;
  bool _revealPending = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (_revealed || _scheduled) {
      return;
    }

    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (!mounted || _revealed) {
      return;
    }

    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _revealed = true);
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final top = renderObject.localToGlobal(Offset.zero).dy;
    final bottom = top + renderObject.size.height;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    final visible =
        top <= viewportHeight * widget.threshold && bottom >= 72;

    if (!visible || _revealPending) {
      return;
    }

    _revealPending = true;
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _revealed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return AnimatedOpacity(
      opacity: _revealed ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _revealed ? Offset.zero : widget.offset,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// Gentle continuous floating animation.
class FloatMotion extends StatefulWidget {
  const FloatMotion({
    required this.child,
    this.distance = 7,
    this.duration = const Duration(milliseconds: 3200),
    this.delay = Duration.zero,
    this.rotate = 0,
    super.key,
  });

  final Widget child;
  final double distance;
  final Duration duration;
  final Duration delay;
  final double rotate;

  @override
  State<FloatMotion> createState() => _FloatMotionState();
}

class _FloatMotionState extends State<FloatMotion>
    with SingleTickerProviderStateMixin {
  bool _started = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started || MediaQuery.disableAnimationsOf(context)) {
      return;
    }

    _started = true;
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final eased = Curves.easeInOut.transform(_controller.value);
        final wave = math.sin(eased * math.pi);
        final offset = -widget.distance / 2 + (wave * widget.distance);
        final rotation = widget.rotate * math.sin(eased * math.pi);

        return Transform.translate(
          offset: Offset(0, offset),
          child: Transform.rotate(
            angle: rotation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Gentle pulsing animation.
class PulseMotion extends StatefulWidget {
  const PulseMotion({
    required this.child,
    this.minScale = .98,
    this.maxScale = 1.04,
    this.duration = const Duration(milliseconds: 1800),
    super.key,
  });

  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;

  @override
  State<PulseMotion> createState() => _PulseMotionState();
}

class _PulseMotionState extends State<PulseMotion>
    with SingleTickerProviderStateMixin {
  bool _started = false;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started || MediaQuery.disableAnimationsOf(context)) {
      return;
    }

    _started = true;
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final scale =
            widget.minScale + ((widget.maxScale - widget.minScale) * t);

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
    );
  }
}

/// Horizontal glass marquee/rail.
///
/// Supports manual touch, mouse and trackpad interaction and, when enabled,
/// automatically loops from end-to-end using duplicated content so the reset
/// is visually continuous.
class HorizontalGlassRail extends StatefulWidget {
  const HorizontalGlassRail({
    required this.children,
    this.gap = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    this.showHint = false,
    this.showArrow = false,
    this.arrowTooltip = 'Scroll right',
    this.autoScroll = false,
    this.autoScrollDuration = const Duration(seconds: 14),
    this.pauseOnHover = false,
    this.pauseOnInteraction = true,
    super.key,
  });

  final List<Widget> children;
  final double gap;
  final EdgeInsetsGeometry padding;
  final bool showHint;
  final bool showArrow;
  final String arrowTooltip;
  final bool autoScroll;
  final Duration autoScrollDuration;
  final bool pauseOnHover;
  final bool pauseOnInteraction;

  @override
  State<HorizontalGlassRail> createState() => _HorizontalGlassRailState();
}

class _HorizontalGlassRailState extends State<HorizontalGlassRail> {
  late final ScrollController _controller;
  final GlobalKey _firstGroupKey = GlobalKey();

  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  double _loopExtent = 0;
  bool _hovering = false;
  bool _interactionPaused = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureLoop();
      _startAutoScroll();
    });
  }

  @override
  void didUpdateWidget(covariant HorizontalGlassRail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.autoScroll != widget.autoScroll ||
        oldWidget.autoScrollDuration != widget.autoScrollDuration ||
        oldWidget.children.length != widget.children.length ||
        oldWidget.gap != widget.gap) {
      _stopAutoScroll();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _measureLoop();
        _startAutoScroll();
      });
    }
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _resumeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _measureLoop() {
    final context = _firstGroupKey.currentContext;
    if (context == null) {
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      _loopExtent = renderObject.size.width + widget.gap;
    }
  }

  bool get _animationsDisabled {
    if (!mounted) {
      return true;
    }

    return MediaQuery.disableAnimationsOf(context);
  }

  bool get _shouldAutoScroll {
    if (!widget.autoScroll || _animationsDisabled) {
      return false;
    }

    if (!_controller.hasClients || _controller.position.maxScrollExtent <= 0) {
      return false;
    }

    if (widget.pauseOnHover && _hovering) {
      return false;
    }

    if (widget.pauseOnInteraction && _interactionPaused) {
      return false;
    }

    return true;
  }

  void _startAutoScroll() {
    _stopAutoScroll();

    if (!widget.autoScroll || _animationsDisabled) {
      return;
    }

    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _tickAutoScroll(),
    );
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _tickAutoScroll() {
    if (!mounted || !_shouldAutoScroll) {
      return;
    }

    if (_loopExtent <= 0) {
      _measureLoop();
    }

    if (!_controller.hasClients || _loopExtent <= 0) {
      return;
    }

    final durationMs = math.max(
      widget.autoScrollDuration.inMilliseconds,
      1,
    );
    final pixelsPerSecond = _loopExtent / (durationMs / 1000);
    final delta = pixelsPerSecond * (16 / 1000);
    final next = _controller.offset + delta;

    if (next >= _loopExtent) {
      final wrapped = next - _loopExtent;
      _controller.jumpTo(
        wrapped.clamp(0.0, _controller.position.maxScrollExtent).toDouble(),
      );
      return;
    }

    _controller.jumpTo(
      next.clamp(0.0, _controller.position.maxScrollExtent).toDouble(),
    );
  }

  void _pauseForInteraction() {
    if (!widget.pauseOnInteraction) {
      return;
    }

    _resumeTimer?.cancel();
    setState(() {
      _interactionPaused = true;
    });
  }

  void _resumeAfterInteraction() {
    if (!widget.pauseOnInteraction) {
      return;
    }

    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _interactionPaused = false;
        });
      }
    });
  }

  Future<void> _scrollNext() async {
    if (!_controller.hasClients) {
      return;
    }

    _pauseForInteraction();

    if (_loopExtent <= 0) {
      _measureLoop();
    }

    final max = _controller.position.maxScrollExtent;
    final target = (_controller.offset + 300).clamp(0.0, max).toDouble();

    await _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 560),
      curve: Curves.easeOutCubic,
    );

    _resumeAfterInteraction();
  }

  List<Widget> _buildGroup({Key? key}) {
    return [
      Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < widget.children.length; i++) ...[
            if (i > 0) SizedBox(width: widget.gap),
            MotionReveal(
              key: ValueKey('rail-${widget.children[i].hashCode}-$i-${key != null}'),
              delay: Duration(milliseconds: i * 55),
              duration: const Duration(milliseconds: 500),
              offset: const Offset(.035, 0),
              child: widget.children[i],
            ),
          ],
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    final rail = Listener(
      onPointerDown: (_) => _pauseForInteraction(),
      onPointerSignal: (_) => _pauseForInteraction(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            _pauseForInteraction();
          } else if (notification is ScrollEndNotification) {
            _resumeAfterInteraction();
          }
          return false;
        },
        child: MouseRegion(
          onEnter: (_) {
            if (widget.pauseOnHover) {
              setState(() => _hovering = true);
            }
          },
          onExit: (_) {
            if (widget.pauseOnHover) {
              setState(() => _hovering = false);
            }
          },
          child: SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: widget.padding,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ..._buildGroup(key: _firstGroupKey),
                SizedBox(width: widget.gap),
                ..._buildGroup(),
              ],
            ),
          ),
        ),
      ),
    );

    return LiquidGlassFoundation(
      borderRadius: 28,
      blur: 18,
      color: dark
          ? Colors.black.withValues(alpha: .16)
          : Colors.white.withValues(alpha: .18),
      borderColor: colors.outlineVariant.withValues(alpha: .46),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [
                Colors.white.withValues(alpha: .08),
                Colors.white.withValues(alpha: .016),
              ]
            : [
                Colors.white.withValues(alpha: .62),
                Colors.white.withValues(alpha: .12),
              ],
      ),
      child: Stack(
        children: [
          rail,
          if (widget.showHint)
            Positioned.fill(
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RailEdgeFade(
                      alignment: Alignment.centerLeft,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    _RailEdgeFade(
                      alignment: Alignment.centerRight,
                      color: Theme.of(context).colorScheme.surface,
                      trailing: true,
                    ),
                  ],
                ),
              ),
            ),
          if (widget.showArrow)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final canScroll = _controller.hasClients &&
                        _controller.offset <
                            _controller.position.maxScrollExtent - 4;
                    return AnimatedOpacity(
                      opacity: canScroll ? 1 : .38,
                      duration: const Duration(milliseconds: 180),
                      child: child,
                    );
                  },
                  child: Tooltip(
                    message: widget.arrowTooltip,
                    child: LiquidGlassIconAction(
                      size: 42,
                      icon: Icons.chevron_right_rounded,
                      onPressed: _scrollNext,
                      tooltip: widget.arrowTooltip,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RailEdgeFade extends StatelessWidget {
  const _RailEdgeFade({
    required this.alignment,
    required this.color,
    this.trailing = false,
  });

  final Alignment alignment;
  final Color color;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: trailing ? 46 : 30,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: trailing ? Alignment.centerRight : Alignment.centerLeft,
            end: trailing ? Alignment.centerLeft : Alignment.centerRight,
            colors: [
              color.withValues(alpha: .88),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
