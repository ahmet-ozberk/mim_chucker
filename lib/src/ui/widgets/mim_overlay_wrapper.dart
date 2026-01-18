import 'package:flutter/material.dart';

/// Wrapper widget for MimChucker overlay animations
class MimOverlayWrapper extends StatefulWidget {
  /// The child widget (MimChucker UI)
  final Widget child;

  /// Callback when dismissal animation completes
  final VoidCallback onDismissed;

  /// Constructor
  const MimOverlayWrapper({
    super.key,
    required this.child,
    required this.onDismissed,
  });

  @override
  MimOverlayWrapperState createState() => MimOverlayWrapperState();
}

class MimOverlayWrapperState extends State<MimOverlayWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Duration for bounce
      reverseDuration: const Duration(milliseconds: 100), // Fast close
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // Bounce effect on open
      reverseCurve: Curves.easeIn, // Smooth fast close
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();
  }

  /// Trigger the exit animation and then call callback
  Future<void> animateOut() async {
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
