import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/services/token_storage_service.dart';

class DioClient {
  static DioClient? _instance;
  Dio? _dio;
  bool _isInitialized = false;
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Manual IP configuration - change this to your server IP
  static const String _baseUrl = 'http://10.4.150.200:8000/api/v1';

  DioClient._internal();

  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  // Get dio instance
  Dio get dio {
    if (_dio == null) {
      throw Exception('DioClient not initialized. Call initialize() first.');
    }
    return _dio!;
  }

  // Simple initialization - can be called multiple times safely
  Future<void> initialize() async {
    if (_isInitialized) {
      return; // Already initialized, skip
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    await _addInterceptors();
    _isInitialized = true;
  }

  // Reset and re-initialize (useful for changing IP)
  Future<void> reset() async {
    _dio?.close();
    _dio = null;
    _isInitialized = false;
    await initialize();
  }

  // Add interceptors
  Future<void> _addInterceptors() async {
    if (_dio == null) return;

    // Add log interceptor for debugging
    _dio!.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );

    // Add custom interceptor for auth and automatic user ID injection
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Always try to add user ID to requests
          await _addUserIdToRequest(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (DioException error, handler) {
          final customError = _handleError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: customError,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  /// Automatically add user ID to all requests
  Future<void> _addUserIdToRequest(RequestOptions options) async {
    try {
      // Get user ID from token storage
      final userId = await _tokenStorage.getUserId();

      if (userId != null && userId.isNotEmpty) {
        // Add user ID as header
        options.headers['X-User-ID'] = userId;

        // Also add as query parameter for GET requests (optional)
        if (options.method.toUpperCase() == 'GET') {
          options.queryParameters['user_id'] = userId;
        }

        // Add as body parameter for POST/PUT requests if body is a Map
        if (['POST', 'PUT', 'PATCH'].contains(options.method.toUpperCase())) {
          if (options.data is Map<String, dynamic>) {
            options.data['user_id'] = userId;
          } else if (options.data is FormData) {
            // For form data requests
            (options.data as FormData).fields.add(MapEntry('user_id', userId));
          }
        }

        debugPrint(
          'DioClient: Added user ID to ${options.method} ${options.path}: $userId',
        );
      } else {
        debugPrint(
          'DioClient: No user ID found for request: ${options.method} ${options.path}',
        );
      }
    } catch (e) {
      debugPrint('DioClient: Error adding user ID to request: $e');
    }
  }

  /// Manually refresh user authentication for all future requests
  Future<void> refreshUserAuth() async {
    // This will ensure the next request gets the latest user ID
    debugPrint('DioClient: User authentication refreshed');
  }

  /// Check if user is authenticated for API calls
  Future<bool> isUserAuthenticated() async {
    final userId = await _tokenStorage.getUserId();
    return userId != null && userId.isNotEmpty;
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    return await _tokenStorage.getUserId();
  }

  // Get current base URL
  static String get baseUrl => _baseUrl;

  // Get WebSocket URL (for your waste detection)
  static String get wsUrl => _baseUrl
      .replaceFirst('http://', 'ws://')
      .replaceFirst('/api/v1', '/ws/v1/detect');

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      switch (statusCode) {
        case 400:
          return BadRequestException(data['message'] ?? 'Bad request');
        case 401:
          return UnauthorizedException(
            data['message'] ?? 'Unauthorized - Please login again',
          );
        case 403:
          return ForbiddenException(data['message'] ?? 'Forbidden');
        case 404:
          return NotFoundException(data['message'] ?? 'Not found');
        case 422:
          return ValidationException(data);
        case 500:
          return ServerException(data['message'] ?? 'Internal server error');
        default:
          return ApiException('Server error: $statusCode - $data');
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return ConnectionTimeoutException('Connection timeout');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return ReceiveTimeoutException('Receive timeout');
    } else if (error.type == DioExceptionType.connectionError) {
      return NetworkException('No internet connection');
    } else {
      return ApiException('Network error: ${error.message}');
    }
  }
}

// Exception classes (same as before)
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class BadRequestException extends ApiException {
  BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;
  ValidationException(dynamic data)
    : errors = data is Map<String, dynamic> ? data['errors'] : null,
      super(
        data is Map<String, dynamic>
            ? (data['message'] ?? 'Validation error')
            : 'Validation error',
      );
}

class ServerException extends ApiException {
  ServerException(super.message);
}

class ConnectionTimeoutException extends ApiException {
  ConnectionTimeoutException(super.message);
}

class ReceiveTimeoutException extends ApiException {
  ReceiveTimeoutException(super.message);
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}
