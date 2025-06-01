// lib/core/utils/category_constants.dart
import 'package:flutter/material.dart';

class CategoryConstants {
  // Category colors mapping
  static final Map<String, Color> _categoryColors = {
    '1': Colors.blue.shade600,      // Plastic
    '2': Colors.brown.shade600,     // Paper
    '3': Colors.purple.shade600,    // Property
    '4': Colors.cyan.shade600,      // Glass
    '5': Colors.grey.shade600,      // E-waste
    '6': Colors.pink.shade600,      // Textile waste
    '7': Colors.orange.shade600,    // Construction
    '8': Colors.red.shade600,       // In-organic
    '9': Colors.green.shade600,     // Organic
    '10': Colors.indigo.shade600,   // Metal
  };

  // Category names mapping
  static final Map<String, String> _categoryNames = {
    '1': 'Plastic',
    '2': 'Paper',
    '3': 'Property',
    '4': 'Glass',
    '5': 'E-waste',
    '6': 'Textile',
    '7': 'Construction',
    '8': 'In-organic',
    '9': 'Organic',
    '10': 'Metal',
  };

  static Color getColor(String categoryId) {
    return _categoryColors[categoryId] ?? Colors.grey.shade600;
  }

  static String getName(String categoryId) {
    return _categoryNames[categoryId] ?? 'Unknown';
  }

  static Map<String, Color> get allColors => Map.unmodifiable(_categoryColors);
  static Map<String, String> get allNames => Map.unmodifiable(_categoryNames);
}