class MaterialImpactCalculator {
  // Calculate environmental impact for a given material and weight
  static Map<String, dynamic> calculateImpact(String material, double weightKg) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return {
          'co2Saved': weightKg * 1.75, // 1.75kg CO2 per kg plastic
          'waterSaved': weightKg * 17.5, // 17.5L per kg plastic
          'treesSaved': 0.0, // Plastic doesn't directly save trees
          'points': (weightKg * 1000 * 2.67).round(), // Points calculation
        };
      case 'paper':
        return {
          'co2Saved': weightKg * 1.0, // 1kg CO2 per kg paper
          'waterSaved': weightKg * 22.5, // 22.5L per kg paper
          'treesSaved': weightKg * 0.017, // 0.017 trees per kg paper
          'points': (weightKg * 1000 * 2.0).round(),
        };
      case 'glass':
        return {
          'co2Saved': weightKg * 0.4, // 0.4kg CO2 per kg glass
          'waterSaved': weightKg * 12.0, // 12L per kg glass
          'treesSaved': 0.0,
          'points': (weightKg * 1000 * 1.5).round(),
        };
      case 'metal':
      case 'aluminum':
        return {
          'co2Saved': weightKg * 5.0, // 5kg CO2 per kg metal
          'waterSaved': weightKg * 35.0, // 35L per kg metal
          'treesSaved': 0.0,
          'points': (weightKg * 1000 * 4.0).round(),
        };
      case 'cardboard':
        return {
          'co2Saved': weightKg * 0.8, // 0.8kg CO2 per kg cardboard
          'waterSaved': weightKg * 20.0, // 20L per kg cardboard
          'treesSaved': weightKg * 0.014, // 0.014 trees per kg cardboard
          'points': (weightKg * 1000 * 1.8).round(),
        };
      default:
        return {
          'co2Saved': weightKg * 0.5, // Default values for unknown materials
          'waterSaved': weightKg * 10.0,
          'treesSaved': 0.0,
          'points': (weightKg * 1000 * 1.0).round(),
        };
    }
  }

  // Get average weight for common items (for estimation)
  static double getAverageWeight(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'plastic_bottle':
        return 0.03; // 30g
      case 'paper_sheet':
        return 0.005; // 5g
      case 'aluminum_can':
        return 0.015; // 15g
      case 'glass_bottle':
        return 0.4; // 400g
      case 'cardboard_box':
        return 0.2; // 200g
      case 'newspaper':
        return 0.1; // 100g
      default:
        return 0.05; // 50g default
    }
  }

  // Get material type from item name (for scanner integration)
  static String getMaterialType(String itemName) {
    String lowerName = itemName.toLowerCase();
    
    if (lowerName.contains('bottle') && lowerName.contains('plastic')) {
      return 'plastic';
    } else if (lowerName.contains('bottle') && lowerName.contains('glass')) {
      return 'glass';
    } else if (lowerName.contains('can') || lowerName.contains('aluminum')) {
      return 'metal';
    } else if (lowerName.contains('paper') || lowerName.contains('document')) {
      return 'paper';
    } else if (lowerName.contains('cardboard') || lowerName.contains('box')) {
      return 'cardboard';
    } else {
      return 'unknown';
    }
  }

  // Calculate total impact from multiple scans
  static Map<String, dynamic> calculateTotalImpact(List<Map<String, dynamic>> impacts) {
    double totalCO2 = 0;
    double totalWater = 0;
    double totalTrees = 0;
    double totalPoints = 0;

    for (var impact in impacts) {
      totalCO2 += impact['co2Saved'] ?? 0;
      totalWater += impact['waterSaved'] ?? 0;
      totalTrees += impact['treesSaved'] ?? 0;
      totalPoints += (impact['points'] ?? 0);
    }

    return {
      'co2Saved': totalCO2,
      'waterSaved': totalWater,
      'treesSaved': totalTrees,
      'points': totalPoints,
    };
  }
}