import 'dart:math';
import 'package:flutter/material.dart';

class StaticWasteIcon extends StatelessWidget {
  final Size screenSize;
  final int gridIndex;

  const StaticWasteIcon({
    super.key,
    required this.screenSize,
    required this.gridIndex,
  });

  // Expanded waste-related icons including food waste
  static const List<IconData> _wasteIcons = [
    // General waste
    Icons.delete_outline,
    Icons.recycling,
    Icons.eco,

    // Plastic & containers
    Icons.water_drop_outlined,
    Icons.local_drink_outlined,
    Icons.coffee_outlined,
    Icons.shopping_bag_outlined,
    Icons.store_outlined,

    // Electronics
    Icons.battery_5_bar_outlined,
    Icons.lightbulb_outline,
    Icons.smartphone_outlined,
    Icons.computer_outlined,
    Icons.tv_outlined,
    Icons.headphones_outlined,

    // Food waste
    Icons.restaurant_outlined,
    Icons.local_pizza_outlined,
    Icons.lunch_dining_outlined,
    Icons.breakfast_dining_outlined,
    Icons.dinner_dining_outlined,
    Icons.bakery_dining_outlined,
    Icons.local_cafe_outlined,
    Icons.emoji_food_beverage_outlined,
    Icons.kitchen_outlined,

    // Transportation & automotive
    Icons.directions_car_outlined,
    Icons.motorcycle_outlined,
    Icons.local_gas_station_outlined,
    Icons.build_outlined,

    // Clothing & textiles
    Icons.checkroom_outlined,
    Icons.dry_cleaning_outlined,

    // Paper & cardboard
    Icons.description_outlined,
    Icons.book_outlined,
    Icons.newspaper_outlined,

    // Glass & ceramics
    Icons.wine_bar_outlined,
    Icons.local_bar_outlined,

    // Hazardous materials
    Icons.local_pharmacy_outlined,
    Icons.science_outlined,
    Icons.cleaning_services_outlined,

    // Garden waste
    Icons.grass_outlined,
    Icons.park_outlined,
    Icons.energy_savings_leaf_outlined,
  ];

  static const List<Color> _iconColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.teal,
    Colors.purple,
    Colors.indigo,
    Colors.brown,
    Colors.red,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
  ];

  @override
  Widget build(BuildContext context) {
    final random = Random(
      gridIndex,
    ); // Use gridIndex as seed for consistent randomness
    final icon = _wasteIcons[random.nextInt(_wasteIcons.length)];
    final color = _iconColors[random.nextInt(_iconColors.length)];
    final size = 35.0 + (random.nextDouble() * 15); // Size 35-50

    // Create a grid layout with fixed positions
    final gridPositions = _getGridPositions(screenSize);
    final position = gridPositions[gridIndex % gridPositions.length];

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Icon(
        icon,
        size: size,
        color: color.withValues(alpha: .15), // Consistent opacity
      ),
    );
  }

  /// Generate fixed grid positions that avoid the center content area
  List<Offset> _getGridPositions(Size screenSize) {
    final List<Offset> positions = [];
    final centerY = screenSize.height / 2;

    // Top area positions (6 icons)
    positions.addAll([
      Offset(screenSize.width * 0.1, screenSize.height * 0.1),
      Offset(screenSize.width * 0.3, screenSize.height * 0.08),
      Offset(screenSize.width * 0.7, screenSize.height * 0.12),
      Offset(screenSize.width * 0.9, screenSize.height * 0.15),
      Offset(screenSize.width * 0.15, screenSize.height * 0.25),
      Offset(screenSize.width * 0.85, screenSize.height * 0.28),
    ]);

    // Left side positions (3 icons) - avoiding center content
    positions.addAll([
      Offset(screenSize.width * 0.05, centerY - 150),
      Offset(screenSize.width * 0.4, centerY - 150),
      Offset(screenSize.width * 0.6, centerY - 160),
    ]);

    // Right side positions (3 icons) - avoiding center content
    positions.addAll([
      Offset(screenSize.width * 0.95, centerY - 180),
      Offset(screenSize.width * 0.92, centerY - 50),
      Offset(screenSize.width * 0.88, centerY + 100),
    ]);

    // Bottom area positions (3 icons)
    positions.addAll([
      Offset(screenSize.width * 0.2, screenSize.height * 0.85),
      Offset(screenSize.width * 0.8, screenSize.height * 0.88),
      Offset(screenSize.width * 0.1, screenSize.height * 0.92),
    ]);

    return positions;
  }
}
