import 'package:dio/dio.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio dio;
  static const String baseUrl = 'http://localhost:8000/api/v1/';

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available (you can implement this later)
          // final token = getStoredToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          handler.next(options);
        },
        onResponse: (response, handler) {
          // Handle successful responses
          handler.next(response);
        },
        onError: (DioException error, handler) {
          // Handle errors globally
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

  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      // Handle specific status codes
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
