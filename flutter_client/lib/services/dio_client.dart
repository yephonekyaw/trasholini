import 'dart:io';
import 'package:dio/dio.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio dio;
  static String? _dynamicBaseUrl;

  // Fallback IPs to try
  static const List<String> _fallbackIPs = [
    '10.4.150.200',
    '192.168.1.100',
    '192.168.0.100',
    '10.0.0.100',
  ];

  DioClient._internal();

  factory DioClient() {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  // Initialize with dynamic IP detection using network_info_plus
  Future<void> initialize() async {
    final baseUrl = await _getWorkingBaseUrl();

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _addInterceptors();
  }

  // Find a working IP address using network_info_plus
  static Future<String> _getWorkingBaseUrl() async {
    if (_dynamicBaseUrl != null) return _dynamicBaseUrl!;

    // Try to get device's WiFi IP using network_info_plus
    final deviceIP = await _getDeviceWiFiIP();
    if (deviceIP != null && await _testConnection(deviceIP)) {
      _dynamicBaseUrl = 'http://$deviceIP:8000/api/v1';
      return _dynamicBaseUrl!;
    }

    // Try fallback IPs
    for (final ip in _fallbackIPs) {
      if (await _testConnection(ip)) {
        _dynamicBaseUrl = 'http://$ip:8000/api/v1';
        return _dynamicBaseUrl!;
      }
    }

    // Last resort - use original hardcoded IP
    _dynamicBaseUrl = 'http://10.4.150.200:8000/api/v1';
    return _dynamicBaseUrl!;
  }

  // Get device WiFi IP using network_info_plus
  static Future<String?> _getDeviceWiFiIP() async {
    try {
      final networkInfo = NetworkInfo();

      // Get WiFi IP address
      final wifiIP = await networkInfo.getWifiIP();

      if (wifiIP != null && wifiIP.isNotEmpty && wifiIP != '0.0.0.0') {
        return wifiIP;
      }
    } catch (e) {
      // Ignore errors, will try fallback IPs
    }
    return null;
  }

  // Test if IP is reachable
  static Future<bool> _testConnection(String ip) async {
    try {
      final socket = await Socket.connect(
        ip,
        8000,
        timeout: const Duration(seconds: 2),
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Add interceptors (your existing code)
  void _addInterceptors() {
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

  // Get current base URL
  static String? getCurrentBaseUrl() => _dynamicBaseUrl;

  // Reset for testing different IPs
  static void reset() {
    _dynamicBaseUrl = null;
  }

  // Manually set IP (for testing or manual override)
  static void setManualIP(String ip) {
    _dynamicBaseUrl = 'http://$ip:8000/api/v1';
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

// Exception classes (your existing code)
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
