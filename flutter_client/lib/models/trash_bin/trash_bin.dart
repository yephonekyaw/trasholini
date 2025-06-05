import 'package:flutter/material.dart';

class TrashBin {
  final String id;
  final String name;
  final String description;
  final Color color;
  final String imagePath; // Changed back to imagePath for local assets
  final bool isSelected;

  TrashBin({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.imagePath, // Updated parameter name
    this.isSelected = false,
  });

  TrashBin copyWith({
    String? id,
    String? name,
    String? description,
    Color? color,
    String? imagePath, // Updated parameter name
    bool? isSelected,
  }) {
    return TrashBin(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath, // Updated field name
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrashBin &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.color == color &&
        other.imagePath == imagePath && // Updated field name
        other.isSelected == isSelected;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        color.hashCode ^
        imagePath.hashCode ^ // Updated field name
        isSelected.hashCode;
  }

  @override
  String toString() {
    return 'TrashBin(id: $id, name: $name, description: $description, color: $color, imagePath: $imagePath, isSelected: $isSelected)'; // Updated field name
  }
}