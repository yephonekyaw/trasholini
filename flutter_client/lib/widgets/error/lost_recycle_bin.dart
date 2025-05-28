import 'package:flutter/material.dart';
import 'dart:math' as math;

class LostRecycleBin extends StatelessWidget {
  const LostRecycleBin({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Question marks floating around
        ..._buildFloatingQuestionMarks(),

        // Main recycle bin
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.shade300,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.shade200.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Bin lid
              Positioned(
                top: -10,
                left: 10,
                right: 10,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              // Recycle symbol
              Center(
                child: Icon(
                  Icons.recycling,
                  size: 60,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFloatingQuestionMarks() {
    return List.generate(3, (index) {
      final angle = (index * 120) * math.pi / 180;
      final radius = 80.0;
      return Positioned(
        left: 60 + radius * math.cos(angle) - 15,
        top: 60 + radius * math.sin(angle) - 15,
        child: Text(
          '?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade400.withValues(alpha: 0.6),
          ),
        ),
      );
    });
  }
}
