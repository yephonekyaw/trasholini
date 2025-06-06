import 'package:flutter/material.dart';

class TrashBin {
  final String id;
  final String name;
  final String description;
  final Color color;
  final String imagePath;
  final bool isSelected;

  const TrashBin({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.imagePath,
    this.isSelected = false,
  });

  /// Create a copy of this TrashBin with optional parameter overrides
  TrashBin copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    String? imagePath,
    bool? isSelected,
  }) {
    return TrashBin(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Convert TrashBin to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color':
          '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}', // Convert Color to hex string
      'image_path': imagePath,
      'is_selected': isSelected,
    };
  }

  /// Create TrashBin from JSON response
  factory TrashBin.fromJson(Map<String, dynamic> json) {
    return TrashBin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: _colorFromHex(json['color'] ?? '#FF000000'),
      imagePath: json['image_path'] ?? '',
      isSelected: json['is_selected'] ?? false,
    );
  }

  /// Helper method to convert hex string to Color
  static Color _colorFromHex(String hexString) {
    try {
      // Remove # if present
      final hex = hexString.replaceFirst('#', '');

      // Handle different hex formats
      if (hex.length == 6) {
        // Add alpha channel if not present
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        // Full ARGB format
        return Color(int.parse(hex, radix: 16));
      } else {
        // Default color if parsing fails
        return Colors.grey;
      }
    } catch (e) {
      debugPrint('Error parsing color from hex: $hexString, error: $e');
      return Colors.grey;
    }
  }

  /// Convert color to hex string (useful for debugging)
  String get colorHex {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// Check if this bin is valid (has required fields)
  bool get isValid {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        description.isNotEmpty &&
        imagePath.isNotEmpty;
  }

  /// Create a copy with selection toggled
  TrashBin toggleSelection() {
    return copyWith(isSelected: !isSelected);
  }

  /// Create a copy with selection set to true
  TrashBin select() {
    return copyWith(isSelected: true);
  }

  /// Create a copy with selection set to false
  TrashBin deselect() {
    return copyWith(isSelected: false);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrashBin &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.color == color &&
        other.imagePath == imagePath &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, color, imagePath, isSelected);
  }

  @override
  String toString() {
    return 'TrashBin('
        'id: $id, '
        'name: $name, '
        'description: $description, '
        'color: $colorHex, '
        'imagePath: $imagePath, '
        'isSelected: $isSelected'
        ')';
  }

  /// Create a formatted string for debugging
  String toDebugString() {
    return '''
TrashBin {
  id: $id
  name: $name
  description: $description
  color: $colorHex (${color.toString()})
  imagePath: $imagePath
  isSelected: $isSelected
  isValid: $isValid
}''';
  }
}

/// Extension methods for TrashBin lists
extension TrashBinListExtensions on List<TrashBin> {
  /// Get all selected bins
  List<TrashBin> get selected => where((bin) => bin.isSelected).toList();

  /// Get all unselected bins
  List<TrashBin> get unselected => where((bin) => !bin.isSelected).toList();

  /// Get bin IDs as a list
  List<String> get ids => map((bin) => bin.id).toList();

  /// Get selected bin IDs as a list
  List<String> get selectedIds => selected.map((bin) => bin.id).toList();

  /// Check if all bins are selected
  bool get allSelected => isNotEmpty && every((bin) => bin.isSelected);

  /// Check if no bins are selected
  bool get noneSelected => every((bin) => !bin.isSelected);

  /// Get selection count
  int get selectedCount => selected.length;

  /// Find bin by ID
  TrashBin? findById(String id) {
    try {
      return firstWhere((bin) => bin.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Toggle selection for a specific bin ID
  List<TrashBin> toggleSelection(String binId) {
    return map((bin) {
      if (bin.id == binId) {
        return bin.toggleSelection();
      }
      return bin;
    }).toList();
  }

  /// Select all bins
  List<TrashBin> selectAll() {
    return map((bin) => bin.select()).toList();
  }

  /// Deselect all bins
  List<TrashBin> deselectAll() {
    return map((bin) => bin.deselect()).toList();
  }

  /// Update selection based on a list of bin IDs
  List<TrashBin> updateSelection(List<String> selectedIds) {
    return map((bin) {
      return bin.copyWith(isSelected: selectedIds.contains(bin.id));
    }).toList();
  }
}
