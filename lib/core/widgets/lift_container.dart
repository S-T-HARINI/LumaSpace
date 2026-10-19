import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LiftContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final double pressedElevation;
  final double defaultElevation;
  final BorderRadius? borderRadius;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableHaptics;

  const LiftContainer({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.97,
    this.pressedElevation = 0.0,
    this.defaultElevation = 0.0,
    this.borderRadius,
    this.color,
    this.border,
    this.padding,
    this.margin,
    this.enableHaptics = true,
  });

  @override
  State<LiftContainer> createState() => _LiftContainerState();
}

class _LiftContainerState extends State<LiftContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 140),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _elevationAnimation = Tween<double>(
      begin: widget.defaultElevation,
      end: widget.pressedElevation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final reduceMotion = mediaQuery.disableAnimations;

    final childWidget = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = reduceMotion ? 1.0 : (_isHovered && !_controller.isAnimating && _controller.value == 0 ? 1.015 : _scaleAnimation.value);
        final elevation = reduceMotion ? widget.defaultElevation : _elevationAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Material(
            color: widget.color ?? Colors.transparent,
            elevation: elevation,
            borderRadius: widget.borderRadius,
            child: Container(
              padding: widget.padding,
              margin: widget.margin,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: widget.border,
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );

    if (widget.onTap == null && widget.onLongPress == null) {
      return childWidget;
    }

    return MouseRegion(
      onEnter: (_) {
        if (mounted && !reduceMotion) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (mounted && !reduceMotion) setState(() => _isHovered = false);
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: childWidget,
      ),
    );
  }
}
