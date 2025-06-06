import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_client/models/trash_bin/trash_bin.dart';
import 'package:flutter_client/services/apis/bin_api_service.dart';

class TrashBinNotifier extends StateNotifier<List<TrashBin>> {
  TrashBinNotifier() : super([]) {
    _loadBins();
  }

  final BinApiService _binApiService = BinApiService();
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get allSelected => state.every((bin) => bin.isSelected);
  List<TrashBin> get selectedBins =>
      state.where((bin) => bin.isSelected).toList();
  List<TrashBin> get availableBins => state;

  /// Load bins from backend (combines available bins with user's accessible bins)
  Future<void> _loadBins() async {
    try {
      _setLoading(true);
      _clearError();

      // Get user's bins with details (combines both API calls)
      final bins = await _binApiService.getUserBinsWithDetails();
      state = bins;

      debugPrint(
        'TrashBinProvider: Loaded ${bins.length} bins, ${selectedBins.length} selected',
      );
    } catch (e) {
      _setError('Failed to load bins: $e');
      debugPrint('TrashBinProvider: Error loading bins: $e');

      // Fallback to empty state on error
      state = [];
    } finally {
      _setLoading(false);
    }
  }

  /// Save current selection to backend
  Future<bool> saveBinsToBackend() async {
    try {
      _setLoading(true);
      _clearError();

      final selectedBinIds = selectedBins.map((bin) => bin.id).toList();
      await _binApiService.updateUserBinList(selectedBinIds);

      debugPrint(
        'TrashBinProvider: Saved ${selectedBinIds.length} bins to backend',
      );
      return true;
    } catch (e) {
      _setError('Failed to save bins: $e');
      debugPrint('TrashBinProvider: Error saving bins: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle bin selection (local state only)
  void toggleBinSelection(String binId) {
    state =
        state.map((bin) {
          if (bin.id == binId) {
            return bin.copyWith(isSelected: !bin.isSelected);
          }
          return bin;
        }).toList();

    debugPrint(
      'TrashBinProvider: Toggled bin $binId, now ${selectedBins.length} selected',
    );
  }

  /// Select all bins (local state only)
  void selectAllBins() {
    state = state.map((bin) => bin.copyWith(isSelected: true)).toList();
    debugPrint('TrashBinProvider: Selected all ${state.length} bins');
  }

  /// Deselect all bins (local state only)
  void deselectAllBins() {
    state = state.map((bin) => bin.copyWith(isSelected: false)).toList();
    debugPrint('TrashBinProvider: Deselected all bins');
  }

  /// Refresh bins from backend
  Future<void> refreshBins() async {
    debugPrint('TrashBinProvider: Refreshing bins from backend');
    await _loadBins();
  }

  /// Reset to user's saved selection (discard local changes)
  Future<void> resetToSavedSelection() async {
    try {
      _setLoading(true);
      _clearError();

      final userBinIds = await _binApiService.getUserAccessibleBins();

      // Update state to match saved selection
      state =
          state.map((bin) {
            return bin.copyWith(isSelected: userBinIds.contains(bin.id));
          }).toList();

      debugPrint('TrashBinProvider: Reset to saved selection: $userBinIds');
    } catch (e) {
      _setError('Failed to reset bins: $e');
      debugPrint('TrashBinProvider: Error resetting bins: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Check if current selection differs from saved selection
  Future<bool> hasUnsavedChanges() async {
    try {
      final savedBinIds = await _binApiService.getUserAccessibleBins();
      final currentBinIds = selectedBins.map((bin) => bin.id).toSet();
      final savedBinIdsSet = savedBinIds.toSet();

      return !currentBinIds.containsAll(savedBinIdsSet) ||
          !savedBinIdsSet.containsAll(currentBinIds);
    } catch (e) {
      debugPrint('TrashBinProvider: Error checking for unsaved changes: $e');
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String error) {
    _error = error;
  }

  void _clearError() {
    _error = null;
  }
}

// Providers
final trashBinProvider =
    StateNotifierProvider<TrashBinNotifier, List<TrashBin>>(
      (ref) => TrashBinNotifier(),
    );

// Additional providers for specific states
final trashBinLoadingProvider = Provider<bool>((ref) {
  return ref.watch(trashBinProvider.notifier).isLoading;
});

final trashBinErrorProvider = Provider<String?>((ref) {
  return ref.watch(trashBinProvider.notifier).error;
});

// Provider for selected bins count
final selectedBinsCountProvider = Provider<int>((ref) {
  return ref.watch(trashBinProvider.notifier).selectedBins.length;
});

// Provider for checking if all bins are selected
final allBinsSelectedProvider = Provider<bool>((ref) {
  return ref.watch(trashBinProvider.notifier).allSelected;
});
