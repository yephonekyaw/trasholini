import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/services/apis/dio_client.dart';

// Models for API requests and responses
class UserDeletionRequest {
  final String confirmationText;
  final String userEmail;

  const UserDeletionRequest({
    required this.confirmationText,
    required this.userEmail,
  });

  Map<String, dynamic> toJson() {
    return {'confirmation_text': confirmationText, 'user_email': userEmail};
  }
}

class DeletionPreview {
  final String userId;
  final Map<String, int> firestoreCollections;
  final Map<String, int> cloudStorageFolders;
  final int estimatedTotalItems;
  final String? error;

  const DeletionPreview({
    required this.userId,
    required this.firestoreCollections,
    required this.cloudStorageFolders,
    required this.estimatedTotalItems,
    this.error,
  });

  factory DeletionPreview.fromJson(Map<String, dynamic> json) {
    final preview = json['preview'] as Map<String, dynamic>;

    return DeletionPreview(
      userId: preview['user_id'] as String,
      firestoreCollections: Map<String, int>.from(
        preview['firestore_collections'] as Map<String, dynamic>,
      ),
      cloudStorageFolders: Map<String, int>.from(
        preview['cloud_storage_folders'] as Map<String, dynamic>,
      ),
      estimatedTotalItems: preview['estimated_total_items'] as int,
    );
  }
}

class DeletionSummary {
  final int totalDocumentsDeleted;
  final int totalFilesDeleted;
  final String deletionTimestamp;
  final String userId;
  final bool forceDeleteUsed;

  const DeletionSummary({
    required this.totalDocumentsDeleted,
    required this.totalFilesDeleted,
    required this.deletionTimestamp,
    required this.userId,
    required this.forceDeleteUsed,
  });

  factory DeletionSummary.fromJson(Map<String, dynamic> json) {
    return DeletionSummary(
      totalDocumentsDeleted: json['total_documents_deleted'] as int,
      totalFilesDeleted: json['total_files_deleted'] as int,
      deletionTimestamp: json['deletion_timestamp'] as String,
      userId: json['user_id'] as String,
      forceDeleteUsed: json['force_delete_used'] as bool,
    );
  }
}

class UserDeletionResponse {
  final bool success;
  final String message;
  final Map<String, dynamic> deletedItems;
  final List<String> errors;
  final String timestamp;
  final DeletionSummary? summary;

  const UserDeletionResponse({
    required this.success,
    required this.message,
    required this.deletedItems,
    required this.errors,
    required this.timestamp,
    this.summary,
  });

  factory UserDeletionResponse.fromJson(Map<String, dynamic> json) {
    final deletedItems = json['deleted_items'] as Map<String, dynamic>;
    DeletionSummary? summary;

    if (deletedItems.containsKey('summary') &&
        deletedItems['summary'] != null) {
      summary = DeletionSummary.fromJson(
        deletedItems['summary'] as Map<String, dynamic>,
      );
    }

    return UserDeletionResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      deletedItems: deletedItems,
      errors: List<String>.from(json['errors'] as List),
      timestamp: json['timestamp'] as String,
      summary: summary,
    );
  }
}

// Custom exceptions
class DeletionException implements Exception {
  final String message;
  final int? statusCode;

  const DeletionException(this.message, [this.statusCode]);

  @override
  String toString() => 'DeletionException: $message';
}

class DeletionConfirmationException extends DeletionException {
  const DeletionConfirmationException(String message) : super(message, 400);
}

class DeletionVerificationException extends DeletionException {
  const DeletionVerificationException(String message) : super(message, 403);
}

// Main service class
class DangerService {
  static DangerService? _instance;
  final DioClient _dioClient = DioClient();

  DangerService._internal();

  factory DangerService() {
    _instance ??= DangerService._internal();
    return _instance!;
  }

  /// Initialize the service
  Future<void> initialize() async {
    await _dioClient.initialize();
  }

  /// Preview what data would be deleted for the current user
  /// This is a safe operation that doesn't delete anything
  Future<DeletionPreview> previewDeletion() async {
    try {
      debugPrint('DangerService: Getting deletion preview');

      // Ensure DioClient is initialized
      await _dioClient.initialize();

      // Check if user is authenticated
      final isAuthenticated = await _dioClient.isUserAuthenticated();
      if (!isAuthenticated) {
        throw DeletionException(
          'User not authenticated. Please login first.',
          401,
        );
      }

      debugPrint(
        'DangerService: Sending request to /danger/user/deletion-preview',
      );

      // Make API call using DioClient
      final response = await _dioClient.dio.get(
        '/danger/user/deletion-preview',
      );

      debugPrint(
        'DangerService: Received preview response with status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final result = DeletionPreview.fromJson(response.data);

        debugPrint('DangerService: Deletion preview retrieved successfully');
        debugPrint('  - User ID: ${result.userId}');
        debugPrint('  - Total items to delete: ${result.estimatedTotalItems}');
        debugPrint('  - Firestore collections: ${result.firestoreCollections}');
        debugPrint('  - Cloud storage folders: ${result.cloudStorageFolders}');

        return result;
      } else {
        throw DeletionException(
          'Unexpected response status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'DangerService: DioException in previewDeletion: ${e.message}',
      );
      debugPrint('  - Error type: ${e.type}');
      debugPrint('  - Response data: ${e.response?.data}');

      // Handle specific error cases
      if (e.response?.statusCode == 404) {
        throw DeletionException('User not found', 404);
      } else if (e.response?.statusCode == 401) {
        throw DeletionException('Authentication required', 401);
      }

      // Re-throw the exception as it's already handled by DioClient
      rethrow;
    } catch (e) {
      debugPrint('DangerService: Unexpected error in previewDeletion: $e');
      throw DeletionException(
        'Failed to get deletion preview: ${e.toString()}',
      );
    }
  }

  /// ⚠️ DANGER: Permanently delete all user data
  /// This operation cannot be undone!
  ///
  /// [userEmail] - User's email for verification
  /// [forceDelete] - Continue deletion even if some operations fail
  Future<UserDeletionResponse> deleteAllUserData({
    required String userEmail,
    bool forceDelete = false,
  }) async {
    try {
      debugPrint('🚨 DangerService: INITIATING USER DATA DELETION');
      debugPrint('  - User email: $userEmail');
      debugPrint('  - Force delete: $forceDelete');

      // Ensure DioClient is initialized
      await _dioClient.initialize();

      // Check if user is authenticated
      final isAuthenticated = await _dioClient.isUserAuthenticated();
      if (!isAuthenticated) {
        throw DeletionException(
          'User not authenticated. Please login first.',
          401,
        );
      }

      // Create deletion request
      final deletionRequest = UserDeletionRequest(
        confirmationText: 'DELETE',
        userEmail: userEmail,
      );

      debugPrint(
        '🚨 DangerService: Sending deletion request to /danger/user/delete-all-data',
      );

      // Make API call using DioClient
      final response = await _dioClient.dio.delete(
        '/danger/user/delete-all-data',
        data: deletionRequest.toJson(),
        queryParameters: {'force_delete': forceDelete},
      );

      debugPrint(
        '🚨 DangerService: Received deletion response with status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final result = UserDeletionResponse.fromJson(response.data);

        debugPrint('🚨 DangerService: User data deletion completed');
        debugPrint('  - Success: ${result.success}');
        debugPrint(
          '  - Documents deleted: ${result.summary?.totalDocumentsDeleted ?? 0}',
        );
        debugPrint(
          '  - Files deleted: ${result.summary?.totalFilesDeleted ?? 0}',
        );
        debugPrint('  - Errors: ${result.errors.length}');

        return result;
      } else {
        throw DeletionException(
          'Unexpected response status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '🚨 DangerService: DioException in deleteAllUserData: ${e.message}',
      );
      debugPrint('  - Error type: ${e.type}');
      debugPrint('  - Response data: ${e.response?.data}');

      // Handle specific error cases
      if (e.response?.statusCode == 400) {
        final errorDetail = e.response?.data?['detail'] ?? 'Invalid request';
        if (errorDetail.contains('confirmation')) {
          throw DeletionConfirmationException(
            'Confirmation text validation failed',
          );
        }
        throw DeletionException(errorDetail, 400);
      } else if (e.response?.statusCode == 403) {
        throw DeletionVerificationException('Email verification failed');
      } else if (e.response?.statusCode == 404) {
        throw DeletionException('User not found', 404);
      }

      // Re-throw the exception as it's already handled by DioClient
      rethrow;
    } catch (e) {
      debugPrint('🚨 DangerService: Critical error in deleteAllUserData: $e');
      throw DeletionException('Failed to delete user data: ${e.toString()}');
    }
  }

  /// Check if the service is ready to make API calls
  Future<bool> isServiceReady() async {
    try {
      await _dioClient.initialize();
      return await _dioClient.isUserAuthenticated();
    } catch (e) {
      debugPrint('DangerService: Service readiness check failed: $e');
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

  /// Get user email from current session (if available)
  Future<String?> getCurrentUserEmail() async {
    try {
      // This would depend on how you store user information
      // You might need to implement this based on your auth system
      debugPrint('DangerService: Getting current user email');

      // If you store user info in shared preferences or secure storage:
      // return await _getUserEmailFromStorage();

      // For now, return null - implement based on your auth system
      return null;
    } catch (e) {
      debugPrint('DangerService: Error getting current user email: $e');
      return null;
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  /// Generate confirmation text constant
  static String get requiredConfirmationText => 'DELETE';
}
