class CategoryItemModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> category; // 🔧 CHANGED: from categoryId to category array
  final String disposalTip;

  CategoryItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category, // 🔧 CHANGED: Now an array
    required this.disposalTip,
  });

  /// 🔧 UPDATED: Handle category array from backend
  factory CategoryItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      // 🔧 CHANGED: Parse category array
      category: _parseCategoryArray(json['category']),
      disposalTip: json['disposal_tip']?.toString() ?? '',
    );
  }

  /// 🔧 NEW: Helper method to parse category array safely
  static List<String> _parseCategoryArray(dynamic categoryData) {
    if (categoryData == null) return [];
    
    if (categoryData is List) {
      return categoryData.map((e) => e.toString()).toList();
    } else if (categoryData is String) {
      // Handle single category as array for backward compatibility
      return [categoryData];
    } else {
      return [];
    }
  }

  /// 🔧 UPDATED: Include category array in JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category, // 🔧 CHANGED: Send as array
      'disposal_tip': disposalTip,
    };
  }

  /// 🔧 NEW: Check if item belongs to a specific category
  bool belongsToCategory(String categoryId) {
    return category.contains(categoryId);
  }

  /// 🔧 NEW: Get primary category (first in array)
  String get primaryCategory => category.isNotEmpty ? category.first : '';

  /// 🔧 NEW: Check if item belongs to multiple categories
  bool get isMultiCategory => category.length > 1;

  /// 🔧 UPDATED: Include category array in copyWith
  CategoryItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? category, // 🔧 CHANGED: Now array
    String? disposalTip,
  }) {
    return CategoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category, // 🔧 CHANGED
      disposalTip: disposalTip ?? this.disposalTip,
    );
  }

  @override
  String toString() {
    return 'CategoryItemModel(id: $id, name: $name, categories: $category)';
  }
}