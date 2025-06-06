import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/services/apis/dio_client.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';

class ProfileUpdateRequest {
  final String? displayName;
  final String? imagePath;

  ProfileUpdateRequest({this.displayName, this.imagePath});
}

class ProfileUpdateResponse {
  final bool success;
  final String message;
  final UserProfile userProfile;

  ProfileUpdateResponse({
    required this.success,
    required this.message,
    required this.userProfile,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      userProfile: UserProfile.fromJson(json['user_profile']),
    );
  }
}

class ProfileApiService {
  static ProfileApiService? _instance;
  final DioClient _dioClient = DioClient();

  ProfileApiService._internal();

  factory ProfileApiService() {
    _instance ??= ProfileApiService._internal();
    return _instance!;
  }

  /// Initialize the service
  Future<void> initialize() async {
    await _dioClient.initialize();
  }

  /// Update user profile with new display name and/or profile image
  Future<ProfileUpdateResponse> updateProfile({
    String? displayName,
    String? imagePath,
  }) async {
    try {
      debugPrint('ProfileApiService: Starting profile update');
      debugPrint('  - Display name: ${displayName ?? 'No change'}');
      debugPrint('  - Image path: ${imagePath ?? 'No change'}');

      // Ensure DioClient is initialized
      await _dioClient.initialize();

      // Check if user is authenticated
      final isAuthenticated = await _dioClient.isUserAuthenticated();
      if (!isAuthenticated) {
        throw UnauthorizedException(
          'User not authenticated. Please login first.',
        );
      }

      // Create FormData for multipart upload
      final formData = FormData();

      // Add display name if provided
      if (displayName != null && displayName.trim().isNotEmpty) {
        formData.fields.add(MapEntry('display_name', displayName.trim()));
      }

      // Add profile image if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          final fileSize = await file.length();
          debugPrint(
            'ProfileApiService: Image file size: ${fileSize / 1024} KB',
          );

          formData.files.add(
            MapEntry(
              'profile_image',
              await MultipartFile.fromFile(
                imagePath,
                filename: imagePath.split('/').last,
              ),
            ),
          );
        } else {
          throw BadRequestException('Image file not found at path: $imagePath');
        }
      }

      // Check if there's any data to update
      if (formData.fields.isEmpty && formData.files.isEmpty) {
        throw BadRequestException('No data provided for update');
      }

      debugPrint('ProfileApiService: Sending request to /profile/update');

      // Make API call using DioClient
      final response = await _dioClient.dio.put(
        '/profile/update',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      debugPrint(
        'ProfileApiService: Received response with status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final result = ProfileUpdateResponse.fromJson(response.data);

        debugPrint('ProfileApiService: Profile update successful');
        debugPrint('  - Message: ${result.message}');

        return result;
      } else {
        throw ServerException(
          'Unexpected response status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('ProfileApiService: DioException occurred: ${e.message}');
      debugPrint('  - Error type: ${e.type}');
      debugPrint('  - Response data: ${e.response?.data}');

      // Re-throw the exception as it's already handled by DioClient
      rethrow;
    } catch (e) {
      debugPrint('ProfileApiService: Unexpected error: $e');
      throw ApiException('Failed to update profile: ${e.toString()}');
    }
  }

  /// Get current user profile
  Future<UserProfile> getCurrentProfile() async {
    try {
      debugPrint('ProfileApiService: Getting current profile');

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
      final response = await _dioClient.dio.get('/profile/me');

      debugPrint(
        'ProfileApiService: Received profile response with status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final profileData = response.data['user_profile'];
        final profile = UserProfile.fromJson(profileData);

        debugPrint('ProfileApiService: Profile retrieved successfully');
        return profile;
      } else {
        throw ServerException(
          'Unexpected response status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'ProfileApiService: DioException in getCurrentProfile: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint(
        'ProfileApiService: Unexpected error in getCurrentProfile: $e',
      );
      throw ApiException('Failed to get profile: ${e.toString()}');
    }
  }

  /// Check if the service is ready to make API calls
  Future<bool> isServiceReady() async {
    try {
      await _dioClient.initialize();
      return await _dioClient.isUserAuthenticated();
    } catch (e) {
      debugPrint('ProfileApiService: Service readiness check failed: $e');
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

// Custom exception classes (assuming they're defined in dio_client.dart)
class ProfileUpdateException implements Exception {
  final String message;

  ProfileUpdateException(this.message);

  @override
  String toString() => 'ProfileUpdateException: $message';
}
