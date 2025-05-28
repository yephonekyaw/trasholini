import 'package:flutter/material.dart';

class BrokenRecycleBin extends StatelessWidget {
  const BrokenRecycleBin({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main recycle bin (tilted)
        Transform.rotate(
          angle: 0.3,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.orange.shade300,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Warning symbol
                Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Crack effect
        Positioned(
          top: 20,
          child: CustomPaint(
            size: const Size(120, 120),
            painter: _CrackPainter(),
          ),
        ),
      ],
    );
  }
}

class _CrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.orange.shade700
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final path =
        Path()
          ..moveTo(size.width * 0.3, size.height * 0.2)
          ..lineTo(size.width * 0.4, size.height * 0.4)
          ..lineTo(size.width * 0.35, size.height * 0.6)
          ..lineTo(size.width * 0.45, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
