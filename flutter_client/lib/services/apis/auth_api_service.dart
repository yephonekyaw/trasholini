import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_client/models/user_profile_data_model.dart';
import 'package:flutter_client/services/apis/dio_client.dart';

class AuthApiService {
  final DioClient _dioClient = DioClient();

  Future<UserProfile> authenticateUser({
    required String googleId,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      await _dioClient.initialize();
      log('Authenticating user with Google ID: $googleId, Email: $email');
      final response = await _dioClient.dio.post(
        '/auth/signin',
        data: {
          'google_id': googleId,
          'email': email,
          'display_name': displayName,
          'photo_url': photoUrl,
        },
      );
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error ??
          ApiException('Unknown error occurred during authentication');
    }
  }
}
