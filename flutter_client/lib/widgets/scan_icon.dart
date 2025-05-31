import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ScanIcon extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const ScanIcon({
    Key? key,
    this.size = 100.0,
    this.backgroundColor = AppConstants.primaryGreen,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        Icons.camera_alt_outlined,
        color: iconColor,
        size: size * 0.4,
      ),
    );
  }
}