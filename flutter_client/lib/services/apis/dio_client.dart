import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class DioClient {
  static DioClient? _instance;
  Dio? _dio;
  bool _isInitialized = false;

  // Manual IP configuration - change this to your server IP
  static const String _baseUrl = 'http://192.168.0.102:8000/api/v1';

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

    _addInterceptors();
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
  void _addInterceptors() {
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

    // Add your custom interceptor for auth and error handling
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if needed
          // final token = getStoredToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
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
          return UnauthorizedException(data['message'] ?? 'Unauthorized');
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

// Exception classes
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
