import 'package:flutter/foundation.dart';
import 'package:flutter_client/services/apis/dio_client.dart';
import 'package:flutter_client/models/trash_bin/trash_bin.dart';

class BinApiService {
  final DioClient _dioClient = DioClient();

  /// Get all available bin types from the backend
  Future<List<TrashBin>> getAllAvailableBins() async {
    try {
      debugPrint('BinAPI: Fetching all available bins');

      final response = await _dioClient.dio.get('/bin/available');

      final List<dynamic> binsData = response.data['bins'] ?? [];
      final bins =
          binsData.map((binData) => TrashBin.fromJson(binData)).toList();

      debugPrint('BinAPI: Retrieved ${bins.length} available bins');
      return bins;
    } catch (e) {
      debugPrint('BinAPI: Error fetching available bins: $e');
      rethrow;
    }
  }

  /// Get bins that the current user has access to (their selected bins)
  Future<List<String>> getUserAccessibleBins() async {
    try {
      debugPrint('BinAPI: Fetching user accessible bins');

      final response = await _dioClient.dio.get('/bin/user-bins');

      final List<dynamic> binIds = response.data['accessible_bin_ids'] ?? [];
      final result = binIds.cast<String>();

      debugPrint('BinAPI: User has access to ${result.length} bins: $result');
      return result;
    } catch (e) {
      debugPrint('BinAPI: Error fetching user accessible bins: $e');
      rethrow;
    }
  }

  /// Update user's bin list (bins they have access to)
  Future<Map<String, dynamic>> updateUserBinList(List<String> binIds) async {
    try {
      debugPrint('BinAPI: Updating user bin list: $binIds');

      final response = await _dioClient.dio.put(
        '/bin/user-bins',
        data: {
          'bin_ids': binIds,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('BinAPI: User bin list updated successfully');
      return response.data;
    } catch (e) {
      debugPrint('BinAPI: Error updating user bin list: $e');
      rethrow;
    }
  }

  /// Helper method to get user's bins with full details
  Future<List<TrashBin>> getUserBinsWithDetails() async {
    try {
      // Get all available bins and user's accessible bin IDs
      final availableBins = await getAllAvailableBins();
      final userBinIds = await getUserAccessibleBins();

      // Filter and mark selected bins
      final userBins =
          availableBins.map((bin) {
            return bin.copyWith(isSelected: userBinIds.contains(bin.id));
          }).toList();

      debugPrint(
        'BinAPI: Retrieved ${userBins.length} bins for user with ${userBinIds.length} selected',
      );
      return userBins;
    } catch (e) {
      debugPrint('BinAPI: Error getting user bins with details: $e');
      rethrow;
    }
  }
}
