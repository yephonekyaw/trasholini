class EnvironmentalImpact {
  final double treesSaved;
  final double waterSaved;
  final double co2Reduced;

  EnvironmentalImpact({
    required this.treesSaved,
    required this.waterSaved,
    required this.co2Reduced,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'treesSaved': treesSaved,
      'waterSaved': waterSaved,
      'co2Reduced': co2Reduced,
    };
  }

  // Create from JSON
  factory EnvironmentalImpact.fromJson(Map<String, dynamic> json) {
    return EnvironmentalImpact(
      treesSaved: json['treesSaved'].toDouble(),
      waterSaved: json['waterSaved'].toDouble(),
      co2Reduced: json['co2Reduced'].toDouble(),
    );
  }

  // Empty/zero state
  factory EnvironmentalImpact.empty() {
    return EnvironmentalImpact(
      treesSaved: 0.0,
      waterSaved: 0.0,
      co2Reduced: 0.0,
    );
  }

  // Add two impacts together
  EnvironmentalImpact operator +(EnvironmentalImpact other) {
    return EnvironmentalImpact(
      treesSaved: treesSaved + other.treesSaved,
      waterSaved: waterSaved + other.waterSaved,
      co2Reduced: co2Reduced + other.co2Reduced,
    );
  }

  // Copy with method
  EnvironmentalImpact copyWith({
    double? treesSaved,
    double? waterSaved,
    double? co2Reduced,
  }) {
    return EnvironmentalImpact(
      treesSaved: treesSaved ?? this.treesSaved,
      waterSaved: waterSaved ?? this.waterSaved,
      co2Reduced: co2Reduced ?? this.co2Reduced,
    );
  }
}