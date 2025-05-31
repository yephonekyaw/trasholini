class WasteCategory {
  final String id;
  final String name;
  final String imageUrl;
  final String description;

  const WasteCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  // Create from JSON from Firebase
  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    return WasteCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
    );
  }
}