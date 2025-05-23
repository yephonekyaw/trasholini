import 'package:flutter/material.dart';
import 'lost_recycle_bin.dart';
import 'broken_recycle_bin.dart';

class AnimatedErrorWidget extends StatefulWidget {
  final bool isNotFound;

  const AnimatedErrorWidget({super.key, required this.isNotFound});

  @override
  State<AnimatedErrorWidget> createState() => _AnimatedErrorWidgetState();
}

class _AnimatedErrorWidgetState extends State<AnimatedErrorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child:
                widget.isNotFound
                    ? const LostRecycleBin()
                    : const BrokenRecycleBin(),
          ),
        );
      },
    );
  }
}
