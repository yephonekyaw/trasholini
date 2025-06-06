import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/presentations/scan/disposal_instruction_page.dart';
import 'package:flutter_client/services/apis/dio_client.dart';

// Models for the API response
class RecommendedBin {
  final String id;
  final String name;
  final String description;

  RecommendedBin({
    required this.id,
    required this.name,
    required this.description,
  });

  factory RecommendedBin.fromJson(Map<String, dynamic> json) {
    return RecommendedBin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

// Update the WasteAnalysisResult model in waste_analysis_service.dart
class WasteAnalysisResult {
  final bool success;
  final String wasteClass;
  final double confidence;
  final String disposalTips;
  final String preparationSteps; // New field
  final String environmentalNote; // New field
  final RecommendedBin? recommendedBin;
  final String message;

  WasteAnalysisResult({
    required this.success,
    required this.wasteClass,
    required this.confidence,
    required this.disposalTips,
    required this.preparationSteps,
    required this.environmentalNote,
    this.recommendedBin,
    required this.message,
  });

  factory WasteAnalysisResult.fromJson(Map<String, dynamic> json) {
    return WasteAnalysisResult(
      success: json['success'] ?? false,
      wasteClass: json['waste_class'] ?? 'unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      disposalTips: json['disposal_tips'] ?? '',
      preparationSteps: json['preparation_steps'] ?? '', // New field
      environmentalNote: json['environmental_note'] ?? '', // New field
      recommendedBin:
          json['recommended_bin'] != null && json['recommended_bin'].isNotEmpty
              ? RecommendedBin.fromJson(json['recommended_bin'])
              : null,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'waste_class': wasteClass,
      'confidence': confidence,
      'disposal_tips': disposalTips,
      'preparation_steps': preparationSteps,
      'environmental_note': environmentalNote,
      'recommended_bin': recommendedBin?.toJson(),
      'message': message,
    };
  }
}

class WasteAnalysisService {
  static WasteAnalysisService? _instance;
  final DioClient _dioClient = DioClient();

  WasteAnalysisService._internal();

  factory WasteAnalysisService() {
    _instance ??= WasteAnalysisService._internal();
    return _instance!;
  }

  /// Initialize the service
  Future<void> initialize() async {
    await _dioClient.initialize();
  }

  /// Analyze waste item from image file path
  Future<WasteAnalysisResult> analyzeWaste(String imagePath) async {
    try {
      debugPrint(
        'WasteAnalysisService: Starting waste analysis for: $imagePath',
      );

      // Ensure DioClient is initialized
      await _dioClient.initialize();

      // Check if user is authenticated
      final isAuthenticated = await _dioClient.isUserAuthenticated();
      if (!isAuthenticated) {
        throw UnauthorizedException(
          'User not authenticated. Please login first.',
        );
      }

      // Verify image file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        throw BadRequestException('Image file not found at path: $imagePath');
      }

      // Get file info for logging
      final fileSize = await file.length();
      debugPrint(
        'WasteAnalysisService: Image file size: ${fileSize / 1024} KB',
      );

      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      debugPrint(
        'WasteAnalysisService: Sending request to /scan/analyze-upload',
      );

      // Make API call using DioClient
      final response = await _dioClient.dio.post(
        '/scan/analyze-upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      debugPrint(
        'WasteAnalysisService: Received response with status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final result = WasteAnalysisResult.fromJson(response.data);

        debugPrint('WasteAnalysisService: Analysis successful');
        debugPrint('  - Detected class: ${result.wasteClass}');
        debugPrint('  - Confidence: ${result.confidence}');
        debugPrint(
          '  - Recommended bin: ${result.recommendedBin?.name ?? 'None'}',
        );

        return result;
      } else {
        throw ServerException(
          'Unexpected response status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('WasteAnalysisService: DioException occurred: ${e.message}');
      debugPrint('  - Error type: ${e.type}');
      debugPrint('  - Response data: ${e.response?.data}');

      // Re-throw the exception as it's already handled by DioClient
      rethrow;
    } catch (e) {
      debugPrint('WasteAnalysisService: Unexpected error: $e');
      throw ApiException('Failed to analyze waste: ${e.toString()}');
    }
  }

  /// Save disposal tips to user's history
  Future<Map<String, dynamic>> saveTips({
    required String imagePath,
    required WasteAnalysisResult result,
  }) async {
    try {
      debugPrint('WasteAnalysisService: Saving disposal tips for: $imagePath');

      // Ensure DioClient is initialized
      await _dioClient.initialize();

      // Check if user is authenticated
      final isAuthenticated = await _dioClient.isUserAuthenticated();
      if (!isAuthenticated) {
        throw UnauthorizedException(
          'User not authenticated. Please login first.',
        );
      }

      // Verify image file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        throw BadRequestException('Image file not found at path: $imagePath');
      }

      final parsedTips = ParsedDisposalTips.fromRawTips(result.disposalTips);

      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        'waste_class': result.wasteClass,
        'confidence': result.confidence.toString(),
        'disposal_tips': parsedTips.disposalTips,
        'preparation_steps': parsedTips.preparationSteps,
        'environmental_note': parsedTips.environmentalNote,
        'message': result.message,
        if (result.recommendedBin != null) ...{
          'recommended_bin_id': result.recommendedBin!.id,
          'recommended_bin_name': result.recommendedBin!.name,
          'recommended_bin_description': result.recommendedBin!.description,
        },
      });

      debugPrint('WasteAnalysisService: Sending save tips request');

      // Make API call using DioClient
      final response = await _dioClient.dio.post(
        '/scan/save-tips',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      debugPrint(
        'WasteAnalysisService: Save tips response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        debugPrint('WasteAnalysisService: Tips saved successfully');
        debugPrint('  - Disposal ID: ${response.data['disposal_id']}');
        debugPrint(
          '  - Eco points earned: ${response.data['eco_points_earned']}',
        );

        return {
          'success': true,
          'message': response.data['message'] ?? 'Tips saved successfully!',
          'disposal_id': response.data['disposal_id'],
          'eco_points_earned': response.data['eco_points_earned'] ?? 0,
          'saved_at': response.data['saved_at'],
        };
      } else {
        throw ServerException(
          'Unexpected response status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'WasteAnalysisService: DioException in saveTips: ${e.message}',
      );
      debugPrint('  - Error type: ${e.type}');
      debugPrint('  - Response data: ${e.response?.data}');

      // Re-throw the exception as it's already handled by DioClient
      rethrow;
    } catch (e) {
      debugPrint('WasteAnalysisService: Unexpected error in saveTips: $e');
      throw ApiException('Failed to save tips: ${e.toString()}');
    }
  }

  /// Get user's disposal history
  Future<List<Map<String, dynamic>>> getDisposalHistory({
    int limit = 20,
  }) async {
    try {
      debugPrint('WasteAnalysisService: Getting disposal history');

      // Ensure DioClient is initialized
      await _dioClient.initialize();

      // Check if user is authenticated
      final isAuthenticated = await _dioClient.isUserAuthenticated();
      if (!isAuthenticated) {
        throw UnauthorizedException(
          'User not authenticated. Please login first.',
        );
      }

      // Make API call using DioClient
      final response = await _dioClient.dio.get(
        '/scan/disposal-history',
        queryParameters: {'limit': limit},
      );

      debugPrint(
        'WasteAnalysisService: History response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final history = List<Map<String, dynamic>>.from(data['history'] ?? []);

        debugPrint(
          'WasteAnalysisService: Retrieved ${history.length} history records',
        );

        return history;
      } else {
        throw ServerException(
          'Unexpected response status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'WasteAnalysisService: DioException in getDisposalHistory: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint(
        'WasteAnalysisService: Unexpected error in getDisposalHistory: $e',
      );
      throw ApiException('Failed to get disposal history: ${e.toString()}');
    }
  }

  /// Check if the service is ready to make API calls
  Future<bool> isServiceReady() async {
    try {
      await _dioClient.initialize();
      return await _dioClient.isUserAuthenticated();
    } catch (e) {
      debugPrint('WasteAnalysisService: Service readiness check failed: $e');
      return false;
    }
  }

  /// Get current user ID (useful for debugging)
  Future<String?> getCurrentUserId() async {
    return await _dioClient.getCurrentUserId();
  }

  /// Refresh user authentication
  Future<void> refreshAuth() async {
    await _dioClient.refreshUserAuth();
  }
}
