class ScanHistory {
  final String id;
  final String material;
  final double weight;
  final DateTime scanDate;
  final double co2Saved;
  final double waterSaved;
  final double treesSaved;
  final int pointsEarned;

  ScanHistory({
    required this.id,
    required this.material,
    required this.weight,
    required this.scanDate,
    required this.co2Saved,
    required this.waterSaved,
    required this.treesSaved,
    required this.pointsEarned,
  });

  // Convert to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'material': material,
      'weight': weight,
      'scanDate': scanDate.toIso8601String(),
      'co2Saved': co2Saved,
      'waterSaved': waterSaved,
      'treesSaved': treesSaved,
      'pointsEarned': pointsEarned,
    };
  }

  // Create from JSON for database retrieval
  factory ScanHistory.fromJson(Map<String, dynamic> json) {
    return ScanHistory(
      id: json['id'],
      material: json['material'],
      weight: json['weight'].toDouble(),
      scanDate: DateTime.parse(json['scanDate']),
      co2Saved: json['co2Saved'].toDouble(),
      waterSaved: json['waterSaved'].toDouble(),
      treesSaved: json['treesSaved'].toDouble(),
      pointsEarned: json['pointsEarned'],
    );
  }

  // Copy with method for updates
  ScanHistory copyWith({
    String? id,
    String? material,
    double? weight,
    DateTime? scanDate,
    double? co2Saved,
    double? waterSaved,
    double? treesSaved,
    int? pointsEarned,
  }) {
    return ScanHistory(
      id: id ?? this.id,
      material: material ?? this.material,
      weight: weight ?? this.weight,
      scanDate: scanDate ?? this.scanDate,
      co2Saved: co2Saved ?? this.co2Saved,
      waterSaved: waterSaved ?? this.waterSaved,
      treesSaved: treesSaved ?? this.treesSaved,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }
}