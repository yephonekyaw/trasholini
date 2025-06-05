import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E8);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color backgroundGray = Color(0xFFF5F5F5);
  
  // Dimensions
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  
  // Animation Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Text Styles
  static const TextStyle headerTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
  
  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    height: 1.4,
  );
  
  static const TextStyle captionTextStyle = TextStyle(
    fontSize: 12,
    color: Colors.black54,
    fontWeight: FontWeight.w500,
  );
}