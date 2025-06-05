class WasteBin {
  final String id;
  final String name;
  final String colorHex;
  final String type;
  final String imageUrl;

  const WasteBin({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.type,
    required this.imageUrl,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'type': type,
      'imageUrl': imageUrl,
    };
  }

  // Create from JSON from Firebase
  factory WasteBin.fromJson(Map<String, dynamic> json) {
    return WasteBin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      colorHex: json['colorHex'] ?? '#4CAF50',
      type: json['type'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}