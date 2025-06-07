class RecommendedBin {
  final String description;
  final String id;
  final String name;

  RecommendedBin({
    required this.description,
    required this.id,
    required this.name,
  });

  factory RecommendedBin.fromJson(Map<String, dynamic> json) {
    return RecommendedBin(
      description: json['description'] ?? '',
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'description': description, 'id': id, 'name': name};
  }
}

class DisposalHistoryItem {
  final String id;
  final double confidence;
  final String disposalTips;
  final String environmentalNote;
  final String imageUrl;
  final String preparationSteps;
  final RecommendedBin? recommendedBin;
  final String savedAt;
  final String userId;
  final String wasteClass;

  DisposalHistoryItem({
    required this.id,
    required this.confidence,
    required this.disposalTips,
    required this.environmentalNote,
    required this.imageUrl,
    required this.preparationSteps,
    this.recommendedBin,
    required this.savedAt,
    required this.userId,
    required this.wasteClass,
  });

  factory DisposalHistoryItem.fromJson(Map<String, dynamic> json) {
    return DisposalHistoryItem(
      id: json['id'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      disposalTips: json['disposal_tips'] ?? '',
      environmentalNote: json['environmental_note'] ?? '',
      imageUrl: json['image_url'] ?? '',
      preparationSteps: json['preparation_steps'] ?? '',
      recommendedBin:
          json['recommended_bin'] != null
              ? RecommendedBin.fromJson(json['recommended_bin'])
              : null,
      savedAt: json['saved_at'] ?? '',
      userId: json['user_id'] ?? '',
      wasteClass: json['waste_class'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'confidence': confidence,
      'disposal_tips': disposalTips,
      'environmental_note': environmentalNote,
      'image_url': imageUrl,
      'preparation_steps': preparationSteps,
      'recommended_bin': recommendedBin?.toJson(),
      'saved_at': savedAt,
      'user_id': userId,
      'waste_class': wasteClass,
    };
  }
}

class DisposalHistoryResponse {
  final bool success;
  final List<DisposalHistoryItem> history;
  final int count;
  final String message;

  DisposalHistoryResponse({
    required this.success,
    required this.history,
    required this.count,
    required this.message,
  });

  factory DisposalHistoryResponse.fromJson(Map<String, dynamic> json) {
    final historyList = json['history'] as List<dynamic>? ?? [];
    final history =
        historyList
            .map(
              (item) =>
                  DisposalHistoryItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();

    return DisposalHistoryResponse(
      success: json['success'] ?? false,
      history: history,
      count: json['count'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'history': history.map((item) => item.toJson()).toList(),
      'count': count,
      'message': message,
    };
  }
}

class WasteClassesResponse {
  final bool success;
  final List<String> wasteClasses;
  final int count;
  final int totalRecords;
  final String message;

  WasteClassesResponse({
    required this.success,
    required this.wasteClasses,
    required this.count,
    required this.totalRecords,
    required this.message,
  });

  factory WasteClassesResponse.fromJson(Map<String, dynamic> json) {
    final classList = json['waste_classes'] as List<dynamic>? ?? [];
    final wasteClasses = classList.cast<String>();

    return WasteClassesResponse(
      success: json['success'] ?? false,
      wasteClasses: wasteClasses,
      count: json['count'] ?? 0,
      totalRecords: json['total_records'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'waste_classes': wasteClasses,
      'count': count,
      'total_records': totalRecords,
      'message': message,
    };
  }
}

class DeleteResponse {
  final bool success;
  final String message;
  final String deletedItemId;

  const DeleteResponse({
    required this.success,
    required this.message,
    required this.deletedItemId,
  });

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      deletedItemId: json['deleted_item_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'deleted_item_id': deletedItemId,
    };
  }

  @override
  String toString() {
    return 'DeleteResponse(success: $success, message: $message, deletedItemId: $deletedItemId)';
  }
}
