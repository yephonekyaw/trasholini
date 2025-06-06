import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_client/models/waste_history_model.dart';
import 'package:flutter_client/services/apis/dio_client.dart';

class WasteHistoryService {
  static WasteHistoryService? _instance;
  final DioClient _dioClient = DioClient();

  WasteHistoryService._internal();

  factory WasteHistoryService() {
    _instance ??= WasteHistoryService._internal();
    return _instance!;
  }

  /// Initialize the service
  Future<void> initialize() async {
    await _dioClient.initialize();
  }

  /// Get disposal history with optional filtering
  /// [wasteClass] - Optional filter by waste class
  /// [limit] - Maximum number of records to return (default: 50, max: 100)
  Future<DisposalHistoryResponse> getDisposalHistory({
    String? wasteClass,
    int? limit,
  }) async {
    try {
      debugPrint('WasteHistoryService: Getting disposal history');
      debugPrint('  - Waste class filter: ${wasteClass ?? 'None'}');
      debugPrint('  - Limit: ${limit ?? 'Default'}');

      // Ensure DioClient is initialized
      await _dioClient.initialize();

      // Check if user is authenticated
      final isAuthenticated = await _dioClient.isUserAuthenticated();
      if (!isAuthenticated) {
        throw UnauthorizedException(
          'User not authenticated. Please login first.',
        );
      }

      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (wasteClass != null && wasteClass.isNotEmpty) {
        queryParams['waste_class'] = wasteClass;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      debugPrint('WasteHistoryService: Sending request to /disposal/history');

      // Make API call using DioClient
      final response = await _dioClient.dio.get(
        '/disposal/history',
        queryParameters: queryParams,
      );

      debugPrint(
        'WasteHistoryService: Received response with status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final result = DisposalHistoryResponse.fromJson(response.data);

        debugPrint('WasteHistoryService: History retrieved successfully');
        debugPrint('  - Total items: ${result.count}');
        debugPrint('  - Items retrieved: ${result.history.length}');

        return result;
      } else {
        throw ServerException(
          'Unexpected response status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('WasteHistoryService: DioException occurred: ${e.message}');
      debugPrint('  - Error type: ${e.type}');
      debugPrint('  - Response data: ${e.response?.data}');

      // Re-throw the exception as it's already handled by DioClient
      rethrow;
    } catch (e) {
      debugPrint('WasteHistoryService: Unexpected error: $e');
      throw ApiException('Failed to get disposal history: ${e.toString()}');
    }
  }

  /// Get disposal history within a specific date range
  /// [startDate] - Start date (inclusive)
  /// [endDate] - End date (inclusive)
  /// [wasteClass] - Optional filter by waste class
  /// [limit] - Maximum number of records to return (default: 100, max: 500)
  Future<DisposalHistoryResponse> getDisposalHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? wasteClass,
    int? limit,
  }) async {
    try {
      debugPrint('WasteHistoryService: Getting disposal history by date range');
      debugPrint('  - Start date: ${startDate.toIso8601String()}');
      debugPrint('  - End date: ${endDate.toIso8601String()}');
      debugPrint('  - Waste class filter: ${wasteClass ?? 'None'}');
      debugPrint('  - Limit: ${limit ?? 'Default'}');

      // Validate date range
      if (startDate.isAfter(endDate)) {
        throw ArgumentError('Start date must be before or equal to end date');
      }

      // Ensure DioClient is initialized
      await _dioClient.initialize();

      // Check if user is authenticated
      final isAuthenticated = await _dioClient.isUserAuthenticated();
      if (!isAuthenticated) {
        throw UnauthorizedException(
          'User not authenticated. Please login first.',
        );
      }

      // Build query parameters
      final queryParams = <String, dynamic>{
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      };

      if (wasteClass != null && wasteClass.isNotEmpty) {
        queryParams['waste_class'] = wasteClass;
      }
      if (limit != null) {
        queryParams['limit'] = limit;
      }

      debugPrint(
        'WasteHistoryService: Sending request to /disposal/date-range',
      );

      // Make API call using DioClient
      final response = await _dioClient.dio.get(
        '/disposal/date-range',
        queryParameters: queryParams,
      );

      debugPrint(
        'WasteHistoryService: Received date range response with status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final result = DisposalHistoryResponse.fromJson(response.data);

        debugPrint(
          'WasteHistoryService: Date range history retrieved successfully',
        );
        debugPrint('  - Total items: ${result.count}');
        debugPrint('  - Items retrieved: ${result.history.length}');
        debugPrint(
          '  - Date range: ${startDate.toLocal().toString().split(' ')[0]} to ${endDate.toLocal().toString().split(' ')[0]}',
        );

        return result;
      } else {
        throw ServerException(
          'Unexpected response status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'WasteHistoryService: DioException in date range query: ${e.message}',
      );
      debugPrint('  - Error type: ${e.type}');
      debugPrint('  - Response data: ${e.response?.data}');

      // Re-throw the exception as it's already handled by DioClient
      rethrow;
    } catch (e) {
      debugPrint(
        'WasteHistoryService: Unexpected error in date range query: $e',
      );
      throw ApiException(
        'Failed to get disposal history by date range: ${e.toString()}',
      );
    }
  }

  /// Get disposal history for the last N days
  /// [days] - Number of days to look back
  /// [wasteClass] - Optional filter by waste class
  /// [limit] - Maximum number of records to return
  Future<DisposalHistoryResponse> getDisposalHistoryLastDays({
    required int days,
    String? wasteClass,
    int? limit,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      debugPrint('WasteHistoryService: Getting history for last $days days');

      return await getDisposalHistoryByDateRange(
        startDate: startDate,
        endDate: endDate,
        wasteClass: wasteClass,
        limit: limit,
      );
    } catch (e) {
      debugPrint(
        'WasteHistoryService: Error getting history for last $days days: $e',
      );
      rethrow;
    }
  }

  /// Get disposal history for the current week (Monday to Sunday)
  /// [wasteClass] - Optional filter by waste class
  /// [limit] - Maximum number of records to return
  Future<DisposalHistoryResponse> getDisposalHistoryThisWeek({
    String? wasteClass,
    int? limit,
  }) async {
    try {
      final now = DateTime.now();

      // Calculate start of week (Monday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      // Calculate end of week (Sunday)
      final endOfWeek = startDate.add(const Duration(days: 6));
      final endDate = DateTime(
        endOfWeek.year,
        endOfWeek.month,
        endOfWeek.day,
        23,
        59,
        59,
      );

      debugPrint('WasteHistoryService: Getting history for this week');

      return await getDisposalHistoryByDateRange(
        startDate: startDate,
        endDate: endDate,
        wasteClass: wasteClass,
        limit: limit,
      );
    } catch (e) {
      debugPrint(
        'WasteHistoryService: Error getting history for this week: $e',
      );
      rethrow;
    }
  }

  /// Get disposal history for the current month
  /// [wasteClass] - Optional filter by waste class
  /// [limit] - Maximum number of records to return
  Future<DisposalHistoryResponse> getDisposalHistoryThisMonth({
    String? wasteClass,
    int? limit,
  }) async {
    try {
      final now = DateTime.now();

      // Start of month
      final startDate = DateTime(now.year, now.month, 1);

      // End of month
      final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      debugPrint('WasteHistoryService: Getting history for this month');

      return await getDisposalHistoryByDateRange(
        startDate: startDate,
        endDate: endDate,
        wasteClass: wasteClass,
        limit: limit,
      );
    } catch (e) {
      debugPrint(
        'WasteHistoryService: Error getting history for this month: $e',
      );
      rethrow;
    }
  }

  /// Get recent scans (limited number for overview)
  /// [limit] - Number of recent items to fetch (default: 5)
  Future<DisposalHistoryResponse> getRecentScans({int limit = 5}) async {
    try {
      debugPrint('WasteHistoryService: Getting recent scans (limit: $limit)');

      return await getDisposalHistory(limit: limit);
    } catch (e) {
      debugPrint('WasteHistoryService: Error getting recent scans: $e');
      rethrow;
    }
  }

  /// Get all unique waste classes from user's disposal history
  Future<WasteClassesResponse> getWasteClasses() async {
    try {
      debugPrint('WasteHistoryService: Getting waste classes');

      // Ensure DioClient is initialized
      await _dioClient.initialize();

      // Check if user is authenticated
      final isAuthenticated = await _dioClient.isUserAuthenticated();
      if (!isAuthenticated) {
        throw UnauthorizedException(
          'User not authenticated. Please login first.',
        );
      }

      debugPrint(
        'WasteHistoryService: Sending request to /disposal/waste-classes',
      );

      // Make API call using DioClient
      final response = await _dioClient.dio.get('/disposal/waste-classes');

      debugPrint(
        'WasteHistoryService: Received waste classes response with status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final result = WasteClassesResponse.fromJson(response.data);

        debugPrint('WasteHistoryService: Waste classes retrieved successfully');
        debugPrint('  - Total classes: ${result.count}');
        debugPrint('  - Total records: ${result.totalRecords}');
        debugPrint('  - Classes: ${result.wasteClasses}');

        return result;
      } else {
        throw ServerException(
          'Unexpected response status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'WasteHistoryService: DioException in getWasteClasses: ${e.message}',
      );
      debugPrint('  - Error type: ${e.type}');
      debugPrint('  - Response data: ${e.response?.data}');

      // Re-throw the exception as it's already handled by DioClient
      rethrow;
    } catch (e) {
      debugPrint(
        'WasteHistoryService: Unexpected error in getWasteClasses: $e',
      );
      throw ApiException('Failed to get waste classes: ${e.toString()}');
    }
  }

  /// Get filtered disposal history by waste class
  Future<DisposalHistoryResponse> getHistoryByWasteClass({
    required String wasteClass,
    int? limit,
  }) async {
    try {
      debugPrint(
        'WasteHistoryService: Getting history for waste class: $wasteClass',
      );

      return await getDisposalHistory(wasteClass: wasteClass, limit: limit);
    } catch (e) {
      debugPrint(
        'WasteHistoryService: Error getting history by waste class: $e',
      );
      rethrow;
    }
  }

  /// Get paginated disposal history
  /// Useful for implementing infinite scroll or pagination
  Future<DisposalHistoryResponse> getPaginatedHistory({
    int limit = 20,
    String? wasteClass,
  }) async {
    try {
      debugPrint(
        'WasteHistoryService: Getting paginated history (limit: $limit)',
      );

      return await getDisposalHistory(wasteClass: wasteClass, limit: limit);
    } catch (e) {
      debugPrint('WasteHistoryService: Error getting paginated history: $e');
      rethrow;
    }
  }

  /// Check if the service is ready to make API calls
  Future<bool> isServiceReady() async {
    try {
      await _dioClient.initialize();
      return await _dioClient.isUserAuthenticated();
    } catch (e) {
      debugPrint('WasteHistoryService: Service readiness check failed: $e');
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
